require "test_helper"

class ImageMetadataStripperTest < ActiveSupport::TestCase
  def jpeg_with_gps
    original = file_fixture("kitten.jpg").binread
    exif = "Exif\x00\x00GPSLatitude35.6812".b
    app1 = "\xFF\xE1".b + [exif.bytesize + 2].pack("n") + exif
    original.byteslice(0, 2) + app1 + original.byteslice(2..)
  end

  test "removes Exif from JPEG and keeps the image data" do
    data = jpeg_with_gps
    stripped = ImageMetadataStripper.strip(data, "image/jpeg")
    assert_not_includes stripped, "GPSLatitude"
    assert stripped.start_with?("\xFF\xD8".b)
    assert_equal "image/jpeg", Marcel::MimeType.for(StringIO.new(stripped))
    assert stripped.end_with?(data.byteslice(-100..))
  end

  test "removes text and eXIf chunks from PNG" do
    chunk = ->(type, body) { [body.bytesize].pack("N") + type + body + [Zlib.crc32(type + body)].pack("N") }
    png = "\x89PNG\r\n\x1A\n".b +
          chunk.("IHDR", [1, 1, 8, 2, 0, 0, 0].pack("NNCCCCC")) +
          chunk.("eXIf", "GPSLatitude".b) +
          chunk.("tEXt", "Comment\x00secret".b) +
          chunk.("IDAT", Zlib::Deflate.deflate("\x00\x00\x00\x00".b)) +
          chunk.("IEND", "".b)
    stripped = ImageMetadataStripper.strip(png, "image/png")
    assert_not_includes stripped, "GPSLatitude"
    assert_not_includes stripped, "secret"
    assert_includes stripped, "IDAT"
  end

  test "removes EXIF chunk from WebP and clears the flag" do
    chunk = ->(type, body) { type + [body.bytesize].pack("V") + body + (body.bytesize.odd? ? "\x00".b : "".b) }
    body = chunk.("VP8X", [0x08, 0, 0, 0].pack("C*") + "\x00\x00\x00\x00\x00\x00".b) +
           chunk.("VP8 ", "fakeimagedata".b) +
           chunk.("EXIF", "GPSLatitude".b)
    webp = "RIFF".b + [body.bytesize + 4].pack("V") + "WEBP".b + body
    stripped = ImageMetadataStripper.strip(webp, "image/webp")
    assert_not_includes stripped, "GPSLatitude"
    assert_includes stripped, "fakeimagedata"
    assert_equal 0, stripped.getbyte(20) & 0x0C
    assert_equal stripped.bytesize - 8, stripped.byteslice(4, 4).unpack1("V")
  end

  test "returns nil for broken data" do
    assert_nil ImageMetadataStripper.strip("not an image".b, "image/jpeg")
  end
end

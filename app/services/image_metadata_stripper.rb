# 画像から撮影場所（GPS）などのメタデータを取り除く。
# 画素データは再圧縮せずにそのまま残し、メタデータの入れ物だけを削除する。
# 外部コマンドに頼らないので、本番環境に ImageMagick がなくても動く。
class ImageMetadataStripper
  JPEG_SOI = "\xFF\xD8".b
  # APP1（Exif・XMP）、APP13（IPTC）、COM（コメント）を削除する
  JPEG_DROP_MARKERS = [0xE1, 0xED, 0xFE].freeze

  PNG_SIGNATURE = "\x89PNG\r\n\x1A\n".b
  PNG_DROP_CHUNKS = %w[eXIf tEXt zTXt iTXt tIME].freeze

  WEBP_DROP_CHUNKS = %w[EXIF XMP\ ].freeze

  # アップロードされたファイルを、その場でメタデータなしの内容に書き換える
  def self.strip_upload!(upload)
    return unless upload.respond_to?(:tempfile)

    file = upload.tempfile
    file.rewind
    data = file.read.b
    stripped = strip(data, upload.content_type)
    if stripped && stripped != data
      file.rewind
      file.truncate(0)
      file.write(stripped)
      file.flush
    end
    file.rewind
  end

  def self.strip(data, content_type)
    case content_type
    when "image/jpeg" then strip_jpeg(data)
    when "image/png"  then strip_png(data)
    when "image/webp" then strip_webp(data)
    end
  rescue StandardError
    nil
  end

  def self.strip_jpeg(data)
    return nil unless data.start_with?(JPEG_SOI)

    out = JPEG_SOI.dup
    pos = 2
    while pos + 4 <= data.bytesize
      return nil unless data.getbyte(pos) == 0xFF

      marker = data.getbyte(pos + 1)
      # SOS 以降は画像データなので、残りをそのままつなぐ
      if marker == 0xDA
        out << data.byteslice(pos..)
        return out
      end

      length = data.byteslice(pos + 2, 2).unpack1("n")
      segment = data.byteslice(pos, 2 + length)
      return nil if segment.nil? || segment.bytesize < 2 + length

      out << segment unless JPEG_DROP_MARKERS.include?(marker)
      pos += 2 + length
    end
    nil
  end

  def self.strip_png(data)
    return nil unless data.start_with?(PNG_SIGNATURE)

    out = PNG_SIGNATURE.dup
    pos = PNG_SIGNATURE.bytesize
    while pos + 12 <= data.bytesize
      length = data.byteslice(pos, 4).unpack1("N")
      type = data.byteslice(pos + 4, 4)
      chunk = data.byteslice(pos, 12 + length)
      return nil if chunk.nil? || chunk.bytesize < 12 + length

      out << chunk unless PNG_DROP_CHUNKS.include?(type)
      pos += 12 + length
      return out if type == "IEND"
    end
    nil
  end

  def self.strip_webp(data)
    return nil unless data.byteslice(0, 4) == "RIFF" && data.byteslice(8, 4) == "WEBP"

    chunks = +"".b
    pos = 12
    while pos + 8 <= data.bytesize
      type = data.byteslice(pos, 4)
      size = data.byteslice(pos + 4, 4).unpack1("V")
      padded = size + (size.odd? ? 1 : 0)
      chunk = data.byteslice(pos, 8 + padded)
      return nil if chunk.nil? || chunk.bytesize < 8 + size

      unless WEBP_DROP_CHUNKS.include?(type)
        if type == "VP8X"
          # 「EXIF・XMP あり」の印（フラグ）を消す
          chunk = chunk.dup
          chunk.setbyte(8, chunk.getbyte(8) & ~0x0C)
        end
        chunks << chunk
      end
      pos += 8 + padded
    end
    "RIFF".b + [chunks.bytesize + 4].pack("V") + "WEBP".b + chunks
  end
end

require "test_helper"

class UploadContentTypeValidatorTest < ActiveSupport::TestCase
  test "PDFの実体とContent-Typeが一致する" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("%PDF-1.4\nTest PDF"),
      filename: "test.pdf",
      content_type: "application/pdf",
      identify: false
    )

    assert UploadContentTypeValidator.valid?(blob)
  end

  test "JPEGと偽装したテキストファイルを拒否する" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("This is not a JPEG"),
      filename: "fake.jpg",
      content_type: "image/jpeg",
      identify: false
    )

    assert_not UploadContentTypeValidator.valid?(blob)
  end
  
  test "正常なPDFアップロードを許可する" do
    upload = uploaded_file(
      "%PDF-1.4\nTest PDF",
      "test.pdf",
      "application/pdf"
    )
  
    assert UploadContentTypeValidator.valid_upload?(
      upload,
      allowed_types: Verification::EVIDENCE_CONTENT_TYPES
    )
  end
  
  test "JPEGに偽装したテキストファイルを拒否する" do
    upload = uploaded_file(
      "This is not a JPEG",
      "fake.jpg",
      "image/jpeg"
    )
  
    assert_not UploadContentTypeValidator.valid_upload?(
      upload,
      allowed_types: Verification::EVIDENCE_CONTENT_TYPES
    )
  end
  
  test "PDFをJPEGと申告したファイルを拒否する" do
    upload = uploaded_file(
      "%PDF-1.4\nTest PDF",
      "fake.jpg",
      "image/jpeg"
    )
  
    assert_not UploadContentTypeValidator.valid_upload?(
      upload,
      allowed_types: Verification::EVIDENCE_CONTENT_TYPES
    )
  end
  
  private
  
  def uploaded_file(content, filename, content_type)
    file = Tempfile.new(["upload_test", File.extname(filename)])
    file.binmode
    file.write(content)
    file.rewind
  
    ActionDispatch::Http::UploadedFile.new(
      tempfile: file,
      filename: filename,
      type: content_type
    )
  end
  
end
class UploadContentTypeValidator
  def self.valid?(blob)
    return false unless blob

    detected_type = blob.open do |file|
      Marcel::MimeType.for(file)
    end

    detected_type == blob.content_type
  rescue ActiveStorage::FileNotFoundError, Errno::ENOENT
    false
  end
  
  def self.valid_upload?(upload, allowed_types:)
    return false unless upload.respond_to?(:tempfile)
  
    file = upload.tempfile
    file.rewind
  
    detected_type = Marcel::MimeType.for(file)
  
    allowed_types.include?(detected_type) &&
      detected_type == upload.content_type
  rescue IOError, SystemCallError
    false
  ensure
    file&.rewind
  end
  
end
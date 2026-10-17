# http:// または https:// で始まる、外部に公開されたURLだけを受け付ける
class HttpUrlValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    return if value.blank?

    uri = URI.parse(value)
    valid = uri.is_a?(URI::HTTP) && uri.host.present? && !value.match?(/\s/)
    record.errors.add(attribute, options[:message] || "は http:// または https:// で始まるURLを入力してください") unless valid
  rescue URI::InvalidURIError
    record.errors.add(attribute, options[:message] || "は http:// または https:// で始まるURLを入力してください")
  end
end


require "net/http"
require "json"

class BrevoDelivery
  API_URL = URI("https://api.brevo.com/v3/smtp/email")

  # Mail gem は delivery_method.new(settings) で生成し、送信後に settings を参照する
  attr_accessor :settings

  def initialize(settings = {})
    @settings = settings
  end

  def deliver!(message)
    payload = {
      sender: sender_for(message),
      to: message.to.map { |email| { email: email } },
      subject: message.subject
    }

    payload[:htmlContent] = message.html_part.decoded if message.html_part
    payload[:textContent] = message.text_part.decoded if message.text_part

    if message.html_part.nil? && message.text_part.nil?
      if message.mime_type == "text/html"
        payload[:htmlContent] = message.body.decoded
      else
        payload[:textContent] = message.body.decoded
      end
    end

    request = Net::HTTP::Post.new(API_URL)
    request["api-key"] = ENV.fetch("BREVO_API_KEY")
    request["Content-Type"] = "application/json"
    request.body = JSON.generate(payload)

    response = Net::HTTP.start(
      API_URL.host,
      API_URL.port,
      use_ssl: true,
      open_timeout: 10,
      read_timeout: 15
    ) do |http|
      http.request(request)
    end

    unless response.is_a?(Net::HTTPSuccess)
      raise "Brevo API error: HTTP #{response.code} - #{response.body}"
    end

    response
  end

  private

  def sender_for(message)
    sender = { email: message.from.first }
    name = message[:from]&.display_names&.first
    sender[:name] = name if name.present?
    sender
  end
end

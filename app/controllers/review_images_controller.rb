class ReviewImagesController < ApplicationController
  def show
    review = Review.find(params[:review_id])

    attachment = review.images_attachments.find(params[:id])
    blob = attachment.blob

    allowed_types = %w[
      image/jpeg
      image/png
      image/webp
    ]

    unless allowed_types.include?(blob.content_type)
      raise ActiveRecord::RecordNotFound
    end

    response.headers["X-Content-Type-Options"] = "nosniff"

    send_data blob.download,
              filename: blob.filename.to_s,
              type: blob.content_type,
              disposition: "inline"
  end
end
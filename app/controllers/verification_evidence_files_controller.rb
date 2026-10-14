class VerificationEvidenceFilesController < ApplicationController
  before_action :logged_in_user

  def show
    verification = Verification.find(params[:verification_id])

    unless current_user.admin? ||
           verification.user_id == current_user.id
      raise ActiveRecord::RecordNotFound
    end

    attachment =
      verification.evidence_files_attachments.find(params[:id])

    blob = attachment.blob

    response.headers["Cache-Control"] = "private, no-store"
    response.headers["X-Content-Type-Options"] = "nosniff"

    send_data blob.download,
              filename: blob.filename.to_s,
              type: "application/octet-stream",
              disposition: "attachment"
  end
end
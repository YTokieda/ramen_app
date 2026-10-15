
require "test_helper"

class VerificationEvidenceFilesControllerTest < ActionDispatch::IntegrationTest
  setup do

    @verification = verifications(:one)
    @owner = users(:archer)
    @other_user = users(:lana)
    @admin = users(:michael)

    @verification.update!(user: @owner)

    @verification.evidence_files.attach(
      io: StringIO.new("sample evidence"),
      filename: "evidence.pdf",
      content_type: "application/pdf"
    )

    @attachment = @verification.evidence_files.first

    @url = verification_evidence_file_path(
      @verification,
      @attachment
    )
  end

  test "owner can download evidence" do
    log_in_as(@owner)

    get @url

    assert_response :success
    assert_equal "sample evidence", response.body
    assert_match(/attachment/, response.headers["Content-Disposition"])
  end

  test "admin can download evidence" do
    log_in_as(@admin)

    get @url

    assert_response :success
  end

  test "other user cannot download evidence" do
    log_in_as(@other_user)
  
    get @url
  
    assert_response :not_found
  end

  test "guest must log in" do
    get @url

    assert_redirected_to login_url
  end

  test "cannot download evidence from another verification" do
    log_in_as(@owner)
  
    other_verification = verifications(:two)
  
    get verification_evidence_file_path(
      other_verification,
      @attachment
    )
  
    assert_response :not_found
  end
    
  test "cannot download nonexistent evidence attachment" do
    log_in_as(@owner)
  
    nonexistent_id =
      ActiveStorage::Attachment.maximum(:id).to_i + 1000
  
    get verification_evidence_file_path(
      @verification,
      nonexistent_id
    )
  
    assert_response :not_found
  end
    
  test "evidence download has security headers" do
      log_in_as(@owner)
    
      get @url
      assert_response :success
    
      assert_equal "private, no-store",
                   response.headers["Cache-Control"]
    
      assert_equal "nosniff",
                   response.headers["X-Content-Type-Options"]
    
      assert_equal "application/octet-stream",
                   response.media_type
    
      assert_match(
        /attachment/,
        response.headers["Content-Disposition"]
      )
  end
    
end

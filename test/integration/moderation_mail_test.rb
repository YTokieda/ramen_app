require "test_helper"

class ModerationMailTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @admin = users(:michael)
    @user  = users(:archer)
    log_in_as(@admin)
  end

  test "approving a shop submission emails the contributor" do
    submission = ShopSubmission.create!(user: @user, name: "通知テスト店", address: "東京都港区2-2")
    patch approve_admin_shop_submission_path(submission)
    mail = ActionMailer::Base.deliveries.last
    assert_equal [@user.email], mail.to
    assert_match "店舗情報が承認されました", mail.subject
    assert_match "通知テスト店", mail.text_part.decoded
    assert_match "/shops/#{Shop.find_by(name: '通知テスト店').id}", mail.text_part.decoded
  end

  test "rejecting a shop submission emails the result" do
    submission = ShopSubmission.create!(user: @user, name: "見送り店", address: "東京都港区3-3")
    patch reject_admin_shop_submission_path(submission)
    mail = ActionMailer::Base.deliveries.last
    assert_match "店舗情報の審査結果のお知らせ", mail.subject
    assert_match "見送らせていただきました", mail.text_part.decoded
  end

  test "approving and rejecting egg info emails the contributor" do
    verification = verifications(:one)
    verification.update_columns(status: "pending", user_id: @user.id)
    patch approve_admin_verification_path(verification)
    assert_match "卵情報が承認されました", ActionMailer::Base.deliveries.last.subject

    other = Verification.where.not(id: verification.id).first
    other.update_columns(status: "pending", user_id: @user.id)
    patch reject_admin_verification_path(other)
    assert_match "卵情報の審査結果", ActionMailer::Base.deliveries.last.subject
  end

  test "approving a shop owner emails the applicant" do
    owner = ShopOwner.new(user: @user, shop: shops(:two), status: "pending")
    owner.save!(validate: false)
    patch approve_admin_shop_owner_path(owner)
    mail = ActionMailer::Base.deliveries.last
    assert_match "店舗オーナー申請が承認されました", mail.subject
    assert_match "店舗管理", mail.text_part.decoded
  end

  test "no mail for withdrawn users and mail errors do not break the action" do
    submission = ShopSubmission.create!(user: @user, name: "退会者の店", address: "東京都港区4-4")
    @user.update_columns(withdrawn_at: Time.current)
    assert_no_difference "ActionMailer::Base.deliveries.size" do
      patch reject_admin_shop_submission_path(submission)
    end
    assert_equal "rejected", submission.reload.status
  end
end

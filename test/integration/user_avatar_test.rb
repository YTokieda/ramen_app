require "test_helper"

class UserAvatarTest < ActionDispatch::IntegrationTest
  def setup
    @user  = users(:michael)
    @other = users(:archer)
  end

  def png_upload
    file = Tempfile.new(["avatar", ".png"])
    file.binmode
    file.write(File.binread(Rails.root.join("app/assets/images/logo-art.png")))
    file.rewind
    Rack::Test::UploadedFile.new(file.path, "image/png")
  end

  test "user can set, see and remove a profile image" do
    log_in_as(@user)
    patch user_path(@user), params: { user: { name: @user.name, avatar: png_upload } }
    assert_redirected_to @user
    assert @user.reload.avatar.attached?

    get user_avatar_path(@user, v: @user.avatar.blob.id)
    assert_response :success
    assert_equal "image/png", response.media_type
    assert_equal "nosniff", response.headers["X-Content-Type-Options"]

    get user_path(@user)
    assert_select ".profile-header img.avatar[src*=?]", "/users/#{@user.id}/avatar"

    patch user_path(@user), params: { user: { name: @user.name, remove_avatar: "1" } }
    perform_enqueued_jobs
    assert_not @user.reload.avatar.attached?
  end

  test "non-image files are rejected" do
    log_in_as(@user)
    file = Tempfile.new(["fake", ".png"])
    file.write("not really an image")
    file.rewind
    patch user_path(@user), params: { user: { name: @user.name,
                                              avatar: Rack::Test::UploadedFile.new(file.path, "image/png") } }
    assert_response :unprocessable_entity
    assert_not @user.reload.avatar.attached?
  end

  test "users cannot change someone else's image" do
    log_in_as(@other)
    patch user_path(@user), params: { user: { name: @user.name, avatar: png_upload } }
    assert_not @user.reload.avatar.attached?
  end

  test "shows initial when no image is set and 404 for the image url" do
    get user_path(@user)
    assert_select ".profile-header .avatar--initial", @user.name.first
    get user_avatar_path(@user)
    assert_response :not_found
  end

  test "review shows the author's image" do
    log_in_as(@user)
    patch user_path(@user), params: { user: { name: @user.name, avatar: png_upload } }
    review = @user.reviews.first || Review.create!(user: @user, shop: shops(:one), content: "おいしかった")
    get shop_path(review.shop)
    assert_select "#review-#{review.id} .review-author img.avatar"
  end
end

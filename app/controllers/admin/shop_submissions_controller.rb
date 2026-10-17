class Admin::ShopSubmissionsController < ApplicationController
  before_action :logged_in_user
  before_action :admin_user

  def index
    @shop_submissions = ShopSubmission.all
  end

  def show
    @shop_submission = ShopSubmission.find(params[:id])
  end

  def approve
    @shop_submission = ShopSubmission.find(params[:id])
  
    result = nil
  
    begin
      @shop_submission.with_lock do
        if @shop_submission.status != "pending"
          result = :already_processed
  
        elsif Shop.exists?(
          name: @shop_submission.name,
          address: @shop_submission.address
        )
          result = :duplicate_shop
  
        else
          shop = Shop.new(
            name: @shop_submission.name,
            address: @shop_submission.address,
            description: @shop_submission.description,
            website_url: @shop_submission.website_url
          )
  
          shop.save!
          @shop_submission.update!(status: "approved")
  
          AdminAuditLog.create!(
            admin_user: current_user,
            target_type: "ShopSubmission",
            target_id: @shop_submission.id,
            action_type: "approve",
            previous_status: "pending",
            new_status: "approved"
          )
  
          result = :approved
        end
      end
  
    rescue ActiveRecord::RecordInvalid,
           ActiveRecord::RecordNotUnique
      result = :failed
    end
  
    case result
    when :approved
      created_shop = Shop.find_by(name: @shop_submission.name, address: @shop_submission.address)
      ModerationMailer.notify(user: @shop_submission.user, kind: "shop_submission", approved: true,
                              subject_name: @shop_submission.name,
                              link_url: created_shop ? shop_url(created_shop, locale: nil) : root_url(locale: nil))
      flash[:success] = "店舗情報を承認し、店舗を登録しました"
      redirect_to admin_shop_submissions_path
  
    when :already_processed
      flash[:danger] = "この申請はすでに処理されています"
      redirect_to admin_shop_submissions_path
  
    when :duplicate_shop
      flash[:danger] = "同じ店舗がすでに登録されています"
      redirect_to admin_shop_submission_path(@shop_submission)
  
    else
      flash[:danger] = "店舗を登録できませんでした"
      redirect_to admin_shop_submission_path(@shop_submission)
    end
  end


  def reject
    @shop_submission = ShopSubmission.find(params[:id])
  
    processed = false
  
    @shop_submission.with_lock do
      if @shop_submission.status == "pending"
        @shop_submission.update!(status: "rejected")
  
        AdminAuditLog.create!(
          admin_user: current_user,
          target_type: "ShopSubmission",
          target_id: @shop_submission.id,
          action_type: "reject",
          previous_status: "pending",
          new_status: "rejected"
        )
  
        processed = true
      end
    end
  
    if processed
      ModerationMailer.notify(user: @shop_submission.user, kind: "shop_submission", approved: false,
                              subject_name: @shop_submission.name,
                              link_url: user_url(@shop_submission.user, locale: nil))
      flash[:success] = "店舗情報を却下しました"
    else
      flash[:danger] = "この申請はすでに処理されています"
    end
  
    redirect_to admin_shop_submissions_path
  end

end
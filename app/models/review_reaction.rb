class ReviewReaction < ApplicationRecord
  KINDS = %w[helpful].freeze

  belongs_to :review
  belongs_to :user

  validates :kind, inclusion: { in: KINDS }
  validates :user_id, uniqueness: { scope: [:review_id, :kind] }
  validate :not_own_review

  private

  def not_own_review
    errors.add(:base, "自分の口コミにはリアクションできません") if review && review.user_id == user_id
  end
end

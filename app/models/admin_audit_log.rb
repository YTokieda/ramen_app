class AdminAuditLog < ApplicationRecord
  belongs_to :admin_user, class_name: "User"

  validates :target_type, presence: true
  validates :target_id, presence: true
  validates :action_type,
            inclusion: { in: %w[approve reject update_status hide unhide delete] }

  validates :previous_status, presence: true
  validates :new_status, presence: true
end
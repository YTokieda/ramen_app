class CreateAdminAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :admin_audit_logs do |t|
      t.references :admin_user,
             null: false,
             foreign_key: { to_table: :users }
      
      t.string :target_type
      t.integer :target_id
      t.string :action_type
      t.string :previous_status
      t.string :new_status

      t.timestamps
    
    end
    
      add_index :admin_audit_logs, [:target_type, :target_id]
  end
end

class AddGuestCartCleanup < ActiveRecord::Migration[6.1]
  def up
    # Add index for better performance when finding guest carts
    add_index :carts, :user_id unless index_exists?(:carts, :user_id)
    
    # Clean up any orphaned guest carts older than 30 days
    cutoff_date = 30.days.ago.strftime('%Y-%m-%d %H:%M:%S')
    execute <<-SQL
      DELETE FROM carts 
      WHERE user_id IS NULL 
      AND created_at < '#{cutoff_date}'
    SQL
  end

  def down
    remove_index :carts, :user_id if index_exists?(:carts, :user_id)
  end
end

class ExampleSafeMigration < ActiveRecord::Migration[6.1]
  def change
    # Safe way to add indexes
    add_index :table_name, :column_name unless index_exists?(:table_name, :column_name)
    
    # Or use conditional syntax
    unless index_exists?(:carts, [:user_id, :created_at])
      add_index :carts, [:user_id, :created_at]
    end
  end
end
class CreateCarts < ActiveRecord::Migration[6.1]
  def change
    create_table :carts do |t|
      t.references :user, null: true, foreign_key: true, index: true
      t.integer :cart_items_count, default: 0, null: false
      t.timestamps
    end

    # Remove this line since t.references already creates the index
    # add_index :carts, :user_id
  end
end

class AddLastAccessedAtToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :last_accessed_at, :datetime
  end
end

class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  
  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  def update_total_price
    self.total_price = cart_items.sum(&:total_price)
    save
  end

  def update_last_accessed
    update(last_accessed_at: Time.current)
  end
end

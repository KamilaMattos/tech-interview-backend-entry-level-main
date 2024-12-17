class MarkCartAsAbandonedJob
  include Sidekiq::Job

  def perform(*args)
    Cart.where('last_accessed_at < ?', 3.hours.ago)
        .where(abandoned: false)
        .find_each do |cart|
      cart.update(abandoned: true)
    end
  end
end

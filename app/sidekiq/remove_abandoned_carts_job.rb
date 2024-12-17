class RemoveAbandonedCartsJob
    include Sidekiq::Job
  
    def perform
        Cart.where('abandoned = ? AND updated_at < ?', true, 7.days.ago).destroy_all
    end
end
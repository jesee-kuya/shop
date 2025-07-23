namespace :cart do
  desc "Clean up old guest carts"
  task cleanup: :environment do
    # Remove guest carts older than 30 days
    old_carts = Cart.where(user_id: nil).where('created_at < ?', 30.days.ago)
    count = old_carts.count
    old_carts.destroy_all
    
    puts "Cleaned up #{count} old guest carts"
  end
end
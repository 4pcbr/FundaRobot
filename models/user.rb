class User < ActiveRecord::Base

  has_many :subscriptions

  validates :email, :presence => true,
                    :length => {
                      :minimum => 5,
                      :maximum => 255,
                    },
                    :uniqueness => {
                      :case_sensitive => false,
                    },
                    :format => {
                      :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i,
                    }

  def subscribe_to(feed)
    subscription = Subscription.find_or_create_by(
      :user_id => self.id,
      :feed_id => feed.id,
    )
    subscription.update_attributes(
      :is_active => true
    )
    subscription.valid?
  end

end

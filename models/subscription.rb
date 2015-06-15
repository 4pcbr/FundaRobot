class Subscription < ActiveRecord::Base
  belongs_to :feed
  belongs_to :user

  validates :user_id, :presence => true

  validates :feed_id, :presence => true,
                      :uniqueness => {
                        :scope => :user_id,
                      }
end

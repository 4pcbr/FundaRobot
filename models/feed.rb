class Feed < ActiveRecord::Base

  KNOWN_INTERVALS = {
    '5min'  => 5,
    '15min' => 15,
    '30min' => 30,
    '1h'    => 60,
    '24h'   => 24 * 60,
  }

  has_many :subscriptions
  has_many :page_indexes

  validates :url,       :presence => true,
                        :length => {
                          :minimum => 10,
                          :maximum => 255,
                        },
                        :uniqueness => {
                          :case_sensitive => false,
                        },
                        :format => {
                          :with => URI.regexp,
                        }

  validates :interval,  :presence => true,
                        :inclusion => {
                          :in => KNOWN_INTERVALS.values
                        }
end

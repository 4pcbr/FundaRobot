require 'thread/pool'
require 'net/http'
require 'nokogiri'
require 'mandrill'

THREAD_POOL_SIZE = 2

def parse_response(response)
  doc = Nokogiri::HTML(response)
  elements = doc.css(FundaListingParser.listing_element_css)
  res = []
  elements.each do |element|
    parsed_obj = FundaListingParser.parse_slop(element)
    res.push parsed_obj
  end
  res
end

def send_email(to, opts={})
  m = Mandrill::API.new(ENV['MANDRIL_API_KEY'])
  message = {  
   :subject=> opts[:subject],
   :from_name=> "Lovely Funda robot",
   :to => to.map { |e|
     {
       :email => e,
       :type => 'to'
     }
   },
   :html => opts[:body],
   :from_email => opts[:from]
  }
  m.messages.send message
end

def notify_feed(feed, items)

  return if feed.nil? || items.nil? || items.none?

  feed.update_timestamps

  users = User.joins('INNER JOIN subscriptions ON users.id = subscriptions.user_id').where('subscriptions.is_active = 1 AND subscriptions.feed_id = ?', feed.id)
  return if users.none?

  indexed_items = Hash[*(items.map { |item| [item[:id], item] }.flatten)]

  page_indices = PageIndex.where(
    :feed_id => feed.id,
    :item_hash => indexed_items.keys,
  )
  page_indices.each do |page_index|
    indexed_items.delete(page_index.item_hash)
  end
  return if indexed_items.none?

  to = users.map(&:email)

  msg_body = EmailTmplFunda.render(feed.url, indexed_items.values)

  send_email(to, {
    from:    'oleg@sidorov.nl',
    subject: 'New apartments found',
    body:    msg_body
  })

  indexed_items.keys.each do |item_hash|
    PageIndex.create(
      :feed_id => feed.id,
      :item_hash => item_hash
    )
  end
  
end

task :fetch_feeds => :environment do

  pool = Thread.pool(THREAD_POOL_SIZE)

  Thread.abort_on_exception = true

  logger = Padrino.logger

  feeds = Feed.where('updated_at < DATE_SUB(NOW(), INTERVAL `interval` MINUTE)')

  feeds.each do |feed|

    pool.process do
      begin
        logger.info("Processing feed id:#{feed.id}, url: #{feed.url}")
        uri = URI(feed.url)
        res = Net::HTTP.get_response(uri)
        logger.info("Got response status #{res.code} #{res.message} for feed id #{feed.id}")
        if res.is_a?(Net::HTTPSuccess)
          response_items = parse_response(res.body)
          notify_feed(feed, response_items)
        else
          logger.warn("Omitting due to a non-successful response status")
        end
      rescue => e
        logger.error e.inspect
      end
    end

  end

  pool.shutdown
end

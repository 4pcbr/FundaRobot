FundaRobot::App.controllers :subscriptions do
  
  post :new, :map => '/subscriptions/new' do
    user = User.find_or_create_by(
      :email => params['email']
    )
    if !user.valid?
      halt 400
    end
    feed = Feed.find_or_create_by(
      :url => params['url'],
      :interval => Feed::KNOWN_INTERVALS[params['interval']]
    )
    if !feed.valid?
      halt 400
    end
    if user.subscribe_to(feed)
      'OK'
    else
      halt 400
    end
  end

end

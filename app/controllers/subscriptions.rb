FundaRobot::App.controllers :subscriptions do
  
  post :new, :map => '/subscriptions/new' do
    user = User.find_or_create_by(
      :email => params['email']
    )
    if !user.valid?
      flash[:error] = 'Email format is wrong'
      redirect '/'
    end
    session['user_email'] = user.email
    feed = Feed.find_or_create_by(
      :url => params['url'],
      :interval => Feed::KNOWN_INTERVALS[params['interval']]
    )
    if !feed.valid?
      flash[:error] = 'URL format is wrong'
      redirect '/'
    end
    session['last_url'] = feed.url
    if user.subscribe_to(feed)
      flash[:success] = 'Welcome human. All your base are belong to us.'
      redirect '/'
    else
      flash[:error] = 'Something went wrong'
      redirect '/'
    end
  end

end

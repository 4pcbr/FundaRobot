FundaRobot::App.controllers :title do

  get :index, :map => '/' do
    render 'index'
  end

end

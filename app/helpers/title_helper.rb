# Helper methods defined here can be accessed in any controller or view in the application

module FundaRobot
  class App
    module TitleHelper
      def csrf_token_field(token = nil)
        if defined?(session) && token  ||= session[:csrf]
          hidden_field_tag :authenticity_token, :value => session[:csrf]
        end
      end
    end

    def user_email_from_session
      session['user_email']
    end

    def last_url_from_session
      session['last_url']
    end

    helpers TitleHelper
  end
end

module SessionsHelper

	def sign_in(user)
		session[:remember_token] = user.id
		self.current_user = user
	end

	def current_user=(user)
    	@current_user = user
  	end

	def current_user
	    @current_user ||= user_from_remember_token
	end
	
  	def signed_in?
		!current_user.nil?
	end

	def sign_out
	    session[:remember_token] = nil
	    self.current_user = nil
	end

	def deny_access
    	redirect_to signin_path, :notice => "Merci de vous identifier pour rejoindre cette page."
  	end

  	private

    def user_from_remember_token
    	self.current_user = User.authenticate_with_id(remember_token)
    end

    def remember_token
     	session[:remember_token]
    end
end

class User < MyActiveResource
	self.site = "https://api.storageroomapp.com/accounts/4ff6ebed1b338a6ace001893/collections/"
	self.element_name = "4ff6f9851b338a3e72000c64/entries"

	def has_password?(submitted_password)
    	password == submitted_password
  	end

	def self.authenticate(email, submitted_password)
	    user = my_find(:first, :params => {:email => email})
	    return nil  if user.nil?
	    return user if user.has_password?(submitted_password)
  	end

  	def is_admin?
  		# TODO
  		return (email == "test2@gmail.com")
  	end

  	def self.authenticate_with_id(id)
	    id ? user = find(id) : nil
	end

	def get_shops
		# @shops = Shop.find(:all, :params => { "beancode!gt" => 0, "app_user.url" => m_url}) if @shops.nil?
		# TODO : for debug we get all shops
		@shops = Shop.my_find(:all, :params => { "beancode!gt" => 0, "name!match" => "/carrefour market*/i"}) if @shops.nil?
		return @shops
	end

end
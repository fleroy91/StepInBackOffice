
class User < ActiveResource::Base
	include ActiveResource::Extend::AuthWithApi
	self.site = "https://api.storageroomapp.com/accounts/4ff6ebed1b338a6ace001893/collections/"
	self.element_name = "4ff6f9851b338a3e72000c64/entries"
	# self.format = UserJSONFormater.new
	self.api_key = "mh1iJru6ydVsDxRCoWjV"

	def initialize(*args)
	  super
	  puts "Creation d'un user : " + args[0].inspect
	end

	def has_password?(submitted_password)
    	password == submitted_password
  	end

  	def id
  		ids = m_url.split('/')
  		id = ids[ids.size-1]
  		return id
  	end

  	def as_json(options)
    	ret = super(options)
    	entry = {}
    	ret.each { |key,val|
    		entry[:entry] = val
		}
    	puts "as JSON de user = " + entry.inspect
    	entry
  	end

	def self.authenticate(email, submitted_password)
	    user = find(:first, :params => {:email => email})
	    return nil  if user.nil?
	    return user if user.has_password?(submitted_password)
  	end

  	def self.authenticate_with_id(id)
	    id ? user = find(id) : nil
	end

end
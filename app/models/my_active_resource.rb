class MyActiveResource < ActiveResource::Base
	include ActiveResource::Extend::AuthWithApi

  	def self.getId(url)
  		id = nil
  		if url then
	  		ids = url.split('/')
	  		id = ids[ids.size-1]
	  	end
  		return id
  	end

  	def id
  		return MyActiveResource.getId(m_url)
  	end

  	def as_json(options)
    	ret = super(options)
    	entry = {}
    	ret.each { |key,val|
    		entry[:entry] = val
		}
    	entry
  	end

end
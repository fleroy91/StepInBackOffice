class MyActiveResource < ActiveResource::Base
	include ActiveResource::Extend::AuthWithApi

    TTL_TIME = 2*60

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

  	def as_json(options = nil)
    	ret = super(options)
      if ! options || ! options[:no_entry] then
      	entry = {}
        if ret then
        	ret.each { |key,val|
        		entry[:entry] = val
    		  }
        end
    	  ret = entry
      end
      return ret
  	end

    def find(*arguments)
      # We try to look first in redis
      res = $redis.get(arguments.to_s)
      if res then
        logger.debug "Using cache key : #{arguments.to_s} = #{res}"
        res = JSON.parse(res)
        if res.kind_of? Array then
          ret = []
          res.each { |elem|
            ret.push(self.Class.new(elem))
          }
        else
          ret = self.Class.new(res)
        end
      else
        ret = super.find(what, options)
        val_to_store = ret.to_json({:no_entry => true})
        $redis.setex(arguments.to_s, TTL_TIME, val_to_store)
        logger.debug "Storing cache key : #{arguments.to_s} = #{val_to_store.to_s}"
      end
      return ret
    end

end
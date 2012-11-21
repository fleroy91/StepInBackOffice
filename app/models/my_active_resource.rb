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
      # logger.debug "Options for to_json = #{self.class} #{options.inspect} #{ret.inspect}"
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

    def self.my_find(*arguments)
      # We try to look first in redis
      key = self.name + '_' + arguments.to_s
      res = $redis.get(key)
      # logger.debug "Calling Redis first on #{arguments.to_s} : #{res.inspect}"
      if res then
        logger.debug "Using cache key : #{arguments.to_s}"
        res = JSON.parse(res)
        if res.kind_of? Array then
          ret = []
          res.each { |elem|
            elem.each { |k,v|
              # logger.debug("Elem = #{k.capitalize.constantize.inspect}")
              ret.push(k.capitalize.constantize.new(v))
            }
          }
        else
          res.each { |k,v|
            ret = k.capitalize.constantize.new(v)
        }
        end
      else
        ret = self.find(*arguments)
        val_to_store = ret.to_json(:no_entry => true)
        $redis.setex(key, TTL_TIME, val_to_store)
        logger.debug "Storing cache key : #{key}"
      end
      return ret
    end

end
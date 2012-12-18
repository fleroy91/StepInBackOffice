# encoding: utf-8
class ApplicationController < ActionController::Base
	protect_from_forgery
	include SessionsHelper
	include UsersHelper
	include ShopsHelper
	include RewardsHelper


	@navigation = {
		:home => { 
			:title => "Synthèse",
			:side => [ { :title => ""}]
		 },
		:stats => { 
			:title => "Statistiques",
			:sides => [
				:title => "Vues", 
				:actions => [
					{ :title => "Par heure", :action => :hour_view },
					{ :title => "Par jour", :action => :day_view },
					{ :title => "Par semaine", :action => :week_view },
					{ :title => "Par mois", :action => :month_view }
					]
			]
		}
	}
    def to_hash(obj)
      hash = {}; obj.attributes.each { |k,v| hash[k] = v }
      return hash
    end


	def get_rewards(id, from, to, filter)
	  ret = nil
	  userId = current_user.id
	  s_from = from.to_s(:db)[0..9]
	  s_to = to.to_s(:db)[0..9]
	  key = userId.to_s + '_' + id.to_s + '_' + s_from + '_' + s_to + '_rewards'

	  r_objs = $redis.get(key)

	  #logger.debug("Before")
	  #logger.debug("r_objs = #{r_objs.inspect}")

	  if r_objs.nil? then
	    # TODO : filter on user shops
	    filter[:per_page] = 1000
	    objs = []
	    current_user.get_shops().each { |shop|
	      filter['shop.url'] = shop.m_url
	      cont = true
	      page = 1
	      while cont do
	      	filter[:page] = page
			res = Reward.find(:all, :params => filter)
			if res.nil? || res.size == 0 then
				cont = false
			end
			objs.concat(res)
			page += 1
		  end
	      logger.debug "#{objs.size} rewards found for this shop #{shop.name.inspect}"
	    }
	    ret = objs

	    $redis.set(key, objs.to_json(:no_entry => true))
	
		#logger.debug("After")
		#logger.debug("r_objs = " + $redis.get(key+ '_objs').inspect)
	  else
	    arr = JSON.parse(r_objs)
	    ret = []
	    arr.each { |elem|
	      rew = Reward.new(elem["reward"])
	      if rew.shop && rew.shop.attributes[:entry] then
	      	rew.shop = Shop.new(to_hash(rew.shop.entry))
	      elsif rew.attributes[:scan] && rew.scan.attributes[:entry] then
	      	rew.scan = Scan.new(to_hash(rew.scan.entry))
	      end
	      ret.push(rew)
	    }
	  end
	  return ret
	end

protected
	def authenticate
		deny_access unless signed_in?
	end

end

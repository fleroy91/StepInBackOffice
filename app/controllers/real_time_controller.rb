# encoding : utf-8
class RealTimeController < ApplicationController
  def index
  	now = DateTime.now()
  end

  def update
  	filter = {:sort => 'when', :order => 'desc', :per_page => 1000}
  	if params[:from] then
  		# logger.debug "From = #{params[:from].inspect}"
  		from = DateTime.parse(params[:from])
  		# logger.debug "From = #{from.inspect}"
  		# from = from.to_time.advance(:hours => -1)
  		# logger.debug "From = #{from.inspect}"
  		filter['when!gt'] = from.to_s
  	end

  	rewards = Reward.my_find(:all, :params => filter)
  	if rewards then
      data = []
  		rewards.each { |rew|
  			#logger.debug "rew = #{rew.inspect}"
  			if rew.shop then
	  			url = rew.shop.url
	  			# logger.debug "url = #{rew.shop.url}"
				shop = findShop(MyActiveResource.getId(url))
				rew.shop = shop if shop

        if rew.catalog then
          logger.debug "Rew.catalog = #{rew.catalog.inspect}"
          rew.catalog = findCatalog(rew.catalog)
          logger.debug "After Rew.catalog = #{rew.catalog.inspect}"
        end

				if rew.code then
					rew.scan = findScan(rew.code)
				end
				if rew.user then
					if rew.user.attributes[:entry] then
						id = MyActiveResource.getId(rew.user.entry.url)
					else
						id = MyActiveResource.getId(rew.user.url)
					end
					# logger.debug "Rew.user = #{rew.user.inspect} #{id.inspect}"
					user = findUser(id)
					if user then
						# logger.debug "Found !"
						rew.user = user
					else
						logger.debug "Not found !"
					end
				end
			end
			data.push(rew)
		}
      rewards = data
  	end
  	logger.debug "#{rewards.size} rewards trouvés !"
  	if ! params[:from] then
  		rewards.slice!(20, rewards.size - 20)
  	end
  	logger.debug "#{rewards.size} rewards réduits !"
  	render :json => rewards.as_json(:no_entry => true)
  end
end

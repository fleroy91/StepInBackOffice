module ShopsHelper
	@allShops = nil

	def findShop(id)
		logger.debug "Find shop : " + id.inspect + " - " + @allShops.size.inspect
		@allShops.each { |shop| 
			return shop if shop.id == id
		}
		return nil
	end

	def refreshShops
		@allShops = nil
	end


	def shop_thumbnail(small_shop)
		ret = content_tag(:ul, "Inconnu")
		if small_shop then
			puts "Small shop = " + small_shop.inspect
			if @allShops.nil? then
				logger.debug "*** Relecture de tous les shops"
				@allShops = Shop.find(:all, :params => {:per_page => 1000})
			end
			url = small_shop.url
			shop = findShop(MyActiveResource.getId(url))
			if shop then
				content = content_tag(:li, image_tag((shop.photo0 && shop.photo0.m_url) || "broken.png"), 
					:class => "span2")
				content << content_tag(:li, shop.name.to_s + " - " + shop.city.to_s, :style => "padding:2px", :class => "span2")
				ret = link_to(shop_path(shop)) do
					content_tag(:ul, content, :class => "thumbnails")
				end
			end
		end
		return ret
	end
end

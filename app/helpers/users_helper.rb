module UsersHelper
	@allUsers = nil

	def findUser(id)
		if @allUsers.nil? then
			@allUsers = User.my_find(:all, :params => {:per_page => 1000})
		end
		#logger.debug "Find User : " + id.inspect + '-' + @allUsers.size.inspect
		@allUsers.each { |user|
			return user if user.id == id
		}
		return nil
	end

	def refreshUsers
		@allUsers = nil
	end

	def user_thumbnail(small_user)
		ret = content_tag(:ul, "Inconnu")
		if small_user then
			url = small_user.url
			user = findUser(MyActiveResource.getId(url))
			if user then
				content = content_tag(:li, image_tag((user.photo0 && user.photo0.m_url) || "silhouette.png"), 
					:class => "span2")
				content << content_tag(:li, user.firstname.to_s + " - " + user.email.to_s, :style => "padding:2px", :class => "span2")
				ret = link_to(user_path(user)) do
					content_tag(:ul, content, :class => "thumbnails")
				end
			end
		end
		return ret
	end
end

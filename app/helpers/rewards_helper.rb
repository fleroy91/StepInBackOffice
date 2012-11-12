module RewardsHelper
	@allScans = nil

	def findScan(code)
		logger.debug "*** Relecture de tous les scans"
		@allScans = Scan.find(:all, :params => { :per_page => 1000}) if @allScans.nil?

		@allScans.each { |scan|
			return scan if scan.code == code
		}
		return nil
	end

	def displayWhen(w)
		t = Time.parse(w)
		return t.strftime("%d/%m/%Y %H:%M")
	end

	def ak_thumbnail(action_kind, code)
		ret = action_kind
		if action_kind == "stepin" then
			content = content_tag(:li, image_tag("steps.png"), :class => "span1")
			content << content_tag(:li, "Step-In", :style => "padding:2px", :class => "span2")

			ret = content_tag(:ul, content, :class => "thumbnails")
		elsif action_kind == "scan" then
			scan = findScan(code)
			content = content_tag(:li, image_tag((scan.photo0 && scan.photo0.m_url) || "tag.png"), 
				:class => "span2")
			content << content_tag(:li, scan.title.to_s, :style => "padding:2px", :class => "span2")

			ret = content_tag(:ul, content, :class => "thumbnails")
		end
		return ret
	end
end

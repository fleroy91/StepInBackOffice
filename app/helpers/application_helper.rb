module ApplicationHelper
	def titre
		base_titre = "Step-In : Back Office"
    	if @titre.nil?
      		return base_titre
    	else
      		return "#{base_titre} | #{@titre}"
 	   	end
	end


	def active_link_to(controller, name)
		content_tag(:li, link_to(name, url_for(:controller => controller)), :class => (current_page?(:controller => controller) ? "active" : "") )
	end
end

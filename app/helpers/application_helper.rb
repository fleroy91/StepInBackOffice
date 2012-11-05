module ApplicationHelper
	def titre
		base_titre = "Step-In : Back Office"
    	if @titre.nil?
      		return base_titre
    	else
      		return "#{base_titre} | #{@titre}"
 	   	end
	end
end

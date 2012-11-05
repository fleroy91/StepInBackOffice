
class Shop < MyActiveResource
	self.site = "https://api.storageroomapp.com/accounts/4ff6ebed1b338a6ace001893/collections/"
	self.element_name = "4ff6ed1e1b338a5c1e000094/entries"

	def initialize(*args)
	  super
	  puts "Creation d'un shop : " + args[0].inspect
	end
end
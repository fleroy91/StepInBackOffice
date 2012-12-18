
class Shop < MyActiveResource
	self.site = "https://api.storageroomapp.com/accounts/4ff6ebed1b338a6ace001893/collections/"
	self.element_name = (MyActiveResource.USE_FAKE_TABLES ? "50d0370d0f6602544100045c/entries" : "4ff6ed1e1b338a5c1e000094/entries")

end
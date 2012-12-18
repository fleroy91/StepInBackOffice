
class Catalog < MyActiveResource
	self.site = "https://api.storageroomapp.com/accounts/4ff6ebed1b338a6ace001893/collections/"
	self.element_name = (MyActiveResource.USE_FAKE_TABLES ? "50d037420f660254410004d5/entries" : "50c209ae0f66022ef800062d/entries")
end
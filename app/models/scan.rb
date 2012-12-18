
class Scan < MyActiveResource
	self.site = "https://api.storageroomapp.com/accounts/4ff6ebed1b338a6ace001893/collections/"
	self.element_name =  (MyActiveResource.USE_FAKE_TABLES ? "50d037240f6602647600050e/entries" : "506eec600f660214ae00013a/entries")
end
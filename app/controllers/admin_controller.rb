# encoding : utf-8
class AdminController < ApplicationController
	before_filter :authenticate

	def index
		@data_kind = "users"
		if params[:admin] then
			@data_kind = params[:admin][:data_kind] if params[:admin][:data_kind]
		end
		@subview = "#{@data_kind}/index"

		@users = User.all
	end

	def populate_users
		# We need first to generate users
		response = HTTParty.get('https://api.viadeo.com/me/contacts.json?access_token=2c81108a48dacdbe2d66e25b2a56e460&user_detail=partial&has_photo=true&limit=30')
		#logger.debug response.body
		ret = JSON.parse(response.body)
		#logger.debug ret.inspect
		users = ret["data"]
		nb_users = 0
		nb_errors = 0

		users.each { |vuser|
			response = HTTParty.get(vuser["picture_large"])

			user = User.new({
				:m_type => "AppUser",
				:email => vuser["id"] + "@fake.com",
				:password => "1234",
				:is_user => true,
				:firstname => vuser["name"]
				})
			user.photo0 = {
				:content_type => "image/jpeg",
				:filename => "post.png",
				:data => Base64.encode64(response.body)
			}
			if user.save then
				nb_users += 1
			else
				nb_errors += 1
			end
		}

		flash[:notice] = "#{nb_users} utilisateurs ont été ajoutés à la BD avec #{nb_errors} erreurs !"
		redirect_to :action => :index
	end

	def populate_visits_scans
		fake_users = User.my_find(:all, :params => { :per_page => 30, 'email!match' => "/fake.com/"})
		logger.debug "#{fake_users.size} fake users find !"
		shops = Shop.my_find(:all, :params => { 'beancode!gt' => 0})

		nb_visits = 0
		nb_scans = 0
		nb_errors = 0

		shops.each { |shop|
			shop.scans = Scan.my_find(:all, :params => { 'shop.url' => shop.m_url})
		}

		now = DateTime.now.to_date

		# for each day, how many purcentage users and visits per user
		visits_per_day = { 1 => [30, 3], 2 => [25, 2], 3 => [25, 2], 4 => [25, 2], 5 => [40, 3], 6 => [80, 6], 7 => [60, 5]}
		scans_per_visit = 3

		from = now.to_time.advance(:days => -10).to_date
		logger.debug "From : #{from.inspect}"

		while from <= now do
			ratio_user = visits_per_day[from.wday + 1][0]
			visit_per_day = visits_per_day[from.wday + 1][1]

			#logger.debug "From : #{from.inspect} - #{ratio_user} - #{visit_per_day}"
			users = selectRandom(fake_users, 1 + fake_users.size * ratio_user / 100)
			users.each { |user|
				shops_visited = selectRandom(shops, visit_per_day)
				shops_visited.each { |shop|
					# We select an hour
					dwhen = from.to_time.advance(:minutes => (9*60 + Random.rand(10*60)))

					rew = Reward.new({:when => dwhen.to_s, :nb_points => shop.points.stepin, :action_kind => 'stepin'})
					rew.shop = {:m_type => 'Shop', :url => shop.m_url}
					rew.user = {:m_type => 'AppUser', :url => user.m_url}

					logger.debug "Stepin : #{rew.inspect}"
					if rew.save then
					# if true then
						nb_visits += 1
					else
						nb_errors += 1
					end

					scans = selectRandom(shop.scans, Random.rand(scans_per_visit))
					scans.each { |scan|
						swhen = dwhen.to_time.advance(:minutes => Random.rand(60))

						rew = Reward.new({:when => swhen.to_s, :nb_points => scan.points, :action_kind => 'scan', :code => scan.code})
						rew.shop = {:m_type => 'Shop', :url => shop.m_url}
						rew.user = {:m_type => 'AppUser', :url => user.m_url}

						logger.debug "Scan : #{rew.inspect}"
						if rew.save then
						# if true then
							nb_scans += 1
						else
							nb_errors += 1
						end
					}
				}
			}

			from = from.to_time.advance(:days => 1).to_date
		end
		flash[:notice] = "#{nb_visits} visites et #{nb_scans} scans ont été ajoutés à la BDavec #{nb_errors} erreurs"
		redirect_to :action => :index
	end

	def populate_db_from_fs
		@beancode = 4
		dir = "/Users/viaduc143/Documents/Titanium_Studio_Workspace/PopulateDB"
		Dir.chdir(dir)

		Dir.glob("*") { |dshop|
		 	populate_db_from_dir(File.join(dir, dshop))
		}
		render :text => "Done ! Check log"
	end

	def call_google(gmapsReq, gmapsOptions)
        req = gmapsReq + "?"
        first = true
        gmapsOptions.each { |k,v|
        	req += "&" unless first
        	first = false
        	req += URI.escape("#{k}=#{v}")
        }
        logger.debug("GET #{req.to_s}")
		response = HTTParty.get(req)
		#logger.debug response.body
		ret = JSON.parse(response.body)
	end

	def get_photo_hash(f) 
		# We read the logo and get it into a base64 string
		blob64 = nil
		File.open(f) { |file|
			blob64 = Base64.encode64(file.read)
			#logger.debug "Logo encoded : #{blob64.inspect}"
		}
		ext = File.extname(f)
		ext = ext[1..ext.size]
		ret = {
			:content_type => "image/#{ext.to_s}",
			:filename => f.to_s,
			:data => blob64
		}
		return ret
	end	

	def find_in_address(address, element)
		address.each { |elem|
			elem["types"].each { |type| 
				if type == element then
					return elem["long_name"]
				end
			}
		}
		return nil
	end

	def get_points_hash
		return { "stepin" => 50 + Random.rand(5) * 25,
			"catalog" => 25}
	end

	def find_logo(dir) 
		flogo = nil
		Dir.glob(File.join(dir, "logo.*"), File::FNM_CASEFOLD) { |file|
			logger.debug "File = #{file}"
			filename = File.basename(file)
			if filename.match(/^logo/i) then
				flogo = file
				break
			end
		}
		return flogo
	end

	def populate_db_from_dir(dshop)
		logger.debug "Dir for shop : #{dshop.inspect}"
		shop_name = File.basename(dshop)
		flogo = find_logo(dshop)

		# We call Google to get all the shops around with the name of the 
        gmapsReq = "https://maps.googleapis.com/maps/api/place/nearbysearch/json";
        gmapsOptions = { 
        	:rankby => :distance,
        	#:radius => 50000,
            :types => 'grocery_or_supermarket',
            :sensor => false, #do we ask for using the current GPS location : NO !
            :key => 'AIzaSyAkB43SsAc4TGopk7WuvLEspVXrOqwhJbI',
            :location => '48.7333,2.2833', #location to be replaced
            :name => shop_name
        }


        ret = call_google(gmapsReq, gmapsOptions)

		shops = ret["results"]
		catalogs = []

		logger.debug "Google answer : #{shops.inspect}"

		nb_shops = 0
		# We create a shop for each answer
		shops.each { |gshop|
			nb_shops += 1
			# We call google to have some details
			ret = call_google("https://maps.googleapis.com/maps/api/place/details/json",
				{ :reference => gshop["reference"],
					:sensor => false,
            	:key => 'AIzaSyAkB43SsAc4TGopk7WuvLEspVXrOqwhJbI'
      		})

      		logger.debug "Google detailed answer : #{ret.inspect}"

      		details = ret["result"]
      		address = details["address_components"]

      		# We look for the shop first
      		shop = Shop.find(:first, :params => {:ident => gshop["id"]})
      		if shop then
      			# logger.debug "Shop found ! #{shop.attributes.inspect}"
      			shop.attributes[:beancode] = @beancode
      		else
				shop = Shop.new({
					:m_type => "Shopb",
					:ident => gshop["id"],
					:name => details["name"],
					:address => "#{find_in_address(address, 'street_number')} #{find_in_address(address, 'route')}",
					:zipcode => find_in_address(address, "postal_code"),
					:city => find_in_address(address, "locality"),
					:beancode => @beancode
				})
      		end
      		logger.debug "-- Gestiond de la boutique #{shop.address.inspect}"
      		points = get_points_hash
      		location = gshop["geometry"]["location"]
			shop.points = points
			shop.location = location
			shop.catalogs = []

			@beancode = @beancode + 1
			# logger.debug "Shop : #{shop.inspect}"
			shop.photo0 = get_photo_hash(flogo)
			if shop.save then
				# logger.debug "Just after save : #{shop.inspect}"
				# We need to reload it
				if nb_shops <= 1 then
					# We need to create the catalogs
					Dir.chdir(dshop)
					Dir.glob("*") { |cdir|
						cdir = File.join(dshop, cdir)
						cat_name = File.basename(cdir)
						if cdir != flogo then
							cname = "#{shop_name} #{cat_name}"
							catalog = Catalog.find(:first, :params => {:name => cname})
							clogo = find_logo(cdir)
							if catalog.nil? then
								catalog = Catalog.new({
									:name => cname,
									:kind => cat_name,
									:m_type => "Catalogb"
								})
								catalog.photo0 = get_photo_hash(clogo)
							end
							#logger.debug "Catalog : #{catalog.inspect}"
							if catalog.save then
					      		logger.debug "---- Gestion du catalogue #{cname.inspect}"
								cata_url = catalog.m_url
								Dir.chdir(cdir)
								Dir.glob("*") { |fscan|
									fscan = File.join(cdir, fscan)
									scan_name = File.basename(fscan, File.extname(fscan))
									if fscan != clogo && File.extname(fscan) != ".docx" && File.extname(fscan) != ".txt" then

										fscan_txt = File.join(cdir, scan_name, ".txt")
										# description = get_description(fscan_txt)

										logger.debug "Scan file : #{fscan.inspect} - clogo : #{clogo.inspect}"

										scan = Scan.find(:first, :params => {:title => scan_name})
										if scan.nil? then
											scan = Scan.new({
												:title => scan_name,
												:m_type => "Scanb"
											})
										end
							      		logger.debug "------ Gestion du Scan #{scan_name.inspect}"
										logger.debug "*** Scan : #{scan.inspect}"
										scan.photo0 = get_photo_hash(fscan)
										scan.catalog = {:m_type => 'Catalogb', :url => cata_url}
										scan.save
									end
								}
								catalogs.push(
									{:m_type => 'Catalogb', :url => cata_url}
								)
							end
						end
					}
				end
				# We save the catalogs
				shop.attributes[:catalogs] = catalogs
				shop.points = points
				shop.location = location
				shop.save
			end
			if nb_shops == 3 then
				break
			end
		}
	end

	def selectRandom(arr, nb)
		l = arr.size

		nb = l if nb > l

		ret = []

		while nb > 0 do
			elem = arr[Random.rand(l)]
			if ! ret.index(elem) then
				ret.push(elem)
				nb -= 1
			end
		end
		#logger.debug "Select Randow : #{nb} #{l} #{ret.inspect}"
		return ret
	end

end

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

# encoding: utf-8
class StatsController < ApplicationController
	before_filter :authenticate

	def index
		# We should receive the values of the forms in params
		@xAxis = :hour
		@kind = :visits
		@chart_type = :column
		# We're looking for the date beginning of month
		@to = DateTime.now()
		@from = DateTime.new(@to.year, @to.month - 1, 1)

		if params[:stats] then
			@xAxis = params[:stats][:xAxis].to_sym if params[:stats][:xAxis]
			@kind = params[:stats][:kind].to_sym if params[:stats][:kind]
			@from = DateTime.parse(params[:stats][:from], 'dd/mm/yy') if params[:stats][:from]
			@to = DateTime.parse(params[:stats][:to], 'dd/mm/yy') if params[:stats][:to]
			@chart_type = params[:stats][:chart_type].to_sym if params[:stats][:chart_type]
		end

		logger.debug "From = #{@from.to_s} To = #{@to.to_s}"
		logger.debug "Kind = #{@kind.to_s}"
		logger.debug "Scale = #{@xAxis.to_s}"

	@chart = {
			chart: {
				renderTo: 'chart_container',
				type: @chart_type
			},
			title: {
				text: 'XXX'
			},
			subtitle: {
				text: 'YYYY'
			},
			xAxis: {
				categories: [
					'XXX',
					'XXX',
					'XXX',
					'XXX',
					'XXX'
				]
			},
			yAxis: {
				min: 0,
				title: {
					text: 'XXXX'
				}
			},
			legend: {
				layout: 'vertical',
				backgroundColor: '#FFFFFF',
				align: 'left',
				verticalAlign: 'top',
				x: 100,
				y: 70,
				floating: true,
				shadow: true
			},
			tooltip: {
				# formatter: function() {
				#     return ''+
				#         this.x +': '+ this.y +' mm';
				# }
			},
			plotOptions: {
				column: {
					pointPadding: 0.2,
					borderWidth: 0
				}
			},
			series: [{
				name: 'XXX',
				data: [0, 1, 2]
			}]
		}
	@data = get_data()

	logger.debug "Chart = #{@chart.inspect}"

	# For JS parameters passing
	gon.chart = @chart

	end

private

	def get_data
		filter = {}

		# date
		filter['when!gte'] = @from.to_s
		filter['when!lte'] = @to.to_s

		# the title
		case (@kind)
		when :visits
			@chart[:title][:text] = "Visites"
			@chart[:yAxis][:title][:text] = "Nb visites"
			filter[:action_kind] = 'stepin'
			incr = 1
		when :scans
			@chart[:title][:text] = "Scans"
			filter[:action_kind] = 'scan'
			@chart[:yAxis][:title][:text] = "Nb scans"
			incr = 1
		when :points
			@chart[:title][:text] = "Points donnés"
			@chart[:yAxis][:title][:text] = "Somme des points"
			incr = :nb_points
			# no filter
		end

		logger.debug "Chart title : #{@chart[:title][:text]}"

		# The xAxis
		case (@xAxis)
		when :hour
			@chart[:xAxis][:categories] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
			@chart[:subtitle][:text] = "Moyenne par heure"
		when :day
			@chart[:xAxis][:categories] = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31]
			@chart[:subtitle][:text] = "Moyenne par jour"
		when :week
			@chart[:xAxis][:categories] = [:lundi,:mardi,:mercredi,:jeudi,:vendredi,:samedi,:dimanche]
			@chart[:subtitle][:text] = "Moyenne par jour de la semaine"
		when :month
			@chart[:xAxis][:categories] = [:Janvier,:Fevrier,:Mars,:Avril,:Mai,:Juin,:Juillet,:Août,:Septembre,:Octobre,:Novembre,:Décembre]
			@chart[:subtitle][:text] = "Moyenne par mois"
		end

		logger.debug "Chart subtitle : #{@chart[:subtitle][:text]}"

		# We get back the objects limited to the shops
		objs = get_objects(filter)

		generate_series(objs, @xAxis, incr)

	end

	def authenticate
		deny_access unless signed_in?
	end

	def generate_series(objs, key, incr)
		@chart[:series] = []
		current_user.get_shops().each { |shop|
			generate_serie(shop, objs, key, incr)
		}
	end

	def generate_serie(shop, objs, key, incr)
		serie = []
		@chart[:xAxis][:categories].each { |cat_val|
			sum = 0
			objs.each { |obj|
				if obj.shop.url == shop.m_url then
					w = DateTime.parse(obj.when)
					case key
					when :hour
						val = w.hour
					when :day
						val = w.day
					when :week
						val = w.cwday
					when :month
						val = w.month
					end

					if val == cat_val then
						if incr.kind_of? Fixnum then
							sum += incr
						else
							sum += obj.attributes[incr] || 0
						end
					end
				end
			}
			serie.push(sum)
		}
		logger.debug "Serie pour #{shop.name} : #{serie.inspect}"
		@chart[:series].push({:name => shop.name, :data => serie })
	end

	def get_objects(filter)
		# TODO : filter on user shops
		filter[:per_page] = 1000
		objs = []
		current_user.get_shops().each { |shop|
			filter['shop.url'] = shop.m_url
			logger.debug "Current shop : #{shop.name.inspect} + #{@from.to_s}"
			res = Reward.find(:all, :params => filter)
			logger.debug "#{res.size} rewards found for this shop #{shop.name.inspect}"
			objs.concat(res)
		}
		return objs
	end
end

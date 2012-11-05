# encoding: utf-8
class ApplicationController < ActionController::Base
	protect_from_forgery
	include SessionsHelper
	include UsersHelper
	include ShopsHelper
	include RewardsHelper


	@navigation = {
		:home => { 
			:title => "Synthèse",
			:side => [ { :title => ""}]
		 },
		:stats => { 
			:title => "Statistiques",
			:sides => [
				:title => "Vues", 
				:actions => [
					{ :title => "Par heure", :action => :hour_view },
					{ :title => "Par jour", :action => :day_view },
					{ :title => "Par semaine", :action => :week_view },
					{ :title => "Par mois", :action => :month_view }
					]
			]
		}
	}
end

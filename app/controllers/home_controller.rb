# encoding: utf-8
class HomeController < ApplicationController
  def index
  	if signed_in? then
  		@titre = "Synthèse"
  		render :action => synthesis
  	else
  		@titre = "Accueil"
  	end
  end

  def admin
  	@titre = "Administration"
  	redirect_to users_path
  end

  def real_time
  	@titre = ""
  end

  def stats
  	@titre = "Statistique"
  end

end

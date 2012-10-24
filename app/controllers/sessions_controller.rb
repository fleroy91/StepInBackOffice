class SessionsController < ApplicationController
	def new
		redirect_to :create
	end

	def create
		puts "Je suis dans Create de SessionsController"
		user = User.authenticate(params[:session][:email],
		                            params[:session][:password])
		if user.nil?
			puts "Erreur : pas de user"
		    # Crée un message d'erreur et rend le formulaire d'identification.
		    flash[:error] = "Combinaison Email/Mot de passe invalide."
      		redirect_to root_path
		else
		    # Authentifie l'utilisateur et redirige vers la page d'affichage.
		    sign_in user
			puts "User reconnu : " + user.inspect + " - " + signed_in?.inspect
      		redirect_to root_path
		end
  	end

	def destroy
		sign_out
		redirect_to root_path
	end
end

StepInBackOffice::Application.routes.draw do
  get "admin/index"
  get "admin/populate_users"
  get "admin/populate_visits_scans"
  get "admin/populate_db_from_fs"
  get "admin/clean_rewards"
  get "admin/flush_db"

  get "real_time/index"
  get "real_time/update"

  get "stats/index"
  get "stats/compute"

  get "home/compute"
  get "home/synthesis"

  get "home/init_mobile"
  post "home/compute_cache"
  post "home/invalidate_cache"

  match '/admin',     :to => 'home#admin'
  match '/stats',     :to => 'home#stats'
  match '/real_time', :to => 'home#real_time'

  resources :rewards
  resources :scans
  resources :shops
  resources :users
  resources :sessions, :only => [:new, :create, :destroy]

  match '/signnew', :to => 'sessions#new'
  match '/signin', :to => 'sessions#create'
  match '/signout', :to => 'sessions#destroy'
  
  root :to => 'home#index'
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end

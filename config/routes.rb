ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  map.search 'search/:query/:page', :controller => 'pasokara', :action => 'search', :page => nil
  map.tag_search 'tag_search/:tag/:page', :controller => 'pasokara', :action => 'tag_search', :page => nil
  map.tag_remove 'tag_remove/:id/:tag', :controller => 'pasokara', :action => 'remove_tag'
  map.tagging 'tagging/:id', :controller => 'pasokara', :action => 'tagging'
  map.tag_form_open 'tag_form_open/:id', :controller => 'pasokara', :action => 'open_tag_form'
  map.tag_form_close 'tag_form_close/:id', :controller => 'pasokara', :action => 'close_tag_form'
  map.all_tag 'all_tag', :controller => 'pasokara', :action => 'all_tag'

  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller
  
  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "dir"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id/:page'
  map.connect ':controller/:action/:id/:page.:format'
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end

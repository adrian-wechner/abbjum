Rails.application.routes.draw do
  resources :products do
    get :spreadsheet, on: :collection
    patch :update_products_xls, on: :collection
  end

  devise_for :users
  resources :checklist_records

  resources :checklists do
    resources :checklist_items
    patch :updateOrdernums, on: :member
  end

  get 'tracking/index'
  get 'tracking/part'
  get 'tracking', to: "tracking#index"
  
  get 'abb/index'
  get 'abb/project'
  get 'abb/select'
  get 'abb', to: "abb#index"
  
  resources :lines do 
    resources :stations
    get :instructions, on: :member
    patch :update_instructions, on: :member
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # The way to request and set "model" for given line
  get 'lines(/:id)/model(/:station)(/:newmodel)(.:format)', to: 'lines#model'

  # Defines the root path route ("/")
  root "abb#index"
end

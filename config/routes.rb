Rails.application.routes.draw do
  devise_for :users
  resources :checklist_records
  resources :checklist_items
  resources :checklists
  get 'tracking/index'
  get 'tracking/part'
  get 'tracking', to: "tracking#index"
  
  get 'abb/index'
  get 'abb/project'
  get 'abb/select'
  get 'abb', to: "abb#index"
  
  resources :lines do 
    resources :stations
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # The way to request and set "model" for given line
  get 'lines(/:id)/model(/:station)(/:newmodel)(.:format)', to: 'lines#model'

  # Defines the root path route ("/")
  root "abb#index"
end

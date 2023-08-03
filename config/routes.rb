Rails.application.routes.draw do
  
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

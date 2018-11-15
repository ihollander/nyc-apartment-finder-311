Rails.application.routes.draw do


  get 'register', to: 'users#new', as: 'register'
  post 'register', to: 'users#create'
  get 'profile', to: 'users#show', as: 'profile'
  delete 'profile', to: 'users#destroy'
  get 'profile/edit', to: 'users#edit', as: 'edit_profile'
  patch 'profile/edit', to: 'users#update'
  get 'profile/apartments', to: 'users#apartments', as: 'user_apartments'
  post 'profile/apartments', to: 'users#add_apartment'

  root to: 'sessions#welcome'
  get '/login', to: 'sessions#new', as: 'login'
  post '/login', to: 'sessions#create'
  delete '/logout', to: 'sessions#destroy', as: 'logout'
  
  resources :apartments
  resources :neighborhoods, only: %i[index] do
    collection do
      get 'search'
      get 'result'
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

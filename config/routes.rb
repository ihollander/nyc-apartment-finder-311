Rails.application.routes.draw do


  get 'register', to: 'users#new', as: 'register'
  post 'register', to: 'users#create'
  get 'profile', to: 'users#show', as: 'profile'
  delete 'profile', to: 'users#destroy'
  get 'profile/edit', to: 'users#edit', as: 'edit_profile'
  patch 'profile/edit', to: 'users#update'

  root to: 'sessions#new'
  post '/login', to: 'sessions#create', as: 'login'
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

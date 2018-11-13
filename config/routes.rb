Rails.application.routes.draw do

  resources :apartments
  resources :incidents, only: %i[index] do
    collection do
      get 'search'
      get 'result'
    end
  end
  resources :users
  resources :maps
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

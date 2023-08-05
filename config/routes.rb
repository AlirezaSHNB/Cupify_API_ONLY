Rails.application.routes.draw do
  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }
  root 'home#index'

  post '/check_username_availability', to: 'users#check_username_availability'


  resources :cups do
    resources :leagues do
      resources :matches do
        resources :rounds do
          resources :scores
          resources :fouls
        end
      end
    end
    resources :knockouts do
      resources :matches do
        resources :rounds do
          resources :scores
          resources :fouls
        end
      end
    end
  end
  resources :participants
  resources :players do
    get 'search_by_name', on: :collection
  end
end
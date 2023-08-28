Rails.application.routes.draw do
  root 'home#index'

  devise_for :users, path: '', path_names: {
    sign_in: 'login',
    sign_out: 'logout',
    registration: 'signup'
  },
  controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  get '/get_current_user', to: "users#get_current_user"
  post '/check_username_availability', to: 'users#check_username_availability'

  # devise_scope :user do
  #   get   "/check_session_timeout"    => "session_timeout#check_session_timeout"
  #   get   "/session_timeout"          => "session_timeout#render_timeout"
  # end

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
  resources :participants do
    get 'single_player_teams', on: :collection
    get 'multiple_player_teams', on: :collection
  end
  resources :players do
    get 'search_by_name', on: :collection
  end

end
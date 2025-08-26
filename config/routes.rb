Rails.application.routes.draw do
  
  scope "(:locale)", locale: /en|vi/ do
    # Trang chủ
    root to: "static_pages#home"
    devise_for :users, only: [:sessions, :registrations, :passwords, :confirmations],
      path: "",
      path_names: { sign_in: "login", sign_out: "logout", sign_up: "signup" }

    # Static pages
    get "/static_pages/home", to: "static_pages#home", as: "home"

    # user and nested resources
    resources :users, only: %i(show edit update) do
      resources :bookings, only: %i(index) do
        member do
          patch :cancel
        end
      end
      resources :requests do
        member do
          patch :cancel
        end
      end
      resources :reviews, only: %i(index destroy create)
      resource :password_user, only: %i(create edit update)
    end


    # Bài viết (Microposts)
    resources :microposts
    
    resources :rooms, only: %i(index show)

    # Admin routes
    namespace :admin do
      root to: "dashboard#index"
      get "/dashboard", to: "dashboard#index", as: "dashboard"

      resources :room_types, only: %i(index new edit create update destroy)
      resources :room_availabilities, only: %i(index edit update)
      resources :bookings, only: %i(index show update) do
        member do
          patch :update_status
          patch :decline
          get :show_decline
        end
        resources :requests, only: %i(show update) do
          resources :guests, only: %i(new create edit update destroy)
        end
      end
      resources :rooms, only: %i(index new edit create update show destroy) do
        member do
          delete :remove_image
        end
      end
      resources :amenities, only: %i(index new edit create update destroy)
      resources :users, only: %i(index show)
      resources :reviews, only: %i(index show update)
    end

    # Phòng
    resources :rooms, only: %i(index show) do
      resources :bookings, only: %i(update)
      member do
        get :calculate_price
      end
    end

    resources :bookings, only: %i(index destroy) do
      collection do
        get :current_booking
      end
      member do
        patch :confirm_booking
      end
    end

    resources :requests, only: %i(destroy)
  end
end

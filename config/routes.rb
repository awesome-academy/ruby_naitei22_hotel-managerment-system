Rails.application.routes.draw do
  scope "(:locale)", locale: /en|vi/ do
    # Trang chủ
    root to: "static_pages#home"

    # Static pages
    get "/static_pages/home", to: "static_pages#home", as: "home"

    # Đăng ký (Sign up)
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"
    put "/users/:id", to: "users#edit"

    # Đăng nhập/Đăng xuất (Login/Logout)
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    # Kích hoạt tài khoản (Account Activations)
    resources :account_activations, only: :edit

    # user and nested resources
    resources :users, only: %i(new create show edit update) do
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
      resource :password, only: %i(create edit update)
    end


    # Bài viết (Microposts)
    resources :microposts
    
    resources :rooms, only: %i(index show)

    # Reset mật khẩu (Password Resets)
    resources :password_resets, only: %i(new create edit update)

    # Admin routes
    namespace :admin do
      root to: "dashboard#index"
      get "/dashboard", to: "dashboard#index", as: "dashboard"

      resources :room_types, only: %i(index new edit create update destroy)
      resources :room_availabilities, only: :index
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
      resources :rooms, only: %i(new edit create update) do
        member do
          delete :remove_image
        end
      end
      resources :amenities, only: %i(index new edit create update destroy)
    end
    
    # Phòng
    resources :rooms, only: %i(index show) do
      resources :bookings, only: %i(update)
      member do
        get :calculate_price
      end
    end 

    resources :bookings, only: %i(index)
  end
end

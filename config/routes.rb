Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
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

    # Người dùng (Users)
    resources :users, only: %i(new create show edit)

    # Bài viết (Microposts)
    resources :microposts

    # Admin routes
    namespace :admin do
      root to: "dashboard#index"
      get "/dashboard", to: "dashboard#index", as: "dashboard"

      resources :room_types, only: %i(index new edit create update destroy)
      resources :bookings, only: :index
      resources :room_availabilities, only: :index
    end
    
    # Phòng
    resources :rooms, only: %i(index)
  end
  # Defines the root path route ("/")
  # root "articles#index"
end

Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  scope "(:locale)", locale: /en|vi/ do
    root to: "static_pages#home"

    # static pages
    get "/static_pages/home", to: "static_pages#home", as: "home"
    get "/static_pages/help", to: "static_pages#help", as: "help"
    get "/static_pages/contact", to: "static_pages#contact", as: "contact"

    # sign up
    get "/signup", to: "users#new"
    post "/signup", to: "users#create"

    # login / logout
    get "/login", to: "sessions#new"
    post "/login", to: "sessions#create"
    delete "/logout", to: "sessions#destroy"

    resources :users, only: :show

    resources :microposts
  end
  # Defines the r oot path route ("/")
  # root "articles#index"
end

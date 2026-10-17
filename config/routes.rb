Rails.application.routes.draw do
  get "/robots.txt",  to: "seo_files#robots", format: false
  get "/sitemap.xml", to: "seo_files#sitemap", defaults: { format: :xml }, format: false

  scope "(:locale)", locale: /en/ do
  root "static_pages#home"
  get  "/help",    to: "static_pages#help"
  get  "/about",   to: "static_pages#about"
  get  "/contact", to: "inquiries#new"
  get  "/privacy", to: "static_pages#privacy"
  get  "/terms",   to: "static_pages#terms"
  get  "/signup",  to: "users#new"

  # ユーザーログイン
  get    "/login",   to: "sessions#new"
  post   "/login",   to: "sessions#create"
  delete "/logout",  to: "sessions#destroy"

  resources :users, only:[:index, :new, :create, :show ,:edit ,:update, :destroy] 

  resources :account_activations, only: [:new, :create, :edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]

  
  resources :shops, only: [:index, :show] do
    resources :menu_items, only: [:new, :create, :edit, :update]
    resources :reviews, only: [:create, :destroy] do
      resource :review_reply, only: [:create]
      resource :reaction, only: [:create, :destroy], controller: "review_reactions"
    end
    
    resources :verifications, only: [:new, :create]
    
  end
  
  get "verifications/:verification_id/evidence_files/:id",
    to: "verification_evidence_files#show",
    as: :verification_evidence_file

  get "users/:user_id/avatar",
      to: "user_avatars#show",
      as: :user_avatar

  get "reviews/:review_id/images/:id",
      to: "review_images#show",
      as: :review_image
  
  
  # 店舗オーナー用ルート（修正版）
  resources :shop_owners, only: [:new, :create] do
    get :dashboard, on: :collection
  
    member do
      get :edit_shop
      patch :update_shop
    end
  end
  
  resources :shop_submissions, only: [:new, :create]
  
  resources :inquiries, only: [:new, :create]

  namespace :admin do
    resources :shop_submissions, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end
  
    resources :admin_audit_logs, only: [:index]

    resources :shops, only: [:index, :edit, :update] do
      member do
        patch :hide
        patch :unhide
      end
    end
    resources :reviews, only: [:index, :destroy]
    resources :menu_items, only: [:destroy]

  
    resources :inquiries, only: [:index, :show, :update]
  
    resources :shop_owners, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end
    
    resources :verifications, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end
    
    get "shop_owners/:shop_owner_id/business_license",
    to: "shop_owner_licenses#show",
    as: :shop_owner_business_license
    
  end
  end
end

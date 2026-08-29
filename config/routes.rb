Rails.application.routes.draw do
  root "static_pages#home"
  get  "/help",    to: "static_pages#help"
  get  "/about",   to: "static_pages#about"
  get  "/contact", to: "static_pages#contact"
  get  "/signup",  to: "users#new"

  # ユーザーログイン
  get    "/login",   to: "sessions#new"
  post   "/login",   to: "sessions#create"
  delete "/logout",  to: "sessions#destroy"

  resources :users, only:[:index, :new, :create, :show ,:edit ,:update, :destroy] 

  resources :account_activations, only: [:edit]
  resources :password_resets,     only: [:new, :create, :edit, :update]


  # ラーメン店舗とレビュー
  resources :shops do
    resources :reviews, only: [:create, :destroy]
    member do
      patch :verify   # /shops/:id/verify → 確認済みにする
    end
  end

  # 店舗オーナー用ルート（修正版）
  resources :shop_owners, only: [:new, :create] do
    get :dashboard, on: :collection
  end


  # 店舗オーナー用ログイン
  get    'shop_owner/login',  to: 'shop_sessions#new'
  post   'shop_owner/login',  to: 'shop_sessions#create'
  delete 'shop_owner/logout', to: 'shop_sessions#destroy'
end

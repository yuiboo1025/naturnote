Rails.application.routes.draw do
  # root to: 'homes#top'
  # get "/about" => "homes#about"

  devise_for :admin, skip: [:registrations, :passwords], controllers: {
    sessions: "admin/sessions"
  }

  devise_for :members, skip: [:passwords], controllers: {
    registrations: "public/registrations",
    sessions: "public/sessions"
  }

  namespace :admin do
    # get 'top' => 'homes#top', as: 'top'
    root "homes#top"
    get "wines/myindex/:id" => "wines#myindex", as: "wines_myindex"
    get "wines/again_index/:id" => "wines#again_index", as: "wines_again_index"
    get "wines/mymap/:id" => "wines#mymap", as: "wines_mymap"
    resources :members, only: [:index, :show, :edit, :update] do
      member do
        get :bookmarks, :followings, :followers, :followings_wine
      end
    end
    resources :genres, only: [:index, :edit, :create, :update, :destroy]
    resources :wines, only: [:index, :show, :edit, :update, :destroy] do
      resources :comments, only: [:destroy]
    end
    get "spots/spots_list" => "spots#spots_list"
    resources :spots, only: [:index, :show, :edit, :update, :destroy]
  end

  scope module: :public do
    root "homes#top"
    get "/about" => "homes#about"
    get "members/unsubscribe" => "members#unsubscribe", as: "confirm_unsubscribe"
    patch "members/withdraw" => "members#withdraw", as: "withdraw_members"
    resources :members, only: [:index, :show, :edit, :update] do
      resource :relationships, only: [:create, :destroy]
      # member doを使うと、ユーザーidが含まれてるurlを使えるようになる。
      member do
        get :bookmarks, :followings, :followers, :followings_wine
      end
    end
    get "wines/myindex/:id" => "wines#myindex", as: "wines_myindex"
    get "wines/again_index/:id" => "wines#again_index", as: "wines_again_index"
    get "wines/mymap/:id" => "wines#mymap", as: "wines_mymap"
    resources :wines, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      # 1人のメンバーは1つの投稿に対して1回しかいいねできないためいいねのidはURLに含める必要がない(params[:id]を使わなくても良い)
      resource :favorites, only: [:create, :destroy]
      resource :bookmarks, only: [:create, :destroy]
      resources :comments, only: [:create, :destroy]
    end
    resources :spots, only: [:index, :show, :create, :new, :edit, :update]
  end

  # ゲストログイン用
  devise_scope :member do
    post "members/guest_sign_in", to: "members/sessions#guest_sign_in"
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end

Rails.application.routes.draw do
  root to: 'schedules#index'
  
  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'
  
  get 'signup', to: 'users#new'
  
  resources :users, only: [:show, :new, :create, :edit, :update]
  resources :schedules do
    member do
      get :reactions
    end
  end
  resources :answers, only: [:new, :create, :destroy]
end

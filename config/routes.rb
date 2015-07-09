Rails.application.routes.draw do
  
  mount RedactorRails::Engine => '/redactor_rails'
  require 'api_v1'
  
  root 'home#index'
  
  devise_for :admins, skip: [:registrations], path: "auth", path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret'}, controllers: { sessions: "users/sessions" }
  
  as :admin do
    get 'account/password/edit' => 'devise/registrations#edit', as: :edit_admin_registration
    patch 'account/password/update'  => 'devise/registrations#update', as: :admin_registration
  end
  
  resources :users, only: [:index] do
    patch :block, on: :member
    patch :unblock, on: :member
  end
  
  resources :goals do
    get :search, on: :collection
  end
  resources :categories
  resources :comments, only: [:index, :destroy]
  # resources :banner, only: [:show]
  resources :feedbacks, only: [:index]
  resources :messages, only: [:index, :new, :create]
  resources :banners
  
  mount API::APIV1 => '/'
  
end

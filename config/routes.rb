Rails.application.routes.draw do
  
  require 'api_v1'
  
  root 'home#index'
  
  devise_for :admins, skip: [:registrations], path: "auth", path_names: { sign_in: 'login', sign_out: 'logout', password: 'secret'}, controllers: { sessions: "users/sessions" }
  
  as :admin do
    get 'admins/edit' => 'devise/registrations#edit', as: :edit_admin_registration
    patch 'admins/:id'  => 'devise/registrations#update', as: :admin_registration
  end
  
  resources :banner, only: [:show]
  
  mount API::APIV1 => '/'
  
end

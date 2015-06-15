Rails.application.routes.draw do
  
  require 'api_v1'
  
  resources :banner, only: [:show]
  
  mount API::APIV1 => '/'
  
end

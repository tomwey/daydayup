Rails.application.routes.draw do
  
  require 'api_v1'
  
  mount API::APIV1 => '/'
  
end

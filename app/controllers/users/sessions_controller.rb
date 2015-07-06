class Users::SessionsController < Devise::SessionsController
  layout 'login'
  prepend_before_filter :require_no_authentication, :only => [ :new, :create, :cancel ]
end
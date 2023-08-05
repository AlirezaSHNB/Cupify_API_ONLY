class ApplicationController < ActionController::API
    before_action :configure_permitted_parameters, if: :devise_controller?

    protected
    def configure_permitted_parameters
        devise_parameter_sanitizer.permit(:sign_up, keys: %i[username gender date_of_birth role])
        devise_parameter_sanitizer.permit(:account_update, keys: %i[username gender date_of_birth role])
    end
    # Make the current_user method available to views also, not just controllers:
    # helper_method :current_user

    # Define the current_user method:
    # def current_user
    #     # Look up the current user based on user_id in the session cookie:
    #     @current_user ||= User.find(session[:user_id]) if session[:user_id]
    # end

    # authroize method redirects user to login page if not logged in:
    # def authorize
    #     redirect_to login_path, alert: 'You must be logged in to access this page.' if current_user.nil?
    # end
end

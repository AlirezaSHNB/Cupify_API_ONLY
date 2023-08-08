class Users::SessionsController < Devise::SessionsController
  include RackSessionsFix
  respond_to :json

  private

  def respond_with(current_user, _opts = {})
    render json: {
        message: 'Logged in successfully.',
        data: { user: UserSerializer.new(current_user).serializable_hash[:data][:attributes] }
    }, status: :ok
  end

  def respond_to_on_destroy
    jwt_token = request.headers['Authorization']&.split(' ')&.last
    if jwt_token.present?
      jwt_payload = JWT.decode(jwt_token, ENV['secret_key']).first
      current_user = User.find(jwt_payload['sub'])
  
      if current_user
        render json: {
          message: 'Logged out successfully.'
        }, status: :ok
      else
        render json: {
          message: "Couldn't find an active session."
        }, status: :unauthorized
      end
    else
      render json: {
        message: "JWT token not present."
      }, status: :unprocessable_entity
    end
  end
  
  # before_action :configure_sign_in_params, only: [:create]

  # GET /resource/sign_in
  # def new
  #   super
  # end

  # POST /resource/sign_in
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  # def destroy
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_sign_in_params
  #   devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  # end
end

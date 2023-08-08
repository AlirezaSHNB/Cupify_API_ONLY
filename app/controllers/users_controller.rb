class UsersController < ApplicationController
    # protect_from_forgery with: :exception
    # before_action :authorize, only: [:dashboard, :show, :edit, :update, :destroy]
    before_action :authenticate_user!, except: [:get_current_user]

    def get_current_user
        jwt_payload = JWT.decode(request.headers['Authorization'].split(' ').last, ENV['secret_key']).first
        current_user = User.find(jwt_payload['sub'])
        render json: current_user.as_json(:except => [:jti]), status: :ok
    end

    def index
        @users = User.all

        render json: {users: @users.map { |user| user.as_json(:except => [:jti]) }}, status: :ok
    end

    def show
        @user = User.find(params[:id])

        render json: {user: @user.as_json(:except => [:jti])}, status: :ok
    end

    def edit
        @user = User.find(params[:id])

        render json: {user: @user.except(:jti)}
    end

    def update
        @user = User.find(params[:id])

        if @user.update(user_params)
            render json: {message: "User was successfully updated."}, status: :accepted
        else
            error_messages = ""
            if @user.errors.any?
                @user.errors.full_messages.each do |message|
                    error_messages << "#{message}\n"
                end
            end
            render json: {message: "Oops, couldn't update user. error :\n#{error_messages}"}, status: :bad_request
        end
    end

    def destroy
        @user = User.find(params[:id])
        if @user.present?
            @user.destroy        redirect_to users_url, notice: 'User was successfully destroyed.'
            render json: {user: @user, message: "User was successfully destroyed."}, status: :accepted
        else
            render json: {message: "Oops, couldn't destroy user."}, status: :bad_request
        end
    end

    def check_username_availability
        user = User.find_by(username: params[:username])
        render json: {available: user.nil?}
    end

    private

    def user_params
        parsed_params = params.require(:user).permit(:username, :email, :gender, :password, :password_confirmation)
        parsed_params[:date_of_birth] = Date.strptime(params[:user][:date_of_birth], "%m/%d/%Y")
        parsed_params
    end

end

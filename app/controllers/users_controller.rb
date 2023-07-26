class UsersController < ApplicationController
    # protect_from_forgery with: :exception
    # before_action :authorize, only: [:dashboard, :show, :edit, :update, :destroy]

    def index
        @users = User.all

        render json: {users: @users}
    end

    def show
        @user = User.find(params[:id])

        render json: {user: @user}
    end

    def new
        @user = User.new

        render json: {user: @user}
    end

    def create
        @user = User.new(user_params)
        @user.role = Role.find(1) # temporary admin
        @user.email.downcase!
        result = @user.save
        if result
            render json: {message: "Account created successfully!"}, status: :created
        else
            error_messages = ""
            if @user.errors.any?
                @user.errors.full_messages.each do |message|
                    error_messages << "#{message}\n"
                end
            end
            
            render json: {message: "Oops, couldn't create account.Please make sure you are using a valid email and password and try again.errors:\n#{error_messages}"}, status: :unprocessable_entity
        end
    end

    def edit
        @user = User.find(params[:id])

        render json: {user: @user}
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

    def dashboard
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

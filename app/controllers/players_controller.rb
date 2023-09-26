class PlayersController < ApplicationController

    # protect_from_forgery with: :exception
    # before_action :authorize

    def index
        @players = Player.all

        render json: {players: @players }
    end
    
    def show
        @player = Player.find(params[:id])

        render json: {player: @player}
    end

    def search
        @players = Player.where("username LIKE ?", "%#{params[:term]}%")
        render json: {players: @players}, status: :ok
    end
end

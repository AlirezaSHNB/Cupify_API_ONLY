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

    def search_by_name
        term = params[:term]
        if term.length < 3
            render json: {message: "enter at least 3 letter"}, status: 404
        else
            result = []
            Player.where("username LIKE ?", "%#{term}%").each do |player|
                result << {
                    id: player.id,
                    username: player.username,
                    first_name: player.first_name,
                    last_name: player.last_name,
                    nickname: player.nickname,
                    date_of_birth: player.date_of_birth
                }
            end
            render json: {result: result}, status: :ok
        end
    end
end

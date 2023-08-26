class HomeController < ApplicationController
    # protect_from_forgery with: :exception
    # before_action :authorize, only: [:show, :edit, :update, :destroy, :index]

    def index
        @cups = Cup.all.limit(10)
        @multiple_player_teams = Participant.multiple_players.limit(10)
        @single_player_teams = Participant.single_players.limit(10)
        @players = Player.all.limit(10)

        render json: {cups: @cups, multiple_player_teams: @multiple_player_teams,
            single_player_teams: @single_player_teams, players: @players }
    end
end

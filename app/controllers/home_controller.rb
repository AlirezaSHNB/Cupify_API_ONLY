class HomeController < ApplicationController
    # protect_from_forgery with: :exception
    # before_action :authorize, only: [:show, :edit, :update, :destroy, :index]

    def index
        @cups = Cup.all.limit(10)
        @teams = Participant.multiple_players.limit(10)
        @persons = Participant.single_players.limit(10)
        @players = Player.all.limit(10)

        render json: {cups: @cups, teams: @teams, persons: @persons, players: @players }
    end
end

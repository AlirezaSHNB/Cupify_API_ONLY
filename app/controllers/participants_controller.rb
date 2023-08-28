class ParticipantsController < ApplicationController

    def index
        @participants = Participant.all

        render json: {teams: @participants }
    end

    def show
        @team = Participant.find(params[:id])

        render json: {team: @team}
    end

    def single_player_teams
        @single_player_participants = Participant.single_players

        render json: {teams: @single_player_participants }
    end

    def multiple_player_teams
        @multiple_player_participants = Participant.multiple_players

        render json: {teams: @multiple_player_participants }
    end
end

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

    def search_by_cup
        cup = Cup.find(params[:cup_id])
        @teams = Participant.matched_participants_with_cup(cup, params[:term])
        render json: {teams: @teams}
    end

    def create
        byebug
        @team = Participant.new(name: params[:name], field: Participant.fields[params[:field]])
        result = @team.save

        if result
            params[:players].each do |player_id|
                @team.add_player(player_id)
            end
            render json: {message: "Participant created successfully!"}, status: :created
        else
            render json: {message: "Oops, couldn't create cup. error :\n#{@team.errors.full_messages}"}, status: :bad_request
        end
    end
end

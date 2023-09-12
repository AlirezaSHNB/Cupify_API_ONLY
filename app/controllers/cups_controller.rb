class CupsController < ApplicationController
    # protect_from_forgery with: :exception
    # before_action :authorize

    def index
        @cups = Cup.all
        @football_base_fields = ["futsal", "football", "individual_fifa23", "team_fifa23", "individual_pes23", "team_pes23"]

        render json: {cups: @cups.as_json(include: :winner), football_base_fields: @football_base_fields }
    end

    def show
        @cup = Cup.find(params[:id])
        @knockout = @cup.knockouts.first if ["knockout", "combination"].include?(@cup.mode)

        render json: {cup: @cup, knockout: @knockout }
    end

    def new
        @cup = Cup.new

        render json: {cup: @cup }
    end

    def create
        @cup = Cup.new(name: params[:name],
            start_date: Date.parse(params[:start_date]),
            end_date: Date.parse(params[:end_date]),
            field: Cup.fields[params[:field]],
            number_of_players: params[:number_of_players].to_i, state: 0,
            min_number_of_participants: params[:min_number_of_participants].to_i,
            max_number_of_participants: params[:max_number_of_participants].to_i,
            mode: Cup.modes[params[:type]])
        result = @cup.save

        if result
            create_league_and_knockout(params, @cup)
            render json: {message: "Cup created successfully!"}, status: :created
        else
            render_error(@cup)
        end
    end

    def edit
        @cup = Cup.find(params[:id])

        render json: {cup: @cup}
    end

    def update
        @cup = Cup.find(params[:id])

        if @cup.update(cup_params)
            render json: {cup: @cup, message: "Cup updated successfully!"}, status: :accepted
        else
            error_messages = ""
            if @cup.errors.any?
                @cup.errors.full_messages.each do |message|
                    error_messages << "#{message}\n"
                end
            end
            render json: {message: "Oops, couldn't update cup. error :\n#{error_messages}"}, status: :bad_request
        end
    end

    def destroy
        @cup = User.find(params[:id])
        if @cup.present?
            @cup.destroy
            render json: {cup: @cup, message: "Cup was successfully destroyed."}, status: :accepted
        else
            render json: {message: "Oops, couldn't destroy cup."}, status: :bad_request
        end
    end

    def search_existing_participants
        participants = Cup.where(number_of_players: self.number_of_players, field: self.field).participants
        term = params[:term]
        if term.length < 3
            render json: {message: "enter at least 3 letter"}, status: :unprocessable_entity
        else
            participants.where("name LIKE ?", "%#{term}%").each do |participant|
                result << {
                    id: participant.id,
                    name: participant.name
                }
            end
            render json: {result: result}, status: :ok
        end
    end

    private

    def generate_league_for_league_cup(params, cup)
        league = League.new(points_for_win: params[:points_for_win].to_i,
            points_for_draw: params[:points_for_draw].to_i,
            points_for_lost: params[:points_for_lost].to_i,
            is_round_trip: params[:round_trip] == "on",
            start_date: Date.parse(params[:start_date]),
            end_date: Date.parse(params[:end_date]), state: 0,
            win_order: generate_win_order(params) ,cup: cup)
    end

    def generate_knockout_for_knockout_cup(params, cup)
        knockout = Knockout.create( is_round_trip: params[:round_trip] == "on",
            is_round_trip_final: params[:round_trip_final] == "on",
            away_goal: params[:away_goal] == "on",
            third_place_match: params[:third_place_match] == "on",
            start_date: Date.parse(params[:start_date]),
            end_date: Date.parse(params[:end_date]), state: 0, cup: cup)
    end

    def generate_league_for_combination_cup(params, cup)
        league = League.create(points_for_win: params[:points_for_win].to_i,
            points_for_draw: params[:points_for_draw].to_i,
            points_for_lost: params[:points_for_lost].to_i,
            is_round_trip: params[:round_trip] == "on",
            start_date: Date.parse(params[:start_date]),
            end_date: Date.parse(params[:end_date]), state: 0,
            win_order: generate_win_order(params) ,cup: cup)
    end

    def generate_knockout_for_combination_cup(params, cup)
        knockout = Knockout.create( is_round_trip: params[:round_trip] == "on",
            is_round_trip_final: params[:round_trip_final] == "on",
            away_goal: params[:away_goal] == "on",
            third_place_match: params[:third_place_match] == "on",
            state: 0, cup: cup)
    end

    def generate_win_order(params)
        win_order = []
        params[:win_order].each do |win_factor|
            win_order << League.win_factors[win_factor]
        end
        win_order
    end

    def generate_save_error(object)
        errors = []
        if object.errors.any?
            object.errors.full_messages.each do |message|
                errors << message
            end
        end
        errors
    end

    def render_error(object)
        errors = generate_save_error(object)
        render json: {message: "Oops, couldn't create cup. error :\n#{errors}"}, status: :bad_request and return
    end

    def create_league_and_knockout(params, cup)
        case params[:type]
        when "league"
            league = generate_league_for_league_cup(params, cup)
            result = league.save
            unless result
                Cup.last.destroy
                render_error(league)
                return
            end
        when "knockout"
            knockout = generate_knockout_for_knockout_cup(params, cup)
            result = knockout.save
            unless result
                Cup.last.destroy
                render_error(knockout)
                return
            end
        when "combination"
            league = generate_league_for_combination_cup(params, cup)
            result = league.save
            unless result
                Cup.last.destroy
                render_error(league)
                return
            end
            knockout = generate_knockout_for_combination_cup(params, cup)
            result = knockout.save
            unless result
                Cup.last.destroy
                render_error(knockout)
                return
            end
        else
            render json: {message: "Oops, couldn't create cup. error :\nType of cup is not valid."},
                status: :unprocessable_entity and return
        end
    end

end

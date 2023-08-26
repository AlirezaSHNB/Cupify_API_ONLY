class CupsController < ApplicationController

    # protect_from_forgery with: :exception
    # before_action :authorize

    # ----- add these lines here: -----

    def index
        @cups = Cup.all

        render json: {cups: @cups }
    end

    def show
        @cup = Cup.find(params[:id])
        @football_base_fields = ["futsal", "football", "individual_fifa23", "team_fifa23", "individual_pes23", "team_pes23"]
        @knockout = @cup.knockouts.first if ["knockout", "combination"].include?(@cup.mode)

        render json: {cup: @cup, football_base_fields: @football_base_fields, knockout: @knockout }
    end

    def new
        @cup = Cup.new

        render json: {cup: @cup }
    end

    def create
        @cup = Cup.new(name: params[:name],
            start_date: Date.strptime(params[:start_date], "%m/%d/%Y"),
            end_date: Date.strptime(params[:end_date], "%m/%d/%Y"),
            field: Cup.fields[params[:field]],
            number_of_players: params[:number_of_players].to_i, state: 0,
            min_number_of_participants: params[:min_number_of_participants].to_i,
            max_number_of_participants: params[:max_number_of_participants].to_i,
            mode: Cup.mode[params[:type]])
        result = @cup.save

        if result
            create_league_and_knockout(params, @cup)
            render json: {cup: @cup, message: "Cup created successfully!"}, status: :created
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
        league = League.new(points_for_win: params[:points_for_win_input].to_i,
            points_for_draw: params[:points_for_draw_input].to_i,
            points_for_lost: params[:points_for_lost_input].to_i,
            is_round_trip: params[:round_trip_input] == "1",
            start_date: Date.strptime(params[:start_date], "%m/%d/%Y"),
            end_date: Date.strptime(params[:end_date], "%m/%d/%Y"), state: 0,
            win_order: generate_win_order(params) ,cup: cup)
    end

    def generate_knockout_for_knockout_cup(params, cup)
        knockout = Knockout.create( is_round_trip: params[:round_trip_input] == "1",
            away_goal: params[:away_goal] == "1",
            third_place_match: params[:third_place_match] == "1",
            start_date: Date.strptime(params[:start_date], "%m/%d/%Y"),
            end_date: Date.strptime(params[:end_date], "%m/%d/%Y"), state: 0, cup: cup)
    end

    def generate_league_for_combination_cup(params, cup)
        league = League.create(points_for_win: params[:points_for_win_input].to_i,
            points_for_draw: params[:points_for_draw_input].to_i,
            points_for_lost: params[:points_for_lost_input].to_i,
            is_round_trip: params[:round_trip_input] == "1",
            start_date: Date.strptime(params[:start_date], "%m/%d/%Y"),
            end_date: Date.strptime(params[:end_date], "%m/%d/%Y"), state: 0,
            win_order: generate_win_order(params) ,cup: cup)
    end

    def generate_knockout_for_combination_cup(params, cup)
        knockout = Knockout.create( is_round_trip: params[:round_trip_input] == "1",
            away_goal: params[:away_goal] == "1",
            third_place_match: params[:third_place_match] == "1",
            state: 0, cup: cup)
    end

    def generate_win_order(params)
        win_order = []
        params[:selected_win_order_items].split(',', -1).each do |win_factor|
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
        case params[:config_option]
        when "league"
            league = generate_league_for_league_cup(params, cup)
            render_error(league) unless league.save
        when "knockout"
            knockout = generate_knockout_for_knockout_cup(params, cup)
            render_error(knockout) unless knockout.save
        when "combination"
            league = generate_league_for_combination_cup(params, cup)
            render_error(league) unless league.save
            knockout = generate_knockout_for_combination_cup(params, cup)
            render_error(knockout) unless knockout.save
        else
            render json: {message: "Oops, couldn't create cup. error :\nType of cup is not valid."},
                status: :unprocessable_entity and return
        end
    end

end

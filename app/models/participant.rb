class Participant < ApplicationRecord
    has_many :player_participant, dependent: :destroy
    has_many :players, through: :player_participant
    has_many :cup_participant, dependent: :destroy
    has_many :cups, through: :cup_participant
    has_many :league_participant, dependent: :destroy
    has_many :leagues, through: :league_participant
    has_many :knockout_participant, dependent: :destroy
    has_many :knockouts, through: :knockout_participant
    has_many :scores, dependent: :destroy
    has_many :fouls, dependent: :destroy

    scope :single_players, -> { joins(:players).group('participants.id').having('COUNT(players.id) = 1') }
    scope :multiple_players, -> { joins(:players).group('participants.id').having('COUNT(players.id) > 1') }
    enum field: { futsal: 0, football: 1, individual_ping_pong: 2, team_ping_pong: 3, individual_fifa23: 4, team_fifa23: 5, individual_pes23: 6, team_pes23: 7 }

    def self.matched_participants_with_cup(cup, term)
        where('participants.name LIKE ?', "%#{term}%").joins(:cups).where(cups: { field: cup.field, number_of_players: cup.number_of_players })
    end

    def add_player(player_id)
        PlayerParticipant.create(player: Player.find(player_id), participant: self,
            number: 1)
    end
end

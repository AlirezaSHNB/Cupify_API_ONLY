class Score < ApplicationRecord
    has_one :match, through: :round
    belongs_to :round
    belongs_to :participant
    belongs_to :player
end

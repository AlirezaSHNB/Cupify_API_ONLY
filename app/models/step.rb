class Step < ApplicationRecord
  has_many :matches, dependent: :destroy
  belongs_to :league, optional: true
  belongs_to :knockout, optional: true
  belongs_to :cup

  enum state: { pending: 0, ready_to_start: 1, in_progress: 2, stopped: 3, done: 4 }
end

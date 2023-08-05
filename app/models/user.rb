class User < ApplicationRecord
    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
    include Devise::JWT::RevocationStrategies::JTIMatcher

    devise :database_authenticatable, :registerable,
        :recoverable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self
    validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :username, presence: true, length: { maximum: 50 }, format: { with: /\A[a-zA-Z0-9!@#$%^&*_+=\\-\\.?><()]+\z/, message: "can only contain letters, numbers, and special characters" }
    validates :date_of_birth, presence: true
    validate :date_of_birth_cannot_be_in_future

    before_validation :assign_role, on: :create

    enum gender: { male: 0, female: 1 }

    belongs_to :role

    private

    def assign_role
        self.role = Role.find_by(name: "guest") # set as guest
    end

    def date_of_birth_cannot_be_in_future
        errors.add(:date_of_birth, "cannot be in the future") if date_of_birth.present? && date_of_birth.future?
    end
end

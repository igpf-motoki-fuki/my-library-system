class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  include Devise::JWT::RevocationStrategies::JTIMatcher

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  has_many :lendings
  has_many :books, through: :lendings

  enum role: { user: 0, librarian: 1, admin: 2 }

  validates :name, presence: true
  validates :email, presence: true, uniqueness: true
  validates :role, presence: true

  def jwt_payload
    super.merge('role' => role)
  end
end 
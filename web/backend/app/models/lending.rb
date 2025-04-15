class Lending < ApplicationRecord
    belongs_to :user
    belongs_to :book

    validates :lending_date, presence: true
    validates :return_date, presence: true
    validates :status, presence: true, inclusion: { in: %w[pending returned] }
end
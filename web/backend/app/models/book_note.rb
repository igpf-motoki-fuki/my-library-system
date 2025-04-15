class BookNote < ApplicationRecord
    belongs_to :book

    validates :score, presence: true
    validates :book_review, presence: true
end 
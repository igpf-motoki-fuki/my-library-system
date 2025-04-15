class Book < ApplicationRecord
  has_many :lendings
  has_many :scan_histories
  has_many :users, through: :lendings

  validates :isbn, presence: true, uniqueness: true
  validates :title, presence: true
  validates :author, presence: true
  validates :status, presence: true, inclusion: { in: %w[available lent maintenance] }

  # 国立国会図書館APIから書籍情報を取得
  def self.fetch_from_national_diet_library(isbn)
    # TODO: APIクライアントの実装
    # TODO: エラーハンドリング
  end

  # 書籍の貸出可能状態をチェック
  def available?
    status == 'available'
  end
end 
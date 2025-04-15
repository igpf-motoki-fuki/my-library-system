class BookSerializer
  include JSONAPI::Serializer
  
  attributes :id, :isbn, :title, :author, :publisher, :published_date, :classification, :description, :status

  attribute :published_date do |book|
    book.published_date&.strftime('%Y/%m/%d')
  end

  attribute :current_lending do |book|
    if book.lendings.lent.exists?
      LendingSerializer.new(book.lendings.lent.first).serializable_hash[:data][:attributes]
    end
  end
end 
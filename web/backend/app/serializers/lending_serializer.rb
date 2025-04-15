class LendingSerializer
  include JSONAPI::Serializer
  
  attributes :id, :status, :lent_at, :returned_at

  attribute :book do |lending|
    BookSerializer.new(lending.book).serializable_hash[:data][:attributes]
  end

  attribute :user do |lending|
    UserSerializer.new(lending.user).serializable_hash[:data][:attributes]
  end

  attribute :lent_at do |lending|
    lending.lent_at&.strftime('%Y/%m/%d %H:%M')
  end

  attribute :returned_at do |lending|
    lending.returned_at&.strftime('%Y/%m/%d %H:%M')
  end
end 
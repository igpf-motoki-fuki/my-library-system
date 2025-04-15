class UserSerializer
  include JSONAPI::Serializer
  
  attributes :id, :email, :name, :role, :created_at, :updated_at

  attribute :created_date do |user|
    user.created_at&.strftime('%Y/%m/%d')
  end
end 
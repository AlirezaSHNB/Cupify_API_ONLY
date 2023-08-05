class UserSerializer
  include JSONAPI::Serializer
  attributes :id, :email, :username, :gender, :date_of_birth
end

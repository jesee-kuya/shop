FactoryBot.define do
  factory :product do
    title { "Sample Product" }
    brand { "Sample Brand" }
    model { "Sample Model" }
    description { "A great product for testing" }
    condition { "New" }
    price { 99.99 }
    association :user
  end
end
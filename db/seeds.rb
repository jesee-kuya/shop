# db/seeds.rb

def load_image(file_name)
  path = Rails.root.join("app/assets/images/#{file_name}")
  File.exist?(path) ? File.open(path) : nil
end

user = User.find_or_create_by!(email: "user@example.com") do |u|
  u.name = "Random User"
  u.password = "password"
  u.password_confirmation = "password"
end

Product.create!([
  {
    title: "Watch",
    brand: "Fossil",
    model: "FH256",
    description: "Good watch for men!",
    condition: "Mint",
    finish: "Black",
    price: 100,
    image: load_image("fossil.jpg"),
    user_id: user.id
  },
  {
    title: "Car",
    brand: "Opel",
    model: "Corsa",
    description: "Cool red car",
    condition: "Excellent",
    finish: "Red",
    price: 15000,
    image: load_image("opel.jpeg"),
    user_id: user.id
  },
  {
    title: "Car",
    brand: "Ferrari",
    model: "F12",
    description: "Cool sports car",
    condition: "New",
    finish: "Black",
    price: 160000,
    image: load_image("ferrari.jpeg"),
    user_id: user.id
  },
  {
    title: "Computer",
    brand: "Lenovo",
    model: "ThinkPad X1 Carbon Touch",
    description: "The Lenovo ThinkPad X1 Carbon Touch is an incredibly thin and light business ultrabook that features a premium design with a 14-inch touch.",
    condition: "Used",
    finish: "Black",
    price: 500,
    image: load_image("computer.jpg"),
    user_id: user.id
  }
])

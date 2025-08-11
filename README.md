# Rails E-Commerce Shop

A full-featured e-commerce application built with Ruby on Rails, featuring user authentication, product management, and a sophisticated shopping cart system that works for both authenticated users and guests.

## Features

### User Management
- **User Authentication**: Complete user registration, login, and profile management using Devise
- **User Profiles**: Users can sign up with name and email, update their profiles
- **Secure Authentication**: Password reset, remember me functionality, and secure session management

### Product Management
- **Product Listings**: Browse all products with detailed information
- **Product Creation**: Authenticated users can create product advertisements
- **Product Details**: Each product includes title, brand, model, price, description, condition, and color
- **Image Upload**: Products support image uploads with automatic resizing using CarrierWave and MiniMagick
- **Owner Authorization**: Only the creator of a product can edit or delete it

### Shopping Cart System
- **Guest Cart Support**: Anonymous users can add items to cart before registration
- **Persistent Cart**: Cart persists across browser sessions for logged-in users
- **Cart Merging**: When guests sign up or log in, their cart automatically merges with their user account
- **Cart Management**: Add items, remove items, update quantities, view total price
- **Real-time Updates**: Cart updates work with both HTML and JSON responses for AJAX support

### Technical Features
- **Responsive Design**: Built with Bulma CSS framework for mobile-friendly interface
- **Image Processing**: Automatic image resizing and thumbnail generation
- **Database Optimization**: Proper indexing and foreign key constraints
- **Counter Caching**: Efficient cart item counting
- **Error Handling**: Comprehensive error handling for cart operations

## Technology Stack

- **Ruby**: 3.2.3
- **Rails**: 8.0.2
- **Database**: SQLite3 (development/test)
- **Authentication**: Devise 4.4+
- **File Uploads**: CarrierWave 2.0+ with MiniMagick
- **CSS Framework**: Bulma Rails 0.8+
- **Forms**: Simple Form 5.1+
- **JavaScript**: Webpacker 5.0+
- **Testing**: RSpec (configured)

## Installation

### Prerequisites

- Ruby 3.2.3
- Rails 8.0.2
- Node.js and Yarn (for asset compilation)
- ImageMagick (for image processing)

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd shop
   ```

2. **Install Ruby dependencies**
   ```bash
   bundle install
   ```

3. **Install JavaScript dependencies**
   ```bash
   yarn install
   ```

4. **Setup the database**
   ```bash
   rails db:create
   rails db:migrate
   rails db:seed
   ```

5. **Generate Devise secret key**
   ```bash
   rails generate devise:install
   ```

6. **Start the development server**
   ```bash
   rails server
   ```

7. **Start the webpack dev server** (in another terminal)
   ```bash
   bin/webpack-dev-server
   ```

The application will be available at `http://localhost:3000`

## Usage

### For Shoppers

1. **Browse Products**: Visit the homepage to see all available products
2. **View Product Details**: Click on any product to see full details and images
3. **Add to Cart**: Add products to your cart (works without registration)
4. **Manage Cart**: View cart, update quantities, remove items
5. **Sign Up/Login**: Create an account to save your cart and manage your products

### For Sellers

1. **Create Account**: Sign up for a new account
2. **Add Products**: Click "New Product" to create a product listing
3. **Upload Images**: Add product images that will be automatically resized
4. **Manage Listings**: Edit or delete your own product listings
5. **View Sales**: See your products in the main product listing

## Database Schema

### Users Table
- `id`: Primary key
- `email`: User's email address (unique)
- `encrypted_password`: Devise encrypted password
- `name`: User's display name
- `reset_password_token`: For password reset functionality
- Timestamps and Devise tracking fields

### Products Table
- `id`: Primary key
- `title`: Product title (max 140 characters)
- `brand`: Product brand (from predefined list)
- `model`: Product model
- `price`: Decimal price (precision 5, scale 2)
- `description`: Text description (max 1000 characters)
- `condition`: Product condition (New, Used, etc.)
- `finish`: Product color/finish
- `image`: CarrierWave image upload
- `user_id`: Foreign key to users table
- Timestamps

### Carts Table
- `id`: Primary key
- `user_id`: Foreign key to users (nullable for guest carts)
- `cart_items_count`: Counter cache for performance
- Timestamps

### Cart Items Table
- `id`: Primary key
- `cart_id`: Foreign key to carts
- `product_id`: Foreign key to products
- `quantity`: Integer quantity (default 1)
- Unique constraint on cart_id + product_id
- Timestamps

## Key Components

### Models

- **User**: Devise authentication with cart relationship
- **Product**: Core product model with validations and image upload
- **Cart**: Shopping cart with business logic for adding/removing items
- **CartItem**: Join model between carts and products with quantity
- **CurrentCart**: Concern for managing guest and user carts

### Controllers

- **ApplicationController**: Base controller with authentication and cart merging
- **ProductsController**: CRUD operations for products with authorization
- **CartsController**: Cart management with AJAX support
- **RegistrationsController**: Custom Devise registration handling

### Key Features Implementation

#### Guest Cart Persistence
The application uses a sophisticated system to handle shopping carts for both guests and authenticated users:

- Guest carts are stored in the database with `user_id: nil`
- Cart ID is stored in the session for guest users
- When a guest logs in, their cart automatically merges with their user cart
- No items are lost during the registration/login process

#### Authorization System
- Products can only be edited/deleted by their creators
- Cart operations work for both guests and authenticated users
- Proper error handling for unauthorized access attempts

#### Image Upload System
- Uses CarrierWave with MiniMagick for image processing
- Automatically creates thumbnail (400x300) and default (800x600) versions
- Supports JPG, JPEG, GIF, and PNG formats
- Images stored in organized directory structure

## Development

### Running Tests
```bash
# Run all tests
bundle exec rspec

# Run specific test file
bundle exec rspec spec/models/product_spec.rb
```

### Code Style
The project follows Rails conventions and includes:
- Proper model validations and associations
- RESTful controller actions
- Semantic HTML with Bulma CSS classes
- AJAX-ready controller responses

### Adding New Features
When extending the application:
1. Follow Rails conventions for naming and structure
2. Add appropriate validations to models
3. Include proper authorization checks in controllers
4. Update tests for new functionality
5. Consider both HTML and JSON response formats

## Deployment

For production deployment:

1. **Environment Variables**: Set up proper environment variables for:
   - `SECRET_KEY_BASE`
   - Database credentials
   - Image upload storage (consider AWS S3)

2. **Database**: Switch from SQLite to PostgreSQL or MySQL
3. **Assets**: Precompile assets with `rails assets:precompile`
4. **Images**: Configure CarrierWave for cloud storage in production

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes with appropriate tests
4. Submit a pull request

## License

This project is available under the MIT License.

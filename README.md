# Deal Finder

A Ruby on Rails application for finding and filtering deals based on various criteria including location, price,
categories, and more.

## Features

- Filter deals by category, subcategory, price range, and tags
- Location-based filtering with radius search
- Featured and available deal filters
- Automatic filtering of expired deals
- Deal ranking based on relevance
- Pagination support via Kaminari

## Requirements

- Ruby 3.3.4
- Rails 8.0.2
- PostgreSQL 15+

## Setup

1. **Install Ruby and Dependencies**
   ```bash
   # Install RVM and Ruby
   curl -sSL https://get.rvm.io | bash -s stable
   rvm install 3.3.4
   rvm use 3.3.4

   # Install dependencies
   bundle install
   ```

2. **Configure Environment**
    - Copy the example environment file:
      ```bash
      cp .env.example .env
      ```
    - Update `.env` with your configuration values

3. **Setup Database**
   ```bash
   # Create and setup the database
   rails db:create
   rails db:migrate
   rails db:seed
   ```

4. **Start the Application**
   ```bash
   # Start the Rails server
   rails server
   ```

5. **Running Tests**
   ```bash
   # Run the test suite
   bundle exec rspec
   ```

The application will be available at http://localhost:3000

## Dependencies

- `geocoder`: Location-based search functionality
- `acts-as-taggable-on`: Tagging functionality
- `kaminari`: Pagination
- `rspec-rails`: Testing framework
- `shoulda-matchers`: Test matchers for common Rails functionality
- `brakeman`: Security vulnerability scanning

## API Endpoints

### Deals API

`GET /api/v1/deals`

Parameters:

- `category`: Filter by category name
- `subcategory`: Filter by subcategory name
- `min`: Minimum price
- `max`: Maximum price
- `tag`: Filter by tag(s)
- `lat`: Latitude for location-based search
- `lon`: Longitude for location-based search
- `radius`: Search radius in kilometers
- `featured`: Filter for featured deals (`true`/`false`)
- `available`: Filter for available deals
- `page`: Page number for pagination

Response:

```json
[
  {
    "id": 1,
    "title": "Example Deal",
    "description": "Deal description",
    "original_price": 100.0,
    "discount_price": 75.0,
    "category": "Food",
    "subcategory": "Restaurants",
    "merchant": {
      "name": "Merchant Name",
      "rating": 9.5,
      "location": {
        "name": "Store Name",
        "address": "123 Main St",
        "latitude": 40.7128,
        "longitude": -74.0060
      }
    },
    "tags": [
      "discount",
      "food"
    ],
    "featured_deal": true,
    "available_quantity": 10,
    "expiry_date": "2023-12-31"
  }
]
```

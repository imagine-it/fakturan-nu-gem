Ruby client for the fakturan.nu API
==============================

API client in ruby for the web based invoicing software [fakturan.nu](https://www.fakturan.nu).

---

## Installation

If you're using Rails/Bundler, add this to your Gemfile:

```ruby
gem "fakturan_nu"
```

Then create an initializer in app/initializers called  ``` fakturan_nu.rb  ``` (or whatever name you choose) with the following:

```ruby
Fakturan.setup 'your api username here', 'your api key/password here'
Fakturan.use_sandbox = true # Should be true during development/testing and false in production.
```

If you're not using Rails, then just ``` require 'fakturan_nu'``` and run the setup method wherever you like.

## Usage

```ruby
Fakturan::Product.all
# GET "https://api.example.com/products" and return an array of product objects

Fakturan::Product.find(1)
# GET "https://api.example.com/products/1" and return a product object

@product = Fakturan::Product.create(name: "Shoes")
# POST "https://api.example.com/products" with `name=Shoes` and return the saved product object

@product = Fakturan::Product.new(name: "Shoes")
@product.tax = 12
@product.save
# POST "https://api.example.com/products" with `name=Shoes` and return the saved product object

@product = Fakturan::Product.find(1)
@product.name = "Blue suede shoes"
@product.save
# PUT "https://api.example.com/products/1" with `name=Blue+suede+shoes` and return the updated product object
```
## Pagination

The Fakturan.nu API paginates results. When a collection is fetched, it contains pagination information on the metadata accessor. So in order to get all results, you can do:

```ruby
products = Fakturan::Product.all # This will give you paginated results of 30 items per page by default
products.concat(Fakturan::Product.get(products.metadata[:next])) while products.metadata[:next]
```

You can change the default number of items per page (30) by passing in the per_page parameter:

```ruby
products = Fakturan::Product.where(per_page: 100) # This will give you paginated results of 100 items per page
products.concat(Fakturan::Product.get(products.metadata[:next])) while products.metadata[:next]
```

The maximum number of items per page allowed is 100.

## Validation

Errors and validation are handled much like in ActiveRecord:

```ruby
invoice = Fakturan::Invoice.new
invoice.save # false
invoice.errors.to_a # ["Client can't be blank", "Date can't be blank", "Date is invalid"]
```

As with ActiveRecord, the ``` save ``` and ``` create ``` methods will return ``` true ``` or ``` false ``` depending on validations, while  ``` save! ``` and ``` create! ``` will raise an error if validations fail. The error that is raised in such cases is ``` Fakturan::Error::ResourceInvalid ```.

## Error handling

If the server responds with an error, or if the server cannot be reached, one of the following errors will be raised:

```ruby
Fakturan::Error::AccessDenied     # http status code: 401
Fakturan::Error::ResourceNotFound # http status code: 404
Fakturan::Error::ConnectionFailed # http status code: 407
Fakturan::Error::ResourceInvalid  # http status code: 422
Fakturan::Error::ClientError      # http status code: other in the 400-499 range
Fakturan::Error::ServerError      # http status code: other in the 500-599 range
```

These errors are all descendents of ```Fakturan::Error``` and should be caught in a begin-rescue block like so (example in a Rails-controller):

```ruby
begin
  invoice = Fakturan::Invoice.create!
rescue Fakturan::Error => error
  render plain: error.message, status: error.status
end
```


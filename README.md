Ruby client for the fakturan.nu API
==============================

API client in ruby for the Swedish web based invoicing software [fakturan.nu](https://www.fakturan.nu). The API is currently in Beta and may be subject to change without notice until final release.

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

If you're not using Rails, just ``` require 'fakturan_nu'``` and run setup wherever you like.

## Usage

### General

The client attempts to provide an interface similar to ActiveRecord.

```ruby
Fakturan::Product.all
# GET "https://fakturan.nu/api/v2/products" and return an array of product objects

Fakturan::Product.find(1)
# GET "https://fakturan.nu/api/v2/products/1" and return a product object

product = Fakturan::Product.create(name: "Shoes")
# POST "https://fakturan.nu/api/v2/products" and return the saved product object

product = Fakturan::Product.new(name: "Shoes")
product.tax = 12
product.save
# POST "https://fakturan.nu/api/v2/products" and return the saved product object

product = Fakturan::Product.find(1)
# GET "https://fakturan.nu/api/v2/products/1" and return a product object
product.name = "Blue suede shoes" # Update a property
product.save
# PUT "https://fakturan.nu/api/v2/products/1" and return the updated product object
```

### Invoices

For creating invoices, a client is required. It can be an existing client (by using client_id), or a new one (by using client):

```ruby
invoice = Fakturan::Invoice.create(client: { company: "Acme Inc" })
# POST "https://fakturan.nu/api/v2/invoices" # Will create a new client + invoice

invoice = Fakturan::Invoice.create(client_id: 1)
# POST "https://fakturan.nu/api/v2/invoices" # Will create a new invoice for client with id: 1

```
Example with items/rows:
```ruby
invoice = Fakturan::Invoice.create(client_id: 1, rows: [{ product_name: "Shoes", product_unit: "pairs", amount: "1", product_price: "500"}])
# POST "https://fakturan.nu/api/v2/invoices" # Will create a new invoice for client with id: 1
```

### Available resources and properties

For a full list of resources and the properties of each type of resource, see the [api reference](https://sandbox.fakturan.nu/apidocs). 

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
  invoice = Fakturan::Invoice.create!(invoice_params)
rescue Fakturan::Error => error
  render plain: error.message, status: error.status
end
```


module Fakturan
  class Product < Base
    uri 'products/(:id)'

    attributes :name, :unit, :price, :tax, :product_code
  end
end
module Fakturan
  class Address < Base
    uri nil

    attributes :name, :care_of, :street_address, :zip_code, :city, :country
  end
end
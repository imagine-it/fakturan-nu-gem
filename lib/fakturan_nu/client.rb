module Fakturan
  class Client < Base
    uri "clients/(:id)"
    has_many :invoices, uri: "clients/:id/invoices", foreign_key: 'id'
    has_one :address, uri: nil

    accepts_nested_attributes_for :address

    attributes :number, :first_name, :last_name, :email, :company, :phone, :home_phone, :mobile_phone, :fax, :org_number, :private, :web, :vat_number

    def address=(attrs_or_obj)
      if attrs_or_obj.respond_to?(:each)
        send(:address_attributes=, attrs_or_obj)
      else
        super
      end
    end
  end
end
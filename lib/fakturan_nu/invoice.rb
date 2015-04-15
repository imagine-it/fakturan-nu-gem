module Fakturan
  class Invoice < Base
    uri "invoices/(:id)"

    # The foreign_key decides which attribute will be used to set the id
    belongs_to :client, uri: "clients/(:id)", foreign_key: 'client_id'
    has_one :address, uri: nil
    
    has_many :rows, uri: nil

    accepts_nested_attributes_for :rows, :address, :client

    # These create getter methods on new instances, mostly for use in forms
    attributes :number, :date, :client_id, :days, :our_reference, :your_reference, :sent, :paid, :paid_at, :interval_period, :auto_send, :recurring, :last_day_of_month, :start_recurring_from, :locale, :currency

    def rows=(attrs_or_obj_array)
      if attrs_or_obj_array.first.respond_to?(:each)
        send(:rows_attributes=, attrs_or_obj_array)
      else
        super
      end
    end

    def address=(attrs_or_obj)
      if attrs_or_obj.respond_to?(:each)
        send(:address_attributes=, attrs_or_obj)
      else
        super
      end
    end

    def client=(attrs_or_obj)
      if attrs_or_obj.respond_to?(:each)
        send(:client_attributes=, attrs_or_obj)
      else
        super
      end
    end
  end
end
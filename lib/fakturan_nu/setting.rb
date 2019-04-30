module Fakturan
  class Setting < Base
    has_many :payment_options, uri: nil
    accepts_nested_attributes_for :payment_options

    attributes :company_email

    def payment_options=(attrs_or_obj)
      if attrs_or_obj.respond_to?(:each)
        send(:payment_options_attributes=, attrs_or_obj)
      else
        super
      end
    end
  end
end
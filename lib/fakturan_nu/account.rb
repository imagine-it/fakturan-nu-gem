module Fakturan
  class Account < Base
    uri 'accounts/(:id)'
    has_many :users, uri: nil
    belongs_to :setting, uri: nil

    attributes :api_token

    accepts_nested_attributes_for :users, :setting

    def users=(attrs_or_obj_array)
      if attrs_or_obj_array.first.respond_to?(:each)
        send(:users_attributes=, attrs_or_obj_array)
      else
        super
      end
    end

    def setting=(attrs_or_obj)
      if attrs_or_obj.respond_to?(:each)
        send(:setting_attributes=, attrs_or_obj)
      else
        super
      end
    end
  end
end
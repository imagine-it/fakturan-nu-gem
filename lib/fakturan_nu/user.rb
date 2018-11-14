module Fakturan
  class User < Base
    attributes :login, :name, :has_approved_now

    validates :login, presence: true
    validates :name, presence: true
  end
end
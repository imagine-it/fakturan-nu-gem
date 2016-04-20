module Fakturan
  class User < Base
    attributes :login, :name

    validates :login, presence: true
    validates :name, presence: true
  end
end
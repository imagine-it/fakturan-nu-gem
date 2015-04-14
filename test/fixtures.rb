module Fakturan
  class Tree < Base
    uri 'trees/(:id)'
    has_many :apples, uri: nil
    has_one :crown, uri: nil

    accepts_nested_attributes_for :apples, :crown
  end

  class Apple < Base
    attributes :colour
  end

  class Crown < Base
    attributes :fluffyness
  end
end
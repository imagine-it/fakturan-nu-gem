module Fakturan
  class Tree < Base
    uri 'trees/(:id)'
    has_many :apples, uri: nil
    has_one :crown, uri: nil
    has_one :trunk, uri: nil

    accepts_nested_attributes_for :apples, :crown, :trunk

    attributes :name

    # This allows us to create instances through params without using _attributes
    def apples=(attrs_or_obj)
      if attrs_or_obj.respond_to?(:each)
        send(:apples_attributes=, attrs_or_obj)
      else
        super
      end
    end

    def crown=(attrs_or_obj)
      if attrs_or_obj.respond_to?(:each)
        send(:crown_attributes=, attrs_or_obj)
      else
        super
      end
    end

    def trunk=(attrs_or_obj)
      if attrs_or_obj.respond_to?(:each)
        send(:trunk_attributes=, attrs_or_obj)
      else
        super
      end
    end
  end

  class Apple < Base
    attributes :colour
  end

  class Crown < Base
    attributes :fluffyness
  end

  class Trunk < Base
    has_many :branches, uri: nil
    accepts_nested_attributes_for :branches

    attributes :colour

    def branches=(attrs_or_obj)
      if attrs_or_obj.respond_to?(:each)
        send(:branches_attributes=, attrs_or_obj)
      else
        super
      end
    end
  end

  class Branch < Base
    attributes :length
  end
end
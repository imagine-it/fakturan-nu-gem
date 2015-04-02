module Spyke
  class Collection
    # For pagination. 
    # Makes it possible to do ps = Fakturan::Product.all and then
    # ps.concat(Fakturan::Product.get(ps.metadata[:next])) while ps.metadata[:next])
    def concat ary_or_collection
      @metadata = ary_or_collection.metadata if ary_or_collection.respond_to?(:metadata)
      super
    end
  end

  class Relation
    # For pagination and more array-like behaviour.
    # It's very tempting to add << as well, but as I recall, it didn't behave as expected
    delegate :concat, :+, :-, to: :find_some
  end

  module Associations
    class Builder
      # Allows us to do reflect_on_association(ass_name).type
      attr_accessor :type
    end
  end
end
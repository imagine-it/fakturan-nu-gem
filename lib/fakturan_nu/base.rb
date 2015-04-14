require 'fakturan_nu/error'

module Fakturan
  class Base < Spyke::Base
    include_root_in_json false

    def self.connection
      Fakturan.connection
    end

    def self.create!(attrs = {})
      instance = self.new(attrs)
      instance.save!
      return instance
    end

    def self.create(attrs = {})
      instance = self.new(attrs)
      instance.save
      return instance
    end

    def save
      errors.clear
      super
      return !errors.any?
    end

    def save!
      raise Fakturan::Error::ResourceInvalid, self unless self.save
    end

    # This is an override from: https://github.com/balvig/spyke/blob/master/lib/spyke/http.rb
    # to allow for nested errors on associated objects
    def add_errors_to_model(errors_hash)
      errors_hash.each do |field, field_errors|
        ass_name, field_name = field.split(".").map(&:to_sym)
        field_name = ass_name unless field_name

        # The errors are for an associated object, and there is an associated object to put them on
        if (association = self.class.reflect_on_association(ass_name)) && !self.send(ass_name).blank?
          if association.type == Spyke::Associations::HasMany
            # We need to add one error to our "base" object so that it's not valid
            self.add_to_errors(field_name.to_sym, [{error: :invalid}])
            field_errors.each do |new_error_hash_with_index| # new_error_hash_OR_error_type ("blank") on presence of has_many
              new_error_hash_with_index.each do |index, inner_errors_hash|
                error_attribute = inner_errors_hash.keys.first.split('.').last.to_sym
                self.send(ass_name)[index.to_i].add_to_errors(error_attribute, inner_errors_hash.values.last)
              end
            end
          else # It's a belongs_to or has_one
            # We add the error to the associated object
            self.send(ass_name).add_to_errors(field_name, field_errors)
            # and then we get the errors (with generated messages) and add them to
            # the parent (but without details, like nested_attributes works)
            # This only makes sense on belongs_to and has_one, since it's impossible
            # to know which object is refered to on has_many
            self.send(ass_name).errors.each do |attribute, message|
              attribute = "#{ass_name}.#{attribute}"
              errors[attribute] << message
              errors[attribute].uniq!
            end
          end
        else
          self.add_to_errors(field_name.to_sym, field_errors)
        end

      end
    end

    def add_to_errors field_name, field_errors
      field_errors.each do |attributes|
        attributes = attributes.symbolize_keys
        error_name = attributes.delete(:error).to_sym
        errors.add(field_name.to_sym, error_name, attributes)
      end
    end

    # This is an override from: https://github.com/balvig/spyke/blob/master/lib/spyke/http.rb
    # In order to re-raise Faraday error as Fakturan error
    def self.request(method, path, params = {})
      begin
        super
      rescue Faraday::ConnectionFailed => e
        raise Fakturan::Error::ConnectionFailed, e.message
      rescue Faraday::TimeoutError => e
        raise Fakturan::Error::ConnectionFailed, e.message
      end
    end
  end
end
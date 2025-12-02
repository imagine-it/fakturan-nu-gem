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
      association_trees = errors_hash.map { |error_key, errors| error_key.to_s.split(".") }.uniq

      association_trees.each do |association_tree|
        association_errors = errors_hash[association_tree.join('.')]
        association_or_attribute_name = association_tree.last
        association_target = association_tree[0..-2].inject(self, :send)

        # Ingore errors for non existant attributes
        next unless association_target.respond_to?(association_or_attribute_name)

        if association_target.send(association_or_attribute_name).respond_to? :each
          # It's a has_many association
          if association_errors == [{"error"=>"blank"}]
            # Special case when the association is completely blank
            self.add_to_errors(association_tree.first, [{error: :blank}])
          else
            # We need to add one error to our "base" object so that it's not valid
            self.add_to_errors(association_tree.first, [{error: :invalid}])
            association_errors.each do |new_error_hash_with_index|

              new_error_hash_with_index.each do |index, inner_errors_hash|
                inner_errors_hash.each do |inner_field_name, inner_field_errors|
                  error_attribute = inner_field_name.split('.').last.to_sym
                  association_target.send(association_or_attribute_name)[index.to_i].add_to_errors(error_attribute, inner_field_errors)
                end
              end
            end
          end
        else
          # It's an attribute
          association_target.add_to_errors(association_or_attribute_name.to_sym, association_errors)
          association_target.errors.each do |error|
            error_key = association_tree.join('.')
            next if self.errors[error_key].include?(error.message)

            self.errors.add(error_key, error.message)
          end
        end
      end
    end

    def add_to_errors field_name, field_errors
      field_errors.each do |attributes|
        attributes = attributes.symbolize_keys
        error_name = attributes.delete(:error).to_sym
        errors.add(field_name.to_sym, error_name, **attributes)
      end
    end

    # This is an override from: https://github.com/balvig/spyke/blob/master/lib/spyke/http.rb
    # In order to re-raise Faraday error as Fakturan error
    def self.request(method, path, params = {})
      begin
        super
      rescue Spyke::ConnectionError => e
        raise Fakturan::Error::ConnectionFailed, e.message
      rescue Faraday::TimeoutError => e
        raise Fakturan::Error::ConnectionFailed, e.message
      end
    end
  end
end
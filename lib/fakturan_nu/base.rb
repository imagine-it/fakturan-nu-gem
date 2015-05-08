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

        path_parts = field.split(".").map(&:to_sym) # 'client.address.country' for example, usually only 1-2 levels though (but sometimes more)
        ass_name = path_parts.first
        field_name = path_parts.last # Will be the same as ass_name if only 1 level

        # The errors are for an associated object, and there is an associated object to put them on
        if (association = self.class.reflect_on_association(ass_name)) && !self.send(ass_name).blank?
          if association.type == Spyke::Associations::HasMany
            # We need to add one error to our "base" object so that it's not valid
            self.add_to_errors(field_name.to_sym, [{error: :invalid}])
            field_errors.each do |new_error_hash_with_index| # new_error_hash_OR_error_type ("blank") on presence of has_many
              new_error_hash_with_index.each do |index, inner_errors_hash|
                inner_errors_hash.each do |inner_field_name, inner_field_errors|
                  error_attribute = inner_field_name.split('.').last.to_sym
                  self.send(ass_name)[index.to_i].add_to_errors(error_attribute, inner_field_errors)
                end
              end
            end
          else # It's a belongs_to or has_one
            path_progression = [] # Will become: [['client'], ['client', 'address'], ['client', 'address', 'country']]
            path_progression = path_parts[0..-2].map {|ass_key| path_progression += [ass_key]}

            path_progression.each do |path_sub_parts|
              full_field_path = path_parts[path_sub_parts.length-1..path_parts.length].join('.')
              field_name = path_parts[1..path_sub_parts.length].last.to_s
              association_target = path_sub_parts.inject(self, :send)
              association_target_parent = path_sub_parts[0..-2].inject(self, :send)

              # We add the error to the associated object
              association_target.add_to_errors(field_name, field_errors)
              # and then we get the errors (with generated messages) and add them to
              # the parent (but without details, like nested_attributes works)
              # This only makes sense on belongs_to and has_one, since it's impossible
              # to know which object is refered to on has_many
              association_target.errors.each do |attribute, message|
                association_target_parent.errors[full_field_path] << message
                association_target_parent.errors[full_field_path].uniq!
              end
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
require "bit_enum/invalid_option_exception"
require "bit_enum/bit_mask"
require "bit_enum/version"

module BitEnum
  def bit_mask(elements = {})
    mask_field = elements.keys.first
    singular_mask_field = mask_field.to_s.singularize.to_sym

    class_eval do
      options_method = :"#{singular_mask_field}_options"
      options = elements.values.first.keys

      define_method :bit_mask_options do
        options
      end

      alias_method options_method, :bit_mask_options

      singleton_class.send :instance_eval do
        define_method :bit_mask_options do
          elements[mask_field].invert
        end

        alias_method options_method, :bit_mask_options
      end

      values_method = :"#{singular_mask_field}_values"

      values = elements.values.first

      define_method :bit_mask_values do
        values
      end

      alias_method values_method, :bit_mask_values

      define_method mask_field do
        bit_mask_object
      end

      define_method :"#{mask_field}=" do |value|
        if value.is_a?(Array)
          @bit_mask_object = BitMask.new(self, value.map(&:to_sym))
          value = bit_mask_object.to_bit_mask
        end

        super(value)
      end

      define_method :"#{singular_mask_field}_ids" do
        bit_mask_object.value_ids
      end

      define_method :"#{singular_mask_field}_ids=" do |ids|
        bit_mask_object.value_ids = ids
      end

      define_method :bit_mask_value do
        self[mask_field]
      end

      define_method :bit_mask_value= do |value|
        self.send :"#{mask_field}=", value
      end

      options.each do |option|
        define_method :"#{option}?" do
          bit_mask_object.include? option
        end

        scope option.to_s.pluralize.to_sym, -> { where("#{mask_field} & ? > 0", 2 ** values[option]) }
      end

      private

      def bit_mask_object
        @bit_mask_object ||= BitMask.new(self)
      end
    end
  end
end

ActiveRecord::Base.send :extend, BitEnum

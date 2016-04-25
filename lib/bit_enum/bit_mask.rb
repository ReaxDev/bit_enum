class BitMask < SimpleDelegator
  attr_reader :object, :options, :values, :inverted_values

  def initialize(object, new_values = nil)
    @object = object
    @options = object.bit_mask_options
    @values = object.bit_mask_values
    @inverted_values = @values.invert

    if not new_values.nil?
      raise InvalidOptionException if new_values.present? and (options & new_values).empty?
      super(new_values)
      object.bit_mask_value = self.to_bit_mask
    else
      super(get_values_from_mask(object.bit_mask_value).values)
    end
  end

  def <<(key)
    key = key.to_sym
    raise InvalidOptionException unless @options.include?(key)
    __getobj__ << key
    object.bit_mask_value = self.to_bit_mask
    __getobj__.uniq!
    __getobj__
  end

  def to_bit_mask
    __getobj__.map { |x| @values[x] }.reduce(0) { |acc, x| (1 << x) | acc }
  end

  def value_ids
    get_values_from_mask(object.bit_mask_value).keys
  end

  def value_ids=(ids)
    __setobj__ ids.reduce([]) {|acc, id| acc << @inverted_values[id.to_i]; acc}
    object.bit_mask_value = self.to_bit_mask
  end

  protected

  def get_values_from_mask(mask)
    @inverted_values.select { |x, _| mask & (2 ** x) > 0 }
  end

end

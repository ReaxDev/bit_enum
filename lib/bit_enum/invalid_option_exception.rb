class InvalidOptionException < Exception
  def initialize
    super('invalid value')
  end
end

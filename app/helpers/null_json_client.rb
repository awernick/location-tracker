class NullJSONClient
  attr_accessor :error
  attr_accessor :object

  def initialize(error = false)
    @error = error
    @object = {}
  end

  def put(address, params, &block)
    request(address, params, &block)
  end

  def post(address, params, &block)
    request(address, params, &block)
  end

  def request(*args, &block)
    result = OpenStruct.new(:error => nil, :object => @object)
    result.error = NSError.alloc.initWithDomain('Error Domain', code: 5, userInfo: nil) if @error
    @object['_id'] = result.object['_id'] = BSON::ObjectId.generate
    block.call(result) if block
  end
end
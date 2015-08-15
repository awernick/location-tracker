class Location::Repository
  include RemoteRepository

  # def initialize(json_client)
  #   #super
  #   @json_client = json_client
  # end

  # def all(&block)
  #   @json_client.get('locations') do |result|
  #     if result.error
  #       block.call(nil) if block
  #     else
  #       locations = result.object.map do |location|
  #         Location.new(normalize_params(location))
  #       end

  #       block.call(locations) if block
  #     end
  #   end
  # end

  # def save(location, &block)
  #   get(location) do |remote_location|
  #     if remote_location.nil?
  #       add(location, &block)
  #     else
  #       update(location, &block)
  #     end
  #   end
  # end

  # def get(location, &block)
  #   @json_client.get("locations/#{location.id}") do |result|
  #     if result.error
  #       block.call(nil) if block
  #     else
  #       location = Location.new(normalize_params(result.object))
  #       block.call(location) if block
  #     end
  #   end
  # end

  # def add(location, &block)
  #   location_params = location.to_h
  #   @json_client.post("locations", location_params) do |result|
  #     process_result(result, location_params, &block)
  #   end
  # end

  # def update(location, &block)
  #   location_params = location.to_h
  #   @json_client.put("locations/#{location.id}", location_params) do |result|
  #     process_result(result, location_params, &block)
  #   end
  # end

  # def delete(location, &block)
  #   @json_client.delete("locations/#{location.id}") do |result|
  #     if result.error
  #       block.call(false) if block
  #     else
  #       block.call(true) if block
  #     end
  #   end
  # end

private
  # def process_result(result, location_params, &block)
  #   if result.failure?
  #     p result.error
  #   else
  #     location_params.merge!(normalize_params(result.object))
  #   end

  #   location = Location.new(location_params)
  #   block.call(location) if block
  # end

  # def normalize_params(params)
  #   params['id'] = params['_id']
  #   params.select! {|k,v| Location.method_defined?(k) && !v.nil?}
  # end
end
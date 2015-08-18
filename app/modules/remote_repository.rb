module RemoteRepository
  def self.included(base)
    base.extend(ClassMethods)
    base.instance_eval do
      @resource_name = self.to_s.deconstantize 
      @path = @resource_name.underscore.pluralize
    end
  end

  module ClassMethods
    attr_accessor :resource_name
    attr_accessor :path 

    attr_writer :primary_key
    attr_writer :client
    attr_writer :site

    def config
      yield self if block_given?
    end

    def all(&block)
      client.get("#{site}/#{path}") do |result|
        if result.error
          payload = []
        else
          payload = result.object.map do |attrs| 
            resource_name.constantize.new(normalize_result(attrs))
          end
        end

        block.call(payload) if block
      end
    end

    def get(resource, &block)
      client.get("#{site}/#{path}/#{resource.id}") do |result|
        if result.error
          payload = nil
        else
          attrs = normalize_result(result.object)
          payload = resource_name.constantize.new(attrs) 
        end

        block.call(payload) if block
      end
    end

    def add(resource, &block)
      resource_params = resource.to_h unless resource.is_a? Hash
      client.post("#{site}/#{path}", resource_params) do |result|
        process_result(result, resource_params, &block)
      end
    end

    def update(resource, &block)
      resource_params = resource.to_h unless resource.is_a? Hash
      client.put("#{site}/#{path}/#{resource.id}", resource_params) do |result|
        process_result(result, resource_params, &block)
      end
    end
    
    def save(resource, &block)
      get(resource) do |remote_resource|
        if remote_resource.nil?
          add(resource, &block)
        else
          update(resource, &block)
        end
      end
    end

    def delete(resource, &block)
      client.delete("#{site}/#{path}/#{resource.id}") do |result|
        if result.error
          block.call(false) if block
        else
          block.call(true) if block
        end
      end
    end
    
    class ClientError < StandardError; end
    
    def site
      raise ClientError, 'Missing site URI' unless defined? @site
      @site
    end

    def client
      raise ClientError, 'Missing valid client' unless defined? @client
      @client
    end

    def primary_key
      @primary_key || '_id'
    end

  private
    def process_result(result, resource_params, &block)
      if result.failure?
        $logger << result.error
      else
        resource_params.merge!(normalize_result(result.object))
      end

      resource = resource_name.constantize.new(resource_params)
      block.call(resource) if block
    end

    def normalize_result(params)
      params['id'] = params[primary_key]
      params.select! {|k,v| resource_name.constantize.method_defined?(k) && !v.nil?}
    end
  end
end

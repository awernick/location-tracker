# Role
# Represent a geographical location in 
# a map. 
# Messages
module LocationTracker
  class Location
    include MotionModel::Model
    include MotionModel::ArrayModelAdapter

    Coordinate = Struct.new(:latitude, :longitude)
    DATA_STORE = 'locations.data'

    columns :name        => :string,
            :label       => :string,
            :latitude    => :float,
            :longitude   => :float,
            :radius      => { type: :integer, default: ->{ 25 } }

    def initialize(options = {})
      super

      self.label = options[:name]
      self.label = options[:label]
      self.latitude = options[:latitude]
      self.longitude = options[:longitude]
      # self.radius = options[:radius] - Crashes program?
    end

    def coordinate
      [latitude, longitude]
    end

    class << self
      def load
        deserialize_from_file(DATA_STORE)
      end

      def save
        serialize_to_file(DATA_STORE)
      end
    end
  end
end

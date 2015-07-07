# Role
# Represent a geographical location in 
# a map. 
# Messages
module LocationTracker
  class Location
    include MotionModel::Model
    include MotionModel::ArrayModelAdapter

    DATA_STORE = 'locations.data'

    columns :label       => :string,
            :latitude    => :integer,
            :longitude   => :integer,
            :radius      => :integer

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

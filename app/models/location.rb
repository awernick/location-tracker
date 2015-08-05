# Role
# Represent a geographical location in 
# a map. 
# Messages
class Location
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter

  DATA_STORE = 'locations.data'

  # Relations
  has_many :visits

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


  def ==(location)
    return latitude == location.latitude && longitude == location.longitude
  end

  def after_save(sender)
    p 'Saving location'
    p sender.to_s
    Location.save
  end

  def after_delete(sender)
    Location.save
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

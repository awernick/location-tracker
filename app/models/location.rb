# Role
# Represent a geographical location in 
# a map. 
# Messages
class Location
  include Yapper::Document

  attr_accessor :new_record

  # Relations
  has_many :visits

  field :name,        type: :string
  field :address,     type: :string
  field :latitude,    type: :float
  field :longitude,   type: :float
  field :radius,      type: :integer, :default => 25 
  
  def coordinate
    latitude.nil? && longitude.nil? ? nil : [latitude, longitude]     
  end

  def to_h
    {
      id: id,
      name: name,
      address: address,
      radius: radius,
      latitude: latitude,
      longitude: longitude
    }
  end

  def ==(location)
    return latitude == location.latitude && longitude == location.longitude
  end

  def !=(location)
    p "New Location #{location.latitude} #{location.longitude}"
    return latitude != location.latitude || longitude != location.longitude
  end

  class << self
    def [](index)
      all.to_a[index]
    end

    def size
      all.to_a.size
    end

    def delete_at(index)
      all.to_a.delete_at(index)
    end
  end
end

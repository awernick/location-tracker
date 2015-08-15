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
  field :label,       type: :string
  field :latitude,    type: :float
  field :longitude,   type: :float
  field :radius,      type: :integer, :default => 25 
  
  def coordinate
    [latitude, longitude]
  end

  def to_h
    {
      id: id,
      label: label,
      name: name,
      radius: radius,
      latitude: latitude,
      longitude: longitude
    }
  end

  def ==(location)
    return latitude == location.latitude && longitude == location.longitude
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

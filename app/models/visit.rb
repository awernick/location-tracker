class Visit
  include Yapper::Document

  belongs_to  :location

  field   :start_time,  type: :time,    default: proc {Time.now}
  field   :end_time,    type: :time,    default: proc {Time.now}
  field   :open,        type: :boolean, default: true

  def total_time
    (end_time - start_time) / 60 
  end

  def to_h
    {
      id: id,
      start_time:  start_time.to_s,
      end_time: end_time.to_s,
      open: open,
      location_id: location_id
    }
  end
end
class Visit
  include MotionModel::Model
  include MotionModel::ArrayModelAdapter

  DATA_STORE = 'visits.dat'

  belongs_to  :location

  columns     :_id         => {type: :string},
              :start_time  => {type: :date, default: Time.now},
              :end_time    => {type: :date, default: Time.now},
              :open        => {type: :boolean, default: true}

  def total_time
    (end_time - start_time) / 60 
  end

  def after_save(sender)
    Visit.save
  end

  def after_delete(sender)
    Visit.save
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

  class << self
    def load
      deserialize_from_file(DATA_STORE)
    end

    def save
      serialize_to_file(DATA_STORE)
    end
  end
end
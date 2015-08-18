class Logger
  attr_accessor :sink

  def initialize(sink)
    @sink = sink
  end

  def <<(output)
    @sink << output.to_s
  end

  class DeviceLogger
    def <<(info)
      NSLog(info)
    end
  end

  class StandardLogger
    def <<(info)
      p info
    end
  end
end

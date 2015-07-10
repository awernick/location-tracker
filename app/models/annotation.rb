class Annotation
  def initWithCoordinates(coordinate, title: title, subTitle: subtitle)
    @coordinate = coordinate
    @title = title
    @subtitle = subtitle

    self
  end

  # Manually specify getter/setters due to RubyMotion not translating
  # attr_* and define_method to Obj-C
  
  def coordinate 
    @coordinate
  end

  def coordinate=(coordinate) 
    @coordinate = coordinate 
  end

  def subtitle 
    @subtitle
  end

  def subtitle=(subtitle)
    @subtitle = subtitle
  end

  def title 
    @title
  end

  def title=(title) 
    @title = title
  end
end
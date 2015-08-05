class LocationDetailViewController < UIViewController
  def viewDidLoad
    super

    self.view.backgroundColor = UIColor.whiteColor
  end

  def initWithLocation(location)
    init
    return self
  end
end
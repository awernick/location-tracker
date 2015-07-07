class LocationTableViewCell < SWTableViewCell
  def initWithStyle(style, reuseIdentifier: reuseIdentifier)
    super

    rmq.stylesheet = LocationTableViewCellStylesheet
    rmq(self).apply_style :location_cell
    p self.detailTextLabel.text = 'Test'
    return self
  end
end
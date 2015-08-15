describe 'visits controllers' do
  before do
    Visit.all.each(&:destroy)
    Location.all.each(&:destroy)

    @client = NullJSONClient.new
    @controller = VisitsController.new(@client)

    @location = Location.create(
      :label      => 'Test', 
      :longitude  => -106.485696,
      :latitude   => 31.769714,
      :radius     => 100
    )
  end

  describe 'open visits' do
    it 'should return all open visits' do
      # Open visits
      5.times { Visit.create({start_time: Time.now, end_time: Time.now, open: true, location_id: @location.id})}
      4.times { Visit.create({start_time: Time.now, end_time: Time.now, open: true, location_id: BSON::ObjectId.generate})}

      # Closed Visits
      6.times { Visit.create({start_time: Time.now, end_time: Time.now, open: false, location_id: @location.id})}

      Visit.all.to_a.size.should.equal 15
      open_visits = @controller.open_visits
      open_visits.length.should.equal 9
      open_visits.each {|visit| visit.open.should.equal true }

      # Close all visits
      open_visits.each {|visit| visit.open = false; visit.save }
      @controller.open_visits.length.should.equal 0
    end

    it 'should return open visits for location' do
      5.times { Visit.create({start_time: Time.now, end_time: Time.now, open: true, location_id: @location.id})}
      6.times { Visit.create({start_time: Time.now, end_time: Time.now, open: false, location_id: @location.id})}

      Visit.all.to_a.size.should.equal 11
      open_visits = @controller.open_visits(@location)
      open_visits.length.should.equal 5
      open_visits.each {|visit| visit.open.should.equal true }
    end

    it "should close location's visits" do
      5.times { Visit.create({start_time: Time.now, end_time: Time.now, open: true, location_id: @location.id})}
      6.times { Visit.create({start_time: Time.now, end_time: Time.now, open: false, location_id: @location.id})}

      Visit.all.to_a.size.should.equal 11

      @controller.open_visits(@location).length.should.equal 5 # Total open visits
      @controller.close_location_visits(@location)  # Close all open visits
      @controller.open_visits(@location).length.should.equal 0 # Verify all have been closed
    end
  end

  describe 'when entering a location' do
    it 'should start a visit' do
      Visit.all.to_a.should.be.empty
    
      @controller.start_visit(@location)

      Visit.all.to_a.size.should.equal 1
    end

    it 'should not start visit if client result has error' do
      @client.error = true # Set error in the client response

      Visit.all.to_a.should.be.empty
      @controller.start_visit(@location)

      Visit.all.to_a.size.should.equal 0
    end

    it 'should close all previous open visits for location' do
      Visit.all.to_a.should.be.empty

      5.times { Visit.create({start_time: Time.now, end_time: Time.now, open: true, location_id: @location.id})}

      @controller.open_visits(@location).size.should.equal 5 # Total open visits

      @controller.start_visit(@location)

      open_visits = @controller.open_visits(@location)
      open_visits.size.should.equal 1
      open_visits.first.location_id.should.equal @location.id

      # Ensure that previous visits where handled correctly
      closed_visits = @location.visits.to_a.select {|visit| visit.open == false }
      closed_visits.size.should.equal 5
      closed_visits.each {|visit| visit.end_time.should.equal visit.start_time }
    end

    it 'should sync visit id with server object id' do
      visit = @controller.start_visit(@location)
      visit.id.should.equal @client.object['_id']
    end
  end

  describe 'when exiting a location' do
    it "should close all visits" do
      5.times { Visit.create({start_time: Time.now, end_time: Time.now, open: true, location_id: @location.id}) }
      6.times { Visit.create({start_time: Time.now, end_time: Time.now, open: false, location_id: @location.id})}

      Visit.all.to_a.size.should.equal 11

      @controller.open_visits(@location).size.should.equal 5 

      @controller.end_visit(@location)

      @controller.open_visits(@location).size.should.equal 0
    end
  end
end
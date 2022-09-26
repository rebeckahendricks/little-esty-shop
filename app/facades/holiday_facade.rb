class HolidayFacade
  def self.all_holidays
    data = HolidayService.get_holidays
    data.map do |holiday_data|
      Holiday.new(holiday_data)
    end
  end
end

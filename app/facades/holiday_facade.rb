require './app/services/holiday_service'

class HolidayFacade
  def self.all_holidays
    data = HolidayService.get_holidays
    data.map do |holiday_data|
      Holiday.new(holiday_data)
    end
  end

  # def self.next_three_holidays
  #   data = HolidayService.get_holidays
  #   x = data.3.times do |holiday_data|
  #     Holiday.new(holiday_data)
  #   end
  # end
end

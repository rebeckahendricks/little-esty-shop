require 'httparty'
require 'json'

class HolidayService
  def self.get_holidays
    get_uri("https://date.nager.at/api/v3/NextPublicHolidays/US")
  end

  def self.get_uri(uri)
    response = HTTParty.get(uri)
    parsed = JSON.parse(response.body, symbolize_names: true)
  end
end

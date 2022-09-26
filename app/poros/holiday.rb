class Holiday
  attr_reader :date,
              :name

  def initialize(data)
    @name = data[:name]
    @date = data[:date]
  end
end

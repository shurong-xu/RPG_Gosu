class GameDate
  attr_reader :year, :month, :day
  attr_accessor :speed, :tick
  def initialize
    @year = 2018
    @month = 11
    @day = 14
    @tick = 0
    @speed = 0
  end

  def update
    @tick += @speed
    if @tick == 2000
      @tick = 0
      @day += 1
      if @day == 31
        @day = 1
        @month += 1
        if @month == 13
          @month = 1
          @year += 1
        end
      end
    end
  end

  def to_string
    str = "#{@year}年"
    if @month == 1
      str += '正月'
    elsif @month <= 10
      str += num_to_char(@month) + '月'
    elsif @month == 11
      str += '冬月'
    elsif @month == 12
      str += '腊月'
    end
    str += '初' if @day <= 10
    str += num_to_char(@day)
    return str
  end

  def num_to_char(num)
    chars = ['十', '一', '二', '三', '四', '五', '六', '七', '八', '九']
    res = ''
    first = num / 10
    if first == 1
      res += chars[0]
    elsif first != 0
      res += chars[first] + chars[0]
    end
    second = num % 10
    res += chars[second] if second != 0
    return res
  end
end
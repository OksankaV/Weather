class RangeWeather

    TEMPERATURE = "temperature"
    PRESSURE = "pressure"
    WIND_POWER = "wind_power"
    HUMIDITY = "humidity"
    DAY = "day"
    NIGHT = "night"
    
    attr_accessor :hash
    
    def initialize
        @hash = {}
    end 
    
    def push(date, weather)
            if @hash.has_key?(date) || weather == nil
                warn "Error"
                #TODO  
            else
                @hash[date] = weather  
            end 
    end

    def [] (date)
         @hash[date]
    end
    
    def detect_item (day_data, hour, key)
            if @hash.index(day_data).hour == hour 
                return day_data[key].to_f  
            end      
    end
    
    def average(column,day_night)
        sum_plus = 0.0
        kilk = 0
        @hash.each_value do |day_data| 
            if day_night == DAY 
                if @hash.index(day_data).hour > 6 && day_data.has_key?(column)
                    sum_plus += detect_item(day_data, @hash.index(day_data).hour, column)
                    kilk += 1                   
                end
            end
            if day_night == NIGHT
                if @hash.index(day_data).hour <= 6 && day_data.has_key?(column)
                    sum_plus += detect_item(day_data, @hash.index(day_data).hour, column)                   
                    kilk += 1
                end
            end 
        end
        return sum_plus/kilk       
    end
    
    def max(column,day_night)
        max_value = -1000
        @hash.each_value do |day_data|
            if day_night == DAY 
                if @hash.index(day_data).hour > 6 && day_data.has_key?(column)
                    value = detect_item(day_data, @hash.index(day_data).hour, column)
                    if value.to_i > max_value.to_i
                        max_value = value 
                    end                    
                end
            end
            if day_night == NIGHT
                if @hash.index(day_data).hour <= 6 && day_data.has_key?(column)
                    value = detect_item(day_data, @hash.index(day_data).hour, column)
                    if value.to_i > max_value.to_i
                        max_value = value 
                    end 
                end
            end   
        end
                    
        return max_value
    end
    
    def min(column,day_night)
        min_value = 1000
        @hash.each_value do |day_data|
            if day_night == DAY 
                if @hash.index(day_data).hour > 6 && day_data.has_key?(column)
                    value = detect_item(day_data, @hash.index(day_data).hour, column)
                    if value.to_i < min_value.to_i
                        min_value = value 
                    end                    
                end
            end
            if day_night == NIGHT
                if @hash.index(day_data).hour <= 6 && day_data.has_key?(column)
                    value = detect_item(day_data, @hash.index(day_data).hour, column)
                    if value.to_i < min_value.to_i
                        min_value = value 
                    end 
                end
            end   
        end
        return min_value
    end
    
    def average_day_temperature
        average(TEMPERATURE, DAY)    
    end
    
    def average_night_temperature
        average(TEMPERATURE, NIGHT)
    end

    def average_day_night_temperature
        (average_day_temperature + average_night_temperature) / 2
    end
    
    def average_day_pressure
        average(PRESSURE, DAY)
    end

    def average_night_pressure
        average(PRESSURE, NIGHT)
    end

    def average_day_night_pressure
        (average_day_pressure + average_night_pressure) / 2
    end
    
    def average_day_wind
        average(WIND_POWER, DAY)
    end

    def average_night_wind
        average(WIND_POWER, NIGHT)
    end

    def average_day_night_wind
        (average_day_wind + average_night_wind) / 2
    end
    
    def average_day_humidity
        average(HUMIDITY, DAY)
    end

    def average_night_humidity
        average(HUMIDITY, NIGHT)
    end

    def average_day_night_humidity
        (average_day_humidity + average_night_humidity) / 2
    end
    
    def max_day_temperature
        max(TEMPERATURE, DAY)
    end

    def max_night_temperature
        max(TEMPERATURE, NIGHT)
    end

    def max_day_night_temperature
        [max_day_temperature, max_night_temperature].max
    end
    
    def max_day_pressure
        max(PRESSURE, DAY)
    end

    def max_night_pressure
        max(PRESSURE, NIGHT)
    end

    def max_day_night_pressure
        [max_day_pressure, max_night_pressure].max
    end
    
    def max_day_wind
        max(WIND_POWER, DAY)
    end

    def max_night_wind
        max(WIND_POWER, NIGHT)
    end

    def max_day_night_wind
        [max_day_wind, max_night_wind].max
    end
    
    def max_day_humidity
        max(HUMIDITY, DAY)
    end

    def max_night_humidity
        max(HUMIDITY, NIGHT)
    end

    def max_day_night_humidity
        [max_day_humidity, max_night_humidity].max
    end
    
    def min_day_temperature
        min(TEMPERATURE, DAY)
    end

    def min_night_temperature
        min(TEMPERATURE, NIGHT)
    end

    def min_day_night_temperature
        [min_day_temperature, min_night_temperature].min
    end
    
    def min_day_pressure
        min(PRESSURE, DAY)
    end

    def min_night_pressure
        min(PRESSURE, NIGHT)
    end

    def min_day_night_pressure
        [min_day_pressure, min_night_pressure].min
    end
    
    def min_day_wind
        min(WIND_POWER, DAY)
    end

    def min_night_wind
        min(WIND_POWER, NIGHT)
    end

    def min_day_night_wind
        [min_day_wind, min_night_wind].min
    end
    
    def min_day_humidity
        min(HUMIDITY, DAY)
    end

    def min_night_humidity
        min(HUMIDITY, NIGHT)
    end

    def min_day_night_humidity
        [min_day_humidity, min_night_humidity].min
    end

    
end

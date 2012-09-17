class WeatherRecord
    
    Hour = 0
    Phenomenon = 1
    Temperature = 2
    Wind_direction =3
    Wind_power = 4 
    Humidity = 5
    Cloudiness = 5
    Pressure = 6
    
    attr_accessor :hash
    
    def initialize(day_data)
        @hash = {}
        if day_data[Hour] != "" && day_data[Hour] != nil 
            @hash["hour"] = day_data[Hour].to_i
        end   
        if day_data[Phenomenon] != "" && day_data[Phenomenon] != nil 
            @hash["phenomenon"] = day_data[Phenomenon].to_s
        end
        if day_data[Temperature] != "" && day_data[Temperature] != nil 
            @hash["temperature"] = day_data[Temperature]
        end    
        if day_data[Wind_direction] != "" && day_data[Wind_direction] != nil
            @hash["wind_direction"] = day_data[Wind_direction].to_s
        end   
        if day_data[Wind_power] != "" && day_data[Wind_power] != nil 
            @hash["wind_power"] = day_data[Wind_power]
        end    
        if day_data[Humidity] != "" && day_data[Humidity] != nil
            if day_data[Humidity].to_s =~ /\d+/
                @hash["humidity"] = day_data[Humidity]
            end
            if day_data[Cloudiness].to_s =~ /\D+/
                @hash["cloudiness"] = day_data[Cloudiness].to_s
            end
        end
        if day_data[Pressure] != "" && day_data[Pressure] != nil
            @hash["pressure"] = day_data[Pressure]
        end    

    end
end


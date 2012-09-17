class Meteo

    require 'net/http'
    require 'weather_record'
    require 'range_weather'
    require 'uri'
    require 'city_code'
    require 'sqlite3'
    $KCODE = 'UTF-8'

    Hour = "hour"
    Phenomenon = "phenomenon"
    Temperature = "temperature"
    Wind_direction = "wind_direction"
    Wind_power = "wind_power" 
    Humidity = "humidity"
    Pressure = "pressure"
    Path = "weather.db"   
    
    def initialize
        @db = SQLite3::Database.new(Path)
    end
    

    def create_data(city_code, start_date, end_date)
        result =  RangeWeather.new

            @db.execute("select * from WeatherData where city_code=(?) and weather_date>=(?) and weather_date<=(?)", [city_code, start_date.strftime("%Y-%m-%d %H:%M:%S"), end_date.strftime("%Y-%m-%d %H:%M:%S")]).each do |row|
                weather_data = WeatherRecord.new([row[2],row[3],row[4],row[5],row[6],row[7],row[8]]).hash
                time = (row[1].split(/-|\s+|:/))
                result.push(Time.gm(time[0],time[1],time[2],time[3]), weather_data)
            end
        return result      
    end
    
    def parse_meteo(date_value,city_code,region_code)
                
        year = date_value.year.to_s
        month_number = date_value.mon.to_s
        day_number = date_value.day.to_s
        hour = date_value.hour.to_s 
                
        temp_data = []
        wind_data = []
        humidity_data = []
        pressure_data = [] 

        params = {:day => day_number, :enter_key_ok => "пошук", :mouns => month_number, :obl => region_code, :town => city_code, :year => year}

        city_url = URI("http://meteo.gov.ua/ua/past_ukr/" + region_code)
        if ENV['http_proxy'] != nil
            ur = URI.split(ENV['http_proxy'])
            proxy_addr = ur[2]
            proxy_port = ur[3]
        end
        res = Net::HTTP::Proxy(proxy_addr,proxy_port).post_form(city_url, params)       
        if res.is_a?(Net::HTTPSuccess)
            page = res.body
            page.gsub!(/<img\s+width="50px"\s+src="[^"]*"\s+border="0">/,"")
            if page.scan(/<span\s+class="txt_for_bl">на\s*<b>(\d+)\s*год.<\/b><\/span><br\s*\/>\s*<br\s*\/><span class="txt_for_bl">([^<]*)<\/span>\s+<br\s*\/><br\s*\/><span\s+class="txt_blue">([^<]*)<\/span>/).each do  
                |some_data|
                    some_data.each do |day_value|
                        if day_value == nil 
                            some_data[some_data.index(day_value)] = "" 
                        end
                    end      
                    temp_data.push(some_data)
                end
            end
            if page.scan(/<span class="txt_for_bl"><b>Вітер:<\/b><\/span><br\s+\/>\s+<span class="txt_for_bl">([^<]+)?<\/span><br \/>\s+<span class="txt_for_bl"><b>(\d+)?м\/с<\/b><\/span>/).each do  
                |some_data| 
                    some_data.each do |day_value|
                        if day_value == nil 
                            some_data[some_data.index(day_value)] = "" 
                        end
                    end 
                    wind_data.push(some_data)
                end
            end
            if page.scan(/<span class="txt_for_bl"><b>Вологість:<\/b><\/span><br\s+\/>\s+<span class="txt_for_bl">(\d+)?%<\/span>/).each do  
                |some_data| 
                    some_data.each do |day_value|
                        if day_value == nil 
                            some_data[some_data.index(day_value)] = "" 
                        end
                    end 
                    humidity_data.push(some_data)
                end
            end
            if page.scan(/<span class="txt_for_bl"><b>Тиск:<\/b><\/span><br\s+\/>\s+<span class="txt_for_bl">(\d+)?\s*мм<\/span>/).each do  
                |some_data| 
                     some_data.each do |day_value|
                         if day_value == nil 
                             some_data[some_data.index(day_value)] = "" 
                         end
                     end 
                     pressure_data.push(some_data)
                end
            end
            all_day = []
            for k in 0..7 do
                all_day[k] = temp_data[k] + wind_data[k] + humidity_data[k] + pressure_data[k]
                if all_day[k][0].to_s == "24"
                    all_day[k][0] = "0"
                end
            end  

            
                #if @db.execute("select * from WeatherData where city_code=(?) and weather_date=(?)", [city_code, date_value.to_s]).include?(city_code) == false && @db.execute("select * from WeatherData where city_code=(?) and weather_date=(?)", [city_code, date_value.to_s]).include?(date_value.to_s) == false
            @db.execute("begin transaction")    
            k = 0
            for k in 0..7 do
                    cache_date_value = Time.gm(year,month_number,day_number,all_day[k][0].to_s)
                    hour_hash = WeatherRecord.new(all_day[k]).hash
                    @db.execute("insert into WeatherData(city_code, weather_date, hour, phenomenon, temperature, wind_direction, wind_power, humidity, pressure) values(?,?,?,?,?,?,?,?,?)", [city_code, cache_date_value.strftime("%Y-%m-%d %H:%M:%S"), hour_hash[Hour], hour_hash[Phenomenon], hour_hash[Temperature], hour_hash[Wind_direction], hour_hash[Wind_power], hour_hash[Humidity], hour_hash[Pressure]])              
                #end
            end 
            @db.execute("commit")

        else
            warn res.message 
            if res.is_a?(Net::HTTPRedirection) 
                location = res['location']
                warn "redirected to #{location}"
            end     
            exit
        end     
          
    end
  

    def get_range_weather (city_code, start_date, end_date)        
        
        region_code = 1
        CityHash.each do |key1,value1|
                if value1.include?(value1.index(city_code.to_s))
                    region_code = CityHash.index(value1)
                end
        end
            
        db_array = @db.execute("select weather_date from WeatherData where city_code=(?) and weather_date>=(?) and weather_date<=(?)", [city_code, start_date.strftime("%Y-%m-%d 0"), end_date.strftime("%Y-%m-%d 21")]).flatten
        
        db_array.each do |date| 
            time = (date.split(/-|\s+|:/))
            db_array[db_array.index(date)] = Time.gm(time[0],time[1],time[2],time[3])
        end

        date_value = Time.gm(start_date.year,start_date.mon,start_date.day) 
        while date_value <= end_date
            if db_array.include?(date_value) == false
                parse_meteo(date_value,city_code,region_code)
            end         
            date_value += (60*60*24)
        end

        
        return create_data(city_code, start_date, end_date)    
              
    end
    
   
end    


require 'rubygems'
require 'sinatra'
require 'city_code'
require 'meteo'

    Hour = "hour"
    Phenomenon = "phenomenon"
    Temperature = "temperature"
    Wind_direction = "wind_direction"
    Wind_power = "wind_power" 
    Humidity = "humidity"
    Pressure = "pressure"
 
    

get '/' do
  erb :create_form
end

get '/statictic' do
    @start_date_statictic = Time.gm(params[:start_year],params[:start_month],params[:start_day],params[:start_hour])
    @end_date_statictic = Time.gm(params[:end_year],params[:end_month],params[:end_day],params[:end_hour])
    @city_statictic = params[:region]
    meteo = Meteo.new
    @weather_statictic =  meteo.get_range_weather(params[:region], @start_date_statictic, @end_date_statictic)
    erb :create_form
    erb :show_statictic
end

get '/history' do
    @date_today = Time.now
    year = 2002
    
    all_days = {}
    @city_history = params[:region]
    meteo = Meteo.new
    while year < @date_today.year
        @start_date_history = Time.gm(year,@date_today.month,@date_today.day,0)
        @end_date_history = Time.gm(year,@date_today.month,@date_today.day,21)
        all_days[year] =  meteo.get_range_weather(@city_history, @start_date_history, @end_date_history)
        year += 1
    end  
    
    def max(max_value,check_value) 
        if max_value <= check_value
            max_value = check_value
        end
        return max_value
    end

    def min(min_value,check_value) 
        if min_value >= check_value
            min_value = check_value
        end
        return min_value
    end
   
    def get_year(all_years,year,weather,key,check_value)
        weather.hash.each_value do |value|
            if value[key] == check_value
                all_years.push(year.to_s)
                break
            end
        end
        return all_years
    end    

    @max_temp = -100
    @max_wind = -1
    @max_humidity = -1
    @min_temp = 100
    @min_wind = 100
    @min_humidity = 101
    @min_temp_year = []
    @min_wind_year = []
    @min_humidity_year = []
    @max_temp_year = []
    @max_wind_year = []
    @max_humidity_year = []
    all_days.each do |year,weather|
        @max_temp = max(@max_temp,weather.max_day_night_temperature)
        @max_wind = max(@max_wind,weather.max_day_night_wind)
        @max_humidity = max(@max_humidity,weather.max_day_night_humidity)
        @min_temp = min(@min_temp,weather.min_day_night_temperature)
        @min_wind = min(@min_wind,weather.min_day_night_wind)
        @min_humidity = min(@min_humidity,weather.min_day_night_humidity)
    end  
    all_days.each do |year,weather|
        @max_temp_year = (get_year(@max_temp_year,year,weather,Temperature, @max_temp))
        @max_wind_year = (get_year(@max_wind_year,year,weather,Wind_power,@max_wind))
        @max_humidity_year = (get_year(@max_humidity_year,year,weather,Humidity,@max_humidity))
        @min_temp_year = (get_year(@min_temp_year,year,weather,Temperature, @min_temp))
        @min_wind_year = (get_year(@min_wind_year,year,weather,Wind_power,@min_wind))
        @min_humidity_year = (get_year(@min_humidity_year,year,weather,Humidity,@min_humidity))
    end  
    
    @phenomenon_hash = {}
    def get_phenomenon(word,year,value)
        if word =~ value.to_s
            if @phenomenon_hash.has_key?(year.to_s) == false
                @phenomenon_hash[year.to_s] = value.to_s
            else
                if word =~ @phenomenon_hash[year.to_s].to_s
                    true                     
                else
                    @phenomenon_hash[year.to_s] = @phenomenon_hash[year.to_s].to_s + ", " + value.to_s   
                end 
            end    
        end 
    end
    all_days.each do |year,weather|
        weather.hash.each_value do |value|
            get_phenomenon(/дощ/,year,value[Phenomenon]) 
            get_phenomenon(/гроза/,year,value[Phenomenon]) 
            get_phenomenon(/димка/,year,value[Phenomenon]) 
            get_phenomenon(/сніг/,year,value[Phenomenon]) 
            get_phenomenon(/мряка/,year,value[Phenomenon]) 
        end
    end  

    erb :show_history
end


__END__

@@ create_form
<html>
    <head>
        <title>Oksanka's Weather</title>
        <meta charset="utf-8" />
    </head>
    <body>
        <form method="GET"  action="statictic">
            <select name="region">     
                <% for i in 1..25 %>
                    <optgroup label=<%= RegionHash.index(i.to_s)%>>
                        <% CityHash[i.to_s].each do |key,value|%>
                            <option name="city" value=<%= value%>><%= key%></option>
                        <% end %> 
                    </optgroup>
                <% end %>  
            </select>
            <select name="start_year">   
                <% for i in 2002..Time.now.year %>
                    <option value=<%= i%>><%= i%></option>
                <% end %>  
            </select>
            <select name="start_month">  
                <% for i in 1..12 %>
                    <% time = Time.gm(2000,i).strftime("%B") %>
                    <option value=<%= i%>><%= time%></option>
                <% end %>  
            </select>
            <select name="start_day">      
                <% for i in 1..31 %>
                    <option value=<%= i%>><%= i%></option>
                <% end %>  
            </select>   
            <select name="start_hour">  
                <%i=0%>  
                <% while i<23 %>
                    <option value=<%= i%>><%= i%></option>
                    <% i += 3%>
                <% end %>  
            </select>  
            <select name="end_year">   
                <% for i in 2002..Time.now.year %>
                    <option value=<%= i%>><%= i%></option>
                <% end %>  
            </select>
            <select name="end_month">  
                <% for i in 1..12 %>
                    <% time = Time.gm(2000,i).strftime("%B") %>
                    <option value=<%= i%>><%= time%></option>
                <% end %>  
            </select>
            <select name="end_day">      
                <% for i in 1..31 %>
                    <option value=<%= i%>><%= i%></option>
                <% end %>  
            </select>   
            <select name="end_hour">
                <%i=0%>  
                <% while i<23 %>
                    <option value=<%= i%>><%= i%></option>
                    <% i += 3%>
                <% end %>  
            </select>  
            <input name="Ok" type="submit" value="Ok" ></input>         

        </form>  
        <form method="GET"  action="history">
            <select name="region">     
                <% for i in 1..25 %>
                    <optgroup label=<%= RegionHash.index(i.to_s)%>>
                        <% CityHash[i.to_s].each do |key,value|%>
                            <option name="city" value=<%= value%>><%= key%></option>
                        <% end %> 
                    </optgroup>
                <% end %>  
            </select>
            <input name="Ok" type="submit" value="Ok" ></input>         

        </form>  
    </body>
</html>

@@ show_statictic
<html>
    <head>
        <title>WEATHER</title>
    </head>
    <body>
    <p>
        <%CityHash.each do |key1,value1|%>
            <%if value1.include?(value1.index(@city_statictic))%>
                <%city = value1.index(@city_statictic)%>
                    <%=city%>
            <%end%>
        <%end%>
    </p>
    <p>From <%=@start_date_statictic.strftime("%Y-%m-%d %H:%M:%S")%> to <%=@end_date_statictic.strftime("%Y-%m-%d %H:%M:%S")%></p> 
    <p>Average day temperature = <%=@weather_statictic.average_day_temperature%></p>
    <p>Average night temperature = <%=@weather_statictic.average_night_temperature%></p>
    <p>Average day wind = <%=@weather_statictic.average_day_wind%></p>
    <p>Average day pressure = <%=@weather_statictic.average_day_pressure%></p>

    <p>Max night temperature = <%=@weather_statictic.max_night_temperature%></p>
    <p>Max night wind = <%=@weather_statictic.max_night_wind%></p>
    <p>Max night pressure = <%=@weather_statictic.max_night_pressure%></p>

    <p>Min night temperature = <%=@weather_statictic.min_night_temperature%></p>
    <p>Min night wind = <%=@weather_statictic.min_night_wind%></p>
    <p>Min night pressure = <%=@weather_statictic.min_night_pressure%></p>
 

    </body>
</html>

@@ show_history
<html>
    <head>
        <title>WEATHER</title>
    </head>
    <body>
    <p>
        <%CityHash.each do |key1,value1|%>
            <%if value1.include?(value1.index(@city_history))%>
                <%city = value1.index(@city_history)%>
                    <%=city%>
            <%end%>
        <%end%>
    </p>
    
    <p>Сьогодні <%=@date_today.strftime("%d-%m-%Y")%></p>
    
    <p>Максимальна температура <%=@max_temp.to_s + "°C в " + @max_temp_year.sort.join(",")%></p>
    <p>Мінімальна температура <%=@min_temp.to_s + "°C в " + @min_temp_year.sort.join(",")%></p>
    
    <p>Максимальний вітер <%=@max_wind.to_s + "m/s в " + @max_wind_year.sort.join(",")%></p>
    <p>Мінімальний вітер <%=@min_wind.to_s + "m/s в " + @min_wind_year.sort.join(",")%></p>
    
    <p>Максимальна вологість <%=@max_humidity.to_s + "% в " + @max_humidity_year.sort.join(",")%></p>
    <p>Мінімальна вологість <%=@min_humidity.to_s + "% в " + @min_humidity_year.sort.join(",")%></p>
    <p>Опади</p>
    <%@phenomenon_hash.each_pair do |key,value| %>
        <p><li><%=value.to_s + " в " + key.to_s%></li></p>
    <%end%>

    </body>
</html>



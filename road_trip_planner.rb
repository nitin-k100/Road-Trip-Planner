    require 'uri'
    require 'net/http'
    require 'json'
    require 'time'


    class RoadTripPlanner
        def initialize 
            while (true)    
                starting_point,starting_time_input,ending_point = input_taken_from_user
                starting_time,date = date_time(starting_time_input)
                sleep_time = sleeping_period(date,starting_time)  
                transport_string,public_transport = transport_details(choosing_transport_mode)
                response = url_request(starting_point,ending_point,transport_string)
                
                if(check_for_correct_route_entry(response))
                    trip_output(response,starting_time,sleep_time)
                end

                if(choice_for_program_flow)
                    break
                end
            end
        end
        
        
        
        
        
        
        
        

        
        private 


        def input_taken_from_user
            puts("If the plan of your trip is to be executed right now then type \"YES\" below or if you need a customized trip planned for future then type \"NO\":- ")
            choice_trip = gets.chomp.upcase
            
            if(choice_trip =="YES")
                arr1 = Time.new
            elsif(choice_trip=="NO")
                starting_time,starting_date = checking_for_nil("Starting time in hh/mm/ss (24 hour format):- "),checking_for_nil("Date of the trip in dd/mm/yyyy format:- ")
                arr1,arr2 = starting_date.split("/"),starting_time.split("/")
                arr1 += arr2
            else
                input_taken_from_user
            end
            
            starting_location = checking_for_nil("Starting location:- ")
            ending_location = checking_for_nil("Ending location:- ")
            return starting_location,arr1,ending_location
        end 
        

        def date_time(starting_time_input)
            if(starting_time_input.is_a?(Array))
                date = []
                starting_time = Time.new(starting_time_input[2],starting_time_input[1],starting_time_input[0],starting_time_input[3],starting_time_input[4],starting_time_input[5],"+05:30")
                date.push(starting_time_input[2],starting_time_input[1],starting_time_input[0])
            else
                date = []
                date_time_input = starting_time_input.to_s.split(" ")
                date_extract = date_time_input[0].split("-")
                date.push(date_extract[0],date_extract[1],date_extract[2])
                starting_time = starting_time_input
            end
            return [starting_time,date]
        end


        def sleeping_period(date,starting_time)
            puts("Do you want to pause your trip for certain period of time, if yes enter \"1\" (or) else enter \"0\" ")
            sleep_choice = gets.chomp.to_i
            if(sleep_choice==1)
                puts("Enter the interval of your day where you want to pause/snooze the trip by seperating the start and end time with \"-\" , format hh/mm/ss-hh/mm/ss  (24 hour fomat)")
                array,sleep_timer,pause_time = gets.chomp.split("-"),[],[]
                array.each do |ele|
                    arr = ele.split("/")
                    sleep_timer+=arr
                end
                pause_time = []
                if sleep_timer[0]>sleep_timer[3]
                    time_obj1 = Time.new(date[0],date[1],date[2],sleep_timer[0],sleep_timer[1],sleep_timer[2],"+05:30")
                    time_obj2 = Time.new(date[0],date[1],(date[2].to_i)+1,sleep_timer[3],sleep_timer[4],sleep_timer[5],"+05:30")
                    pause_time.push(time_obj1,time_obj2)
                else
                    time_obj1 = Time.new(date[0],date[1],date[2],sleep_timer[0],sleep_timer[1],sleep_timer[2],"+05:30")
                    time_obj2 = Time.new(date[0],date[1],date[2],sleep_timer[3],sleep_timer[4],sleep_timer[5],"+05:30")
                    pause_time.push(time_obj1,time_obj2)
                end
                return pause_time
            end
        end


        def choosing_transport_mode
            puts "Enter your required modes of transport \n Enter 1.For choosing driving \n Enter 2.For choosing bicycling \n Enter 3.For choosing walking \n Enter 4.For choosing public transportation"
            transport_option = gets.chomp.to_i  
            case transport_option
            when 1
                transport_mode = "driving"
            when 2
                transport_mode = "bicycling"
            when 3
                transport_mode = "walking"
            when 4
                transport_mode = "transit"
                transit_mode = public_transport_mode
                return [transport_mode,transit_mode]
            else
                choosing_transport_mode
            end
        end


        def public_transport_mode 
            puts "Enter your required modes of public transport \n Enter 1.For choosing bus \n Enter 2.For choosing subway \n Enter 3.For choosing train \n Enter 4.For choosing tram \n Enter 5.For choosing rail"
            transport_option = gets.chomp.to_i 
            case transport_option
            when 1
                transport_mode = "bus"
            when 2
                transport_mode = "subway"
            when 3
                transport_mode = "train"
            when 4
                transport_mode = "tram"
            when 5
                transport_mode = "rail"
            else
                public_transport_mode
            end
            
        end


        def transport_details(transport_mode)
            if (transport_mode.is_a?(Array))
                transport_string = "&mode=#{transport_mode[0]}&transit_mode=#{transport_mode[1]}"
                public_transport = true
            else 
                transport_string = "&mode=#{transport_mode}"
                public_transport = false
            end
            return transport_string,public_transport
        end


        def url_request(starting_point,ending_point,transport_string)
            url = URI("https://maps.googleapis.com/maps/api/directions/json?origin=#{starting_point}&destination=#{ending_point}#{transport_string}&key=#{enter_the_api_key_for_directions_api}")
            https = Net::HTTP.new(url.host, url.port)
            https.use_ssl = true
            response = JSON.parse(https.request(Net::HTTP::Get.new(url)).read_body)
        end

        
        def check_for_correct_route_entry(result) 
            if (result["routes"].nil? || result["routes"].size==0)
                puts("The status of the trip is #{result["status"]}")
                unless(result["available_travel_modes"].nil? || result["available_travel_modes"].size==0)
                    puts("The available travel modes are:- \n #{result["available_travel_modes"]}")
                    puts()
                end
                return false
            end
            true 
        end 


        def trip_output(response,starting_time,sleep_time)
            route_details = response["routes"][0]["legs"][0]
            start_address,end_address,journey_duration,journey_distance = route_details["start_address"],route_details["end_address"],route_details["duration"]["text"],route_details["distance"]["text"]
            puts()
            puts()
            puts("Trip starts from #{start_address}")
            puts ("Trip ends at #{end_address}")
            puts ("The starting date and time of the trip are #{starting_time}")
            puts("Distance for the journrey is #{journey_distance}")
            puts ("Time taken for the journey is #{journey_duration}")
            puts()
            puts("The steps to be followed to reach the destination are given below:-")
            puts()
            start_time, end_time = starting_time, starting_time 
            route_details["steps"].each_with_index do |ele,count|
                trip_duration = ele["duration"]["value"]
                end_time += trip_duration
                if(not(sleep_time.nil?))
                    if(start_time>sleep_time[0] && start_time<sleep_time[1]) || (end_time>sleep_time[0] && end_time<sleep_time[1])
                    start_time = sleep_time[1]
                    end_time = (start_time+trip_duration)
                    sleep_time[0],sleep_time[1] = sleep_time[0]+(24*60*60),sleep_time[1]+(24*60*60)
                    end
                end
                puts (" ->Step #{count+1}")
                puts (" ->Distance to be covered #{ele["distance"]["text"]}")
                puts (" ->Time interval of this sub journey #{start_time} to #{end_time} with a duration of #{time_duration(trip_duration)}")
                start_time = end_time
                puts printing_text(" ->Instructions:- #{ele["html_instructions"]}")
                puts ()   
            end
        end

        
        def printing_text(string)
            arr,flag,str = string.split(""),0,""
            arr.each do |ele|
                if(ele=="<")
                    flag = 1
                elsif(flag==0)
                    str+=ele
                elsif(ele==">")
                    flag=0
                end
            end
            str  
        end


        def choice_for_program_flow 
            puts "Enter your choice \n 1.To continue searching for other trips \n 2.Exit the program"
            choice = gets.chomp.to_i
            if (choice == 2)
                flag = true
            elsif (choice == 1)
                flag = false
            else
                choice_for_program_flow
            end
        end


        def checking_for_nil(str)
            puts "Enter your #{str}"
            ele = gets.chomp  
            if(not(ele.nil?) && ele.size>0)
                return ele
            else 
                checking_for_nil(ele)
            end
        end


        def time_duration(time)
            minutes = time/60
            if minutes>=60
                return "#{(minutes/60).floor}hours #{minutes%60}minutes"
            elsif(minutes<1)
                return "#{time} seconds"
            elsif(minutes>=1 && minutes<60)
                return "#{(time/60).floor}minutes #{time%60}seconds"
            end
        end
    end

    RoadTripPlanner.new

#
#  AppDelegate.rb
#  Critical Mass
#
#  Created by Chris Oliver on 10/13/11.
#  Copyright 2011 Chris Oliver. All rights reserved.
#

class AppDelegate
    attr_accessor :window, :power_source_label, :status_label, :status_detail_label, :battery_percent_label, :battery_level
    
    def applicationDidFinishLaunching(a_notification)
        window.level = NSFloatingWindowLevel
        @hide = 4
        
        tick
        @timer = NSTimer.scheduledTimerWithTimeInterval 1, target:self, selector: :tick, userInfo:nil, repeats:true

    end
    
    def tick
        # Hide the window after 
        @hide -= 1 if @hide >= 0
        window.orderOut self if @hide == 0
        
        status = battery_status
        percent = status[:percent]
        
        battery_level.setFloatValue percent.to_f
        
        power_source_label.stringValue = status[:source]
        battery_percent_label.stringValue = "#{percent}% " + full_or_remaining(status[:status])
        
        
        if status[:status] == "discharging" and percent.to_i <= 5
            status_label.stringValue = "Low battery"
            status_detail_label.stringValue = "Quick! Hurry up and plug in!"
            window.orderFront self
        elsif status[:source] == "AC Power" and @hide < 0 # no longer starting up
            status_label.stringValue = "Charging"
            status_detail_label.stringValue = "Phew, you're safe for now."
            @hide = 3
        end
    end
    
    def full_or_remaining(status)
        (status == "charging") ? "Full" : "Remaining"
    end
    
    def battery_output
        `pmset -g batt`.split "\n"
    end
        
    def battery_status
        source, battery, *batteries = battery_output
        power_source = source.match(/.+'(.+)'$/)[1]
        
        name, status_line = battery.split "\t"
        percent, status, time = status_line.split "; "
        
        {
            :source => power_source, 
            :percent => percent.match(/\d+/)[0],
            :status => status, 
            :time => time
        }
    end
end


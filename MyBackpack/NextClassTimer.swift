//
//  NextClassTimer.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/17/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import CoreData

class NextClassTimer
{
    fileprivate static let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
    
    weak var infoLabel: UILabel?
    var timer: Timer?
    
    init(forLabel label: UILabel) {
        self.infoLabel = label
        update()
    }
    
    @objc func update() {
        timer?.invalidate()
        
        guard let infoLabel = self.infoLabel else {
            return 
        }
        
        let fetchRequest: NSFetchRequest<ClassDay> = ClassDay.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "day", ascending: true), NSSortDescriptor(key: "startTime", ascending: true)]
        
        //Core data error or no classes
        guard let classDays = try? CoreDataManager.shared.managedContext.fetch(fetchRequest), classDays.count > 0 else {
            infoLabel.text = ""
            return 
        }
        
        //semester has not started yet
        if let firstDay = classDays.first, Date() < firstDay.forClass!.firstLectureDate! as Date {
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            infoLabel.text = "Next class: \(firstDay.forClass!.name!)\n Starts on \(dateFormatter.string(from: firstDay.forClass!.firstLectureDate! as Date))"
            return
        }
        
        //semester has finished already
        if let lastDay = classDays.last, Date() > lastDay.forClass!.lastLectureDate! as Date {
            infoLabel.text = "No more scheduled classes"
            return 
        }
        
        //today's date metrics
        let now = Date()
        let currentWeekday = Int16(Calendar.current.component(.weekday, from: now))
        let currentTimestamp = Int16(Calendar.current.component(.hour, from: now) * 60 + Calendar.current.component(.minute, from: now))
        
        //search for next class
        var nextDay = classDays.first!
        for day in classDays {
            if day.day == currentWeekday {
                if day.startTime >= currentTimestamp || day.endTime > currentTimestamp {
                    nextDay = day
                    let currentSecond = Calendar.current.component(.second, from: now)
                    let fireDate = Calendar.current.date(byAdding: .second, value: 60 - currentSecond + 1, to: now)!
                    self.timer = Timer(fireAt: fireDate, interval: 0, target: self, selector: #selector(update), userInfo: nil, repeats: false)
                    RunLoop.main.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
                    break
                } 
            } else if day.day > currentWeekday {
                nextDay = day
                break
            }
        }

        let className = nextDay.forClass!.name ?? "No class name"

        //display next class info
        if currentWeekday == nextDay.day && currentTimestamp >= nextDay.startTime && currentTimestamp <= nextDay.endTime {
            infoLabel.text = "Now: \(className)"
        } else {
            let hour = nextDay.startTime / 60 > 12 ? nextDay.startTime / 60 - 12 : nextDay.startTime / 60
            let minute = nextDay.startTime % 60
            
            let timeText = "\(hour > 9 ? "\(hour)" : "0\(hour)"):\(minute > 9 ? "\(minute)" : "0\(minute)") \(nextDay.startTime >= 720 ? "pm" : "am")"
            
            let diff = nextDay.day - currentWeekday
            
            if diff == 0 {
                infoLabel.text = "Next class: \(className)\nStarts today at \(timeText)"
            } else if diff == 1 {
                infoLabel.text = "Next class: \(className)\nStarts tomorrow at \(timeText)"
            } else {
                infoLabel.text = "Next class: \(className)\nStarts on \(NextClassTimer.dayNames[Int(nextDay.day - 1)]) at \(timeText)"
            }
        }
    }
}

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
    var daysQueue: [ClassDay]!
    var timer: Timer?
    
    init(forLabel label: UILabel) {
        self.infoLabel = label
        loadQueue()
        update()
    }
    
    fileprivate func loadQueue() {
        let fetchRequest: NSFetchRequest<ClassDay> = ClassDay.fetchRequest()
        let daySortDescriptor = NSSortDescriptor(key: "day", ascending: true)
        let timeSortDescriptor = NSSortDescriptor(key: "startTime", ascending: true)
        fetchRequest.sortDescriptors = [daySortDescriptor, timeSortDescriptor]
        
        let classDays = (try? CoreDataManager.shared.managedContext.fetch(fetchRequest)) ?? []
        
        let now = Date()
        let currentWeekday = Int16(Calendar.current.component(.weekday, from: now))
        let currentTimestamp = Int16(Calendar.current.component(.hour, from: now) * 60 + Calendar.current.component(.minute, from: now))
        
        var nextDay: ClassDay?
        var count = 0
        for day in classDays {
            if day.day == currentWeekday {
                if day.startTime >= currentTimestamp || day.endTime > currentTimestamp {
                    nextDay = day
                    setupTimer()
                    break
                } 
            } else if day.day > currentWeekday {
                nextDay = day
                break
            }
            
            count += 1
        }
        
        if nextDay != nil {
            daysQueue = [ClassDay](classDays.dropFirst(count) + classDays.dropLast(classDays.count - count)) 
        } else {
            daysQueue = classDays
        }
    }
    
    fileprivate func setupTimer() {
        let currentSecond = Calendar.current.component(.second, from: Date())
        let fireDate = Calendar.current.date(byAdding: .second, value: 60 - currentSecond + 1, to: Date())!
        self.timer = Timer(fireAt: fireDate, interval: TimeInterval(60), target: self, selector: #selector(update), userInfo: nil, repeats: true)
        RunLoop.main.add(timer!, forMode: RunLoopMode.defaultRunLoopMode)
    }
    
    func reset() {
        timer?.invalidate()
        daysQueue.removeAll()
        loadQueue()
        update()
    }
    
    @objc fileprivate func update() {
        guard let infoLabel = self.infoLabel, daysQueue.count > 0 else {
            self.infoLabel?.text = "No classes"
            return 
        }

        let currentTimestamp = Int16(Calendar.current.component(.hour, from: Date()) * 60 + Calendar.current.component(.minute, from: Date()))
        let currentWeekday = Int16(Calendar.current.component(.weekday, from: Date()))
        
        if currentWeekday == daysQueue.first!.day && currentTimestamp > daysQueue.first!.endTime {
            daysQueue.append(daysQueue.removeFirst())
        }
        
        let nextDay = daysQueue.first!
        
        let className = nextDay.forClass?.name ?? "No class name"
        
        if currentTimestamp >= nextDay.startTime && currentTimestamp <= nextDay.endTime {
            infoLabel.text = "Now: \(className)"
        } else {
            let hour = nextDay.startTime / 60 - 12
            let minute = nextDay.startTime % 60
            let timeText = "\(hour > 9 ? "\(hour)" : "0\(hour)"):\(minute > 9 ? "\(minute)" : "0\(minute)") \(nextDay.startTime >= 720 ? "pm" : "am")"
            
            let diff = nextDay.day - currentWeekday
            
            if diff == 0 {
                infoLabel.text = "Next class: \(className)\nStarts today at \(timeText)"
            } else if diff == 1 {
                infoLabel.text = "Next class: \(className)\nStarts tomorrow at \(timeText)"
            } else {
                infoLabel.text = "Next class: \(className)\nStarts on \(NextClassTimer.dayNames[Int(currentWeekday - 1)]) at \(timeText)"
            }
        }
    }
}

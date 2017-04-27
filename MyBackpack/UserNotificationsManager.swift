//
//  UserNotificationsManager.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/22/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UserNotifications

class UserNotificationsManager: NSObject
{
    static let shared = UserNotificationsManager()
    
    let notificationCenter: UNUserNotificationCenter
    
    private override init() {
        self.notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllDeliveredNotifications()
    }
    
    func scheduleNotification(forReminder reminder: Reminder, onDate date: Date, repeatDayBefore days: [Int]) {
        if UserDefaults.standard.object(forKey: "DidAskForNotifications") == nil {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: { (accepted, error) in
                UserDefaults.standard.set(true, forKey: "DidAskForNotifications")
            })
        }
        
        //should be 1 not 0
        let daysToRemind = days.count > 0 ? days : [0]
        let type = ReminderType(rawValue: Int(reminder.typeID))!
        
        let content = UNMutableNotificationContent()
        content.title = ReminderType.typeNames[Int(reminder.typeID)] + " reminder"
        content.sound = UNNotificationSound.default()
        
        for day in daysToRemind {
          
            let fireDate = Calendar.current.date(byAdding: .day, value: -day, to: date)!
            let components = Calendar.current.dateComponents(in: .current, from: fireDate)
            let fireComponents = DateComponents(calendar: Calendar.current, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
             
            switch type {
                case .homework:
                    content.body = "You have a homework for \(reminder.inClass!.name!) class in \(day) \(day == 1 ? "day" : "days")."
                
                case .test:
                    content.body = "You have a \(reminder.inClass!.name!) test in \(day) \(day == 1 ? "day" : "days")."
                
                case .classCanceled:
                    let formatter = DateFormatter()
                    formatter.dateStyle = .long
                    content.body = "\(reminder.inClass!.name!) class is canceled on \(formatter.string(from: date))."
                
                case .custom:
                    content.body = reminder.remark!
            }
            
            if let date = fireComponents.date, Calendar.current.compare(date, to: Date(), toGranularity: .minute) == .orderedSame {
                continue
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: fireComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: reminder.title!, content: content, trigger: trigger)
            notificationCenter.add(request) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func removerNotification(forReminder reminder: Reminder) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminder.title!])
    }
}

//
//  UserNotificationsManager.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/22/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UserNotifications
import CoreData

class UserNotificationsManager: NSObject, UNUserNotificationCenterDelegate
{
    static let shared = UserNotificationsManager()
    
    let notificationCenter: UNUserNotificationCenter
    
    private override init() {
        self.notificationCenter = UNUserNotificationCenter.current()
        super.init()
        self.notificationCenter.delegate = self
        notificationCenter.removeAllDeliveredNotifications()
        
        let reminders = (try? CoreDataManager.shared.managedContext.fetch(Reminder.fetchRequest())) ?? []
        
        let now = Date()
        reminders.forEach{ reminder in
            if (reminder.date as Date) < now && reminder.shouldNotify {
                CoreDataManager.shared.managedContext.delete(reminder)
            }
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    func scheduleNotification(forReminder reminder: Reminder, onDate date: Date, repeatDayBefore days: [Int]) {
        if UserDefaults.standard.object(forKey: "DidAskForNotifications") == nil {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound], completionHandler: { (accepted, error) in
                UserDefaults.standard.set(true, forKey: "DidAskForNotifications")
            })
        }
        
        let type = ReminderType(rawValue: Int(reminder.typeID))!
        
        let content = UNMutableNotificationContent()
        content.title = ReminderType.typeNames[Int(reminder.typeID)] + " reminder"
        content.sound = UNNotificationSound.default()
        
        for day in days {
            let fireDate = Calendar.current.date(byAdding: .day, value: -day, to: date)!
            let components = Calendar.current.dateComponents(in: .current, from: fireDate)
            let fireComponents = DateComponents(calendar: Calendar.current, timeZone: .current, month: components.month, day: components.day, hour: components.hour, minute: components.minute)
             
            switch type {
                case .homework:
                    content.body = "You have a homework for \(reminder.inClass.name) class\(day > 0 ? " in \(day) \(day == 1 ? "day" : "days")" :  "")."
                
                case .test:
                    content.body = "You have a \(reminder.inClass.name) test\(day > 0 ? " in \(day) \(day == 1 ? "day" : "days")" :  "")."
                
                case .classCanceled:
                    let formatter = DateFormatter()
                    formatter.dateStyle = .long
                    content.body = "\(reminder.inClass.name) class is canceled on \(formatter.string(from: date))."
                
                case .custom:
                    content.body = reminder.remark
            }
            
            if let date = fireComponents.date, Calendar.current.compare(date, to: Date(), toGranularity: .minute) == .orderedSame {
                continue
            }
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: fireComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: reminder.title, content: content, trigger: trigger)
            notificationCenter.add(request) { error in
                if let error = error {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func removerNotification(forReminder reminder: Reminder) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [reminder.title])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler(UNNotificationPresentationOptions.alert)
    }
}

//
//  ContentDataSource.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/16/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import CoreData

final class ContentDataSource
{
    public static let shared = ContentDataSource()
    
    fileprivate(set) var currentClass: Class?
    private var subscribers: [ClassObserver] = []
    
    func addObserver(_ observer: ClassObserver) {
        subscribers.append(observer)
    }
    
    init() {
        let remindersRequest: NSFetchRequest<Reminder> = Reminder.fetchRequest()
        let reminders = (try? CoreDataManager.shared.managedContext.fetch(remindersRequest)) ?? []
        
        let now = Date()
        reminders.forEach{ reminder in
            if (reminder.date! as Date) < now {
                CoreDataManager.shared.managedContext.delete(reminder)
            }
        }
        
        CoreDataManager.shared.saveContext()
        
        let fetchRequest: NSFetchRequest<Class> = Class.fetchRequest()
    
        let components = Calendar.current.dateComponents([.weekday, .hour, .minute], from: Date())
        let timeStamp = Int16(components.hour! * 60 + components.minute!)
        let weekday = Int16(components.weekday!)
        
        if let classes = try? CoreDataManager.shared.managedContext.fetch(fetchRequest) {
            
            for object in classes {
                for day in object.days?.allObjects as! [ClassDay] {
                    if timeStamp >= day.startTime && timeStamp <= day.endTime && day.day == weekday {
                        loadData(forClass: object)
                        return
                    }
                }
            }
            
            if UserDefaults.standard.object(forKey: SideMenuViewController.savedClassIndex) != nil {
                let index = UserDefaults.standard.integer(forKey: SideMenuViewController.savedClassIndex)
                if index != -1 {
                    loadData(forClass: classes[index])
                } else {
                    loadData(forClass: nil)
                }
            } else if classes.count > 0 {
                loadData(forClass: classes.first)
            } else {
                loadData(forClass: nil)
            }
        }
    }
    
    func loadData(forClass classObject: Class?) {
        self.currentClass = classObject
        self.subscribers.forEach { $0.classDidChange() }
    }
}

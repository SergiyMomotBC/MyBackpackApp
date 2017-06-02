//
//  CoreDataManager.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/2/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import CoreData

class CoreDataManager
{
    static let shared = CoreDataManager()
    
    private var persistentContainer: NSPersistentContainer
    
    private init() {
        self.persistentContainer = NSPersistentContainer(name: "MyBackpack")
        self.persistentContainer.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }
    
    var managedContext: NSManagedObjectContext {
        return self.persistentContainer.viewContext
    }
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func deleteClasses(_ classes: [Class]) {
        for object in classes {
            if let lectures = object.lectures.allObjects as? [Lecture] {
                for lecture in lectures {
                    for content in lecture.contents.allObjects as! [Content] {
                        do {
                            try FileManager.default.removeItem(at: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(content.resourceURL))
                        } catch {
                            print("File could not be deleted")
                        }
                        
                        managedContext.delete(content)
                    }
                    
                    managedContext.delete(lecture)
                }
            }
            
            if let days = object.days.allObjects as? [ClassDay] {
                for day in days {
                    managedContext.delete(day)
                }
            }
            
            object.reminders.forEach { 
                self.managedContext.delete($0 as! Reminder)
                UserNotificationsManager.shared.removerNotification(forReminder: $0 as! Reminder)
            }
            
            managedContext.delete(object)
        }
        
        saveContext()
    }
}

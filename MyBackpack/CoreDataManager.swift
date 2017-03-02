//
//  CoreDataManager.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/2/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import CoreData

class CoreDataManager
{
    private static var instance: CoreDataManager? = nil
    
    static var shared: CoreDataManager {
        if instance == nil {
            instance = CoreDataManager()
        }
        
        return instance!
    }
    
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
}

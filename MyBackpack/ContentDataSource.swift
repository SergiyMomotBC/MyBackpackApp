//
//  ContentDataSource.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/16/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import Foundation
import CoreData

final class ContentDataSource
{
    public static let shared = ContentDataSource()
    
    fileprivate(set) var currentClass: Class? = nil
    fileprivate var contentObjects: [[Content]] = []
    private var subscribers: [ClassObserver] = []
    
    fileprivate var dataCopy: [[Content]]?
    
    func addObserver(_ observer: ClassObserver) {
        subscribers.append(observer)
    }
        
    var classTitle: String {
        return currentClass?.name ?? ""
    }
    
    var lecturesCount: Int {
        return contentObjects.count
    }
    
    func contentsCount(forLecture lecture: Int) -> Int {
        return contentObjects[lecture].count 
    }

    init() {
        let fetchRequest: NSFetchRequest<Class> = Class.fetchRequest()
        
        if let classes = try? CoreDataManager.shared.managedContext.fetch(fetchRequest) {
            if UserDefaults.standard.object(forKey: SideMenuViewController.savedClassIndex) != nil {
                let index = UserDefaults.standard.integer(forKey: SideMenuViewController.savedClassIndex)
                loadData(forClass: classes[index])
            } else if classes.count > 0 {
                loadData(forClass: classes.first)
            } else {
                loadData(forClass: nil)
            }
        }
    }
    
    func loadData(forClass classObject: Class?, notify: Bool = true) {
        if notify {
            subscribers.forEach { $0.classWillChange() }
        }

        guard classObject != nil else {
            if notify {
                subscribers.forEach { $0.classDidChange() }
            }
            return
        }
        
        DispatchQueue.global().async {
            usleep(250_000)
            
            self.currentClass = classObject
            self.contentObjects.removeAll()
            
            let lectures = (self.currentClass!.lectures?.allObjects as! [Lecture]).sorted { $0.date! as Date > $1.date! as Date }
            
            for lecture in lectures {
                let fetchRequest: NSFetchRequest<Content> = Content.fetchRequest()
                fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
                fetchRequest.predicate = NSPredicate(format: "lecture.countID == %d AND lecture.inClass.name == %@", lecture.countID, self.currentClass!.name!) 
                fetchRequest.fetchBatchSize = 12
                
                if let contents = try? CoreDataManager.shared.managedContext.fetch(fetchRequest) as [Content] {
                    self.contentObjects.append(contents)
                } else {
                    self.contentObjects.append([])
                }
            }
            
            if notify {
                DispatchQueue.main.async {
                    self.subscribers.forEach { $0.classDidChange() }
                }
            }
        }
    }
    
    func refresh() {
        guard dataCopy == nil else {
            return
        }
        
        if let classObject = currentClass {
            let fetchRequest: NSFetchRequest<Content> = Content.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "lecture.inClass.name == %@", currentClass!.name!)
            
            let count = contentObjects.reduce(0, { $0 + $1.count })
            
            if try! CoreDataManager.shared.managedContext.count(for: fetchRequest) != count {
                loadData(forClass: classObject)
            }
        }
    }
    
    func removeContent(atIndexPath indexPath: IndexPath) {
        guard let currentClass = currentClass else {
            return
        }
        
        let content = contentObjects[indexPath.section].remove(at: indexPath.row)
        let lecture = content.lecture!
        
        lecture.removeFromContents(content)
        CoreDataManager.shared.managedContext.delete(content)
        
        if lecture.contents?.count == 0 {
            contentObjects.remove(at: indexPath.section)
            currentClass.removeFromLectures(lecture)
            CoreDataManager.shared.managedContext.delete(lecture)
        }
        
        do {
            try FileManager.default.removeItem(at: ContentFileManager.shared.documentsFolderURL.appendingPathComponent(content.resourceURL!))
        } catch {
            print("File could not be deleted")
        }
        
        CoreDataManager.shared.saveContext()
    }
    
    
    func content(forIndexPath indexPath: IndexPath) -> Content? {
        return contentObjects[indexPath.section][indexPath.row]
    }
    
    func lecture(forSection section: Int) -> Lecture? {
        return contentObjects[section][0].lecture
    }
}

extension ContentDataSource
{
    func prepareForSearching() {
        guard dataCopy == nil else {
            print("Already prepared for searching...")
            return
        }
        
        dataCopy = contentObjects
    }
    
    func endSearching() {
        guard dataCopy != nil else {
            print("Data was not used for searching")
            return
        }
        
        contentObjects = dataCopy!
        dataCopy = nil
    }
    
    func updateDataForSearchString(_ text: String, withFilterOptions options: FilterOptions) {
        contentObjects.removeAll()

        for lecture in dataCopy! {
            let result = lecture.filter { 
                   $0.title!.lowercased().contains(text.isEmpty ? $0.title!.lowercased() : text.lowercased()) 
                && options.types.contains(Int($0.typeID)) 
                && (options.fromLecture...options.toLecture).contains(Int($0.lecture!.countID))
            }
            
            if result.count > 0 {
                contentObjects.append(result)
            }
        }
    } 
}







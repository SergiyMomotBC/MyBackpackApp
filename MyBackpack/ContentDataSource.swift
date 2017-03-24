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
    
    private(set) var currentClass: Class? = nil
    
    private var lectures: [Lecture] = []
    private var contentObjects: [[Content]] = []
    
    private var subscribers: [ClassObserver] = []
    
    func addObserver(_ observer: ClassObserver) {
        subscribers.append(observer)
    }
        
    var classTitle: String {
        return currentClass?.name ?? ""
    }
    
    var lecturesCount: Int {
        return lectures.count
    }
    
    func contentsCount(forLecture lecture: Int) -> Int {
        return contentObjects[lecture].count
    }
    
    init() {
        if let classObject = (try? CoreDataManager.shared.managedContext.fetch(Class.fetchRequest()))?.first {
            currentClass = classObject
            loadData(forClass: classObject)
        }  
    }
    
    func loadData(forClass classObject: Class) {
        currentClass = classObject
        lectures.removeAll()
        lectures.append(contentsOf: (currentClass!.lectures?.allObjects as! [Lecture]).sorted { $0.date! as Date > $1.date! as Date })
        
        contentObjects.removeAll()
        
        for lecture in lectures {
            let fetchRequest: NSFetchRequest<Content> = Content.fetchRequest()
            fetchRequest.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
            fetchRequest.predicate = NSPredicate(format: "lecture.countID == %d", lecture.countID) 
            fetchRequest.fetchBatchSize = 12
            
            if let contents = try? CoreDataManager.shared.managedContext.fetch(fetchRequest) as [Content] {
                contentObjects.append(contents)
            } else {
                contentObjects.append([])
            }
        }
        
        subscribers.forEach { $0.classDidChange() }
    }
    
    func refresh() {
        if let classObject = currentClass {
            loadData(forClass: classObject)
        }
    }
    
    func removeContent(atIndexPath indexPath: IndexPath) {
        guard let currentClass = currentClass else {
            return
        }
        
        let content = contentObjects[indexPath.section].remove(at: indexPath.row)
        lectures[indexPath.section].removeFromContents(content)
        CoreDataManager.shared.managedContext.delete(content)
        
        if lectures[indexPath.section].contents?.count == 0 {
            contentObjects.remove(at: indexPath.section)
            let lecture = lectures.remove(at: indexPath.section)
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
        return self.lectures[section]
    }
}

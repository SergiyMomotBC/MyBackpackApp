 //
//  SaveContentViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/23/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import CoreData
import DoneHUD

class SaveContentViewController: UIViewController, UITextFieldDelegate
{
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var contentTitleTextField: UITextField!
    @IBOutlet weak var contentPreviewView: UIView!
    @IBOutlet weak var lectureDropDownList: IQDropDownTextField!

    var resource: AnyObject!
    var resourceType: ContentType!
    
    weak var contentController: NewContentViewController!
    var contentPreviewer: ContentPreviewer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contentTitleTextField.delegate = self
        self.setupPickerAndToolbar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.titleLabel.text = "New " + self.resourceType.name
        self.contentTitleTextField.placeholder = "My " + resourceType.name.lowercased()
        self.contentPreviewer = ContentPreviewer(forContentType: self.resourceType, withResource: self.resource, inView: self.contentPreviewView)
        self.contentPreviewer.preparePreview()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.contentTitleTextField.isEditing {
            self.contentTitleTextField.endEditing(true)
        } else if self.lectureDropDownList.isEditing {
            self.lectureDropDownList.endEditing(true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.contentTitleTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func backAction(_ sender: Any) {
        self.contentController.captureContentVC?.presentAnimated(inScrollDirection: .reverse)
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.contentController.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func doneAction(_ sender: Any) {
        let newObject = NSEntityDescription.insertNewObject(forEntityName: "Content", into: CoreDataManager.shared.managedContext) as! Content
        
        newObject.typeID = Int16(self.resourceType.rawValue)
        newObject.title = (self.contentTitleTextField.text?.isEmpty)! ? self.contentTitleTextField.placeholder : self.contentTitleTextField.text
        newObject.dateCreated = NSDate()
        newObject.resourceURL = ContentFileManager.shared.saveResource(self.resource, ofType: self.resourceType)
        
        let currClass = ContentDataSource.shared.currentClass!
        
        let id = Int16(lectureDropDownList.itemList.count - lectureDropDownList.selectedRow - 1)
        
        if let lecture = currClass.lectures?.first(where: { return ($0 as! Lecture).countID == id }) as? Lecture {
            newObject.lecture = lecture
            lecture.addToContents(newObject)
        } else {
            let newLecture = NSEntityDescription.insertNewObject(forEntityName: "Lecture", into: CoreDataManager.shared.managedContext) as! Lecture
            newLecture.countID = id
            
            var index = lectureDropDownList.selectedItem!.characters.index(of: "-")!
            index = lectureDropDownList.selectedItem!.index(index, offsetBy: 2)
            let dateString = lectureDropDownList.selectedItem!.substring(from: index)
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .long
            
            newLecture.date = dateFormatter.date(from: dateString) as NSDate? 
            newObject.lecture = newLecture
            newLecture.addToContents(newObject)
            currClass.addToLectures(newLecture)
        }
        
        CoreDataManager.shared.saveContext()
        
        DoneHUD.shared.showInView(self.view, message: "Saved") {
            self.contentController.dismiss(animated: true, completion: nil)
        }
    }
    
    private func setupPickerAndToolbar() {
        contentPreviewView.backgroundColor = UIColor.clear
        self.lectureDropDownList.isOptionalDropDown = false
        self.lectureDropDownList.itemList = Class.retrieveLecturesList(forClass: ContentDataSource.shared.currentClass)
        lectureDropDownList.inputAccessoryView = PickerToolbar(for: lectureDropDownList)
    }
}

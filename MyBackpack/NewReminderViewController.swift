//
//  NewReminderViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 4/13/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import ATHMultiSelectionSegmentedControl
import CoreData
import DoneHUD

enum ReminderType: Int {
    case homework = 0
    case test 
    case custom
    
    static var typeNames: [String] {
        return ["Homework", "Test", "Custom"]
    }
}

class NewReminderViewController: UIViewController, UITextFieldDelegate 
{
    @IBOutlet weak var typePicker: IQDropDownTextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: IQDropDownTextField!
    @IBOutlet weak var segmentedControlContainer: UIView!
    @IBOutlet weak var descriptionTextField: UITextView!
    
    var reminderType: ReminderType?
    var daysToRemindControl: MultiSelectionSegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil) 
        
        titleTextField.delegate = self
        
        typePicker.isOptionalDropDown = false
        typePicker.dropDownMode = .textPicker
        typePicker.itemList = ReminderType.typeNames
        
        datePicker.dropDownMode = .dateTimePicker
        datePicker.isOptionalDropDown = false
        datePicker.minimumDate = Date()
        datePicker.maximumDate = ContentDataSource.shared.currentClass?.lastLectureDate as Date?
        datePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        
        let daysControl = MultiSelectionSegmentedControl(items: ["1", "2", "3", "4", "5", "6", "7"])
        daysControl.tintColor = .white
        daysToRemindControl = daysControl
        segmentedControlContainer.backgroundColor = .clear
        segmentedControlContainer.addSubview(daysControl)
        segmentedControlContainer.addConstraintsWithFormat(format: "H:|[v0]|", views: daysControl)
        segmentedControlContainer.addConstraintsWithFormat(format: "V:|[v0]|", views: daysControl)
        
        descriptionTextField.layer.cornerRadius = 8
        
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.default
        toolBar.isTranslucent = true
        toolBar.tintColor = .blue
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.plain, target: self, action: #selector(donePicker))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil)
        
        toolBar.setItems([spaceButton, doneButton, spaceButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        
        typePicker.inputAccessoryView = toolBar
        datePicker.inputAccessoryView = toolBar
    }
    
    @objc private func donePicker() {
        if typePicker.isEditing {
            typePicker.endEditing(true)
        } else if datePicker.isEditing {
            datePicker.endEditing(true)
        } 
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let type = reminderType {
            typePicker.selectedRow = type.rawValue
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        if typePicker.isEditing {
            typePicker.endEditing(true)
        } else if titleTextField.isEditing {
            titleTextField.endEditing(true)
        } else if datePicker.isEditing {
            datePicker.endEditing(true)
        } else {
            descriptionTextField.endEditing(true)
        }
    }
    
    func keyboardWillShow(notification: NSNotification) {        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 && descriptionTextField.isFirstResponder {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }        
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 && descriptionTextField.isFirstResponder {
                self.view.frame.origin.y += keyboardSize.height
            }
        }
    }
    
    @IBAction func saveReminder(_ sender: Any) {
        guard !titleTextField.text!.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Reminder's title cannot be empty.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default) { action in alert.dismiss(animated: true, completion: nil) })
            present(alert, animated: true, completion: nil)
            return 
        }
        
        //reminders
        
        let newReminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: CoreDataManager.shared.managedContext) as! Reminder
        
        newReminder.typeID = Int16(typePicker.selectedRow)
        newReminder.title = titleTextField.text
        newReminder.date = datePicker.date as NSDate?
        newReminder.remark = descriptionTextField.text
        ContentDataSource.shared.currentClass?.addToReminders(newReminder)
        
        CoreDataManager.shared.saveContext()
        
        DoneHUD.shared.showInView(view, message: "Saved") { 
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

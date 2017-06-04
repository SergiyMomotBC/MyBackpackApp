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
    case classCanceled
    case custom
    
    static var typeNames: [String] {
        return ["Homework", "Test", "Class Cancelation", "Custom"]
    }
}

class NewReminderViewController: UIViewController, UITextFieldDelegate 
{
    @IBOutlet weak var doneDescriptionButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var typePicker: IQDropDownTextField!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: IQDropDownTextField!
    @IBOutlet weak var segmentedControlContainer: UIView!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet weak var notificationSwitch: UISwitch!
    @IBOutlet weak var segmentedControlTitle: UILabel!
    
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
        datePicker.maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: (SideMenuViewController.currentClass!.lastLectureDate as Date))
        datePicker.date = Calendar.current.date(byAdding: .day, value: 1, to: Date())
        
        descriptionTextField.keyboardAppearance = .dark
        
        let daysControl = MultiSelectionSegmentedControl(items: ["0", "1", "2", "3", "4", "5", "6"])
        daysControl.tintColor = .white
        daysToRemindControl = daysControl
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0166667) {
            self.daysToRemindControl.selectedSegmentIndices = [1]
        }
        
        segmentedControlContainer.backgroundColor = .clear
        segmentedControlContainer.addSubview(daysControl)
        segmentedControlContainer.addConstraintsWithFormat(format: "H:|[v0]|", views: daysControl)
        segmentedControlContainer.addConstraintsWithFormat(format: "V:|[v0]|", views: daysControl)
        
        descriptionTextField.layer.cornerRadius = 8
        
        typePicker.inputAccessoryView = PickerToolbar(for: typePicker)
        datePicker.inputAccessoryView = PickerToolbar(for: datePicker)
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
                
                let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
                
                UIView.animate(withDuration: duration) {
                    self.typePicker.superview?.isHidden = true
                    self.titleTextField.superview?.isHidden = true
                    self.datePicker.superview?.isHidden = true
                    self.notificationSwitch.superview?.isHidden = true
                    self.segmentedControlTitle.isHidden = true
                    self.segmentedControlContainer.isHidden = true
                    self.cancelButton.isHidden = true
                    self.doneButton.isHidden = true
                    self.doneDescriptionButton.isHidden = false
                }
            }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y != 0 && descriptionTextField.isFirstResponder {
                self.view.frame.origin.y += keyboardSize.height
                
                let duration = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? Double ?? 0.25
                
                UIView.animate(withDuration: duration) {
                    self.typePicker.superview?.isHidden = false
                    self.titleTextField.superview?.isHidden = false
                    self.datePicker.superview?.isHidden = false
                    self.notificationSwitch.superview?.isHidden = false
                    self.segmentedControlTitle.isHidden = false
                    self.segmentedControlContainer.isHidden = false
                    self.cancelButton.isHidden = false
                    self.doneButton.isHidden = false
                    self.doneDescriptionButton.isHidden = true
                }
            }
        }
    }
    
    
    @IBAction func notificationSwitchToggled(_ sender: Any) {
        daysToRemindControl.setEnabled(notificationSwitch.isOn)
        segmentedControlTitle.isEnabled = notificationSwitch.isOn
        
        if notificationSwitch.isOn {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.0166667) { 
                self.daysToRemindControl.selectedSegmentIndices = [1]
            }
        }
    }
    
    @IBAction func doneEditingDescription(_ sender: Any) {
        self.descriptionTextField.endEditing(true)
    }
    
    @IBAction func saveReminder(_ sender: Any) {
        guard !titleTextField.text!.isEmpty else {
            let errorPopUp = PopUp()
            errorPopUp.displayError(message: "Reminder's title cannot be empty.")
            return 
        }
    
        let newReminder = NSEntityDescription.insertNewObject(forEntityName: "Reminder", into: CoreDataManager.shared.managedContext) as! Reminder
        
        newReminder.typeID = Int16(typePicker.selectedRow)
        newReminder.title = titleTextField.text ?? ""
        newReminder.date = datePicker.date! as NSDate
        newReminder.remark = descriptionTextField.text
        newReminder.shouldNotify = notificationSwitch.isOn
        SideMenuViewController.currentClass?.addToReminders(newReminder)
        
        CoreDataManager.shared.saveContext()

        if notificationSwitch.isOn && !daysToRemindControl.selectedSegmentIndices.isEmpty {
            UserNotificationsManager.shared.scheduleNotification(forReminder: newReminder, onDate: datePicker.date!, repeatDayBefore: daysToRemindControl.selectedSegmentIndices)
        }
        
        DoneHUD.shared.showInView(view, message: "Saved") { 
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}

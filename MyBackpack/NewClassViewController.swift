//
//  NewClassViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/17/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import CoreData
import DoneHUD

final class NewClassViewController: UIViewController
{
    private let lectureDayEntryHeight: CGFloat = 24.0
    
    @IBOutlet weak var classNameField: UITextField!
    @IBOutlet weak var firstLectureDateField: IQDropDownTextField!
    @IBOutlet weak var lastLectureDateField: IQDropDownTextField!
    @IBOutlet weak var daysStackView: UIStackView!
    @IBOutlet weak var dayField: IQDropDownTextField!
    @IBOutlet weak var fromTimeField: IQDropDownTextField!
    @IBOutlet weak var dayViewHeightConstrait: NSLayoutConstraint!
    @IBOutlet weak var toTimeField: IQDropDownTextField!
    
    weak var delegate: ClassViewControllerDelegate?
    
    fileprivate lazy var lectureDays = [(String, Date, Date)]()
    
    fileprivate let dayNames = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    private lazy var alert: UIAlertController = {
        let alert = UIAlertController(title: "Error", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        })) 
        return alert
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.classNameField.delegate = self
        self.setupPickers()
    }
    
    @IBAction func addDay(_ sender: Any) {
        guard !self.lectureDays.contains(where: { $0.0 == dayField.selectedItem! }) else {
            let errorPopUp = PopUp()
            errorPopUp.displayError(message: "Class already has \(dayField.selectedItem!) as a lecture day.")
            return
        }
        
        let text = "\(dayField.selectedItem!),  \(fromTimeField.selectedItem!) - \(toTimeField.selectedItem!)"
        daysStackView.addArrangedSubview(getLectureDayEntry(forText: text))
        UIView.animate(withDuration: 0.5) { 
            self.dayViewHeightConstrait.constant += self.daysStackView.spacing + self.lectureDayEntryHeight
        }
        
        self.lectureDays.append((dayField.selectedItem!, fromTimeField.date!, toTimeField.date!))
    }
    
    @objc fileprivate func removeDay(_ sender: UIButton) {
        sender.superview?.removeFromSuperview()
        UIView.animate(withDuration: 0.5) { 
            self.dayViewHeightConstrait.constant -= self.daysStackView.spacing + self.lectureDayEntryHeight
        }
        
        if let index = self.lectureDays.index(where: { $0.0 == sender.accessibilityIdentifier!}) {
            self.lectureDays.remove(at: index)
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.delegate?.classViewController(self, didCommitChanges: false)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        var errorMessage: String?
        
        if classNameField.text!.isEmpty {
            errorMessage = "Class name is not specified."
        } else if firstLectureDateField.date == nil {
            errorMessage = "First lecture date is not specified."
        } else if lastLectureDateField.date == nil {
            errorMessage = "Last lecture date is not specified."
        } else if daysStackView.arrangedSubviews.count == 0 {
            errorMessage = "Class should have at least one lecture day."
        } else {
            var weekday = Calendar.current.dateComponents([Calendar.Component.weekday], from: self.firstLectureDateField.date! as Date).weekday!
        
            if !lectureDays.contains(where: { self.dayNames.index(of: $0.0)! + 1 == weekday }) {
                errorMessage = "First lecture date is not one of the lecture days."
            }
            
            weekday = Calendar.current.dateComponents([Calendar.Component.weekday], from: self.lastLectureDateField.date! as Date).weekday!
            
            if !lectureDays.contains(where: { self.dayNames.index(of: $0.0)! + 1 == weekday }) {
                errorMessage = "Last lecture date is not one of the lecture days."
            }
        }
        
        guard errorMessage == nil else {
            let errorPopUp = PopUp()
            errorPopUp.displayError(message: errorMessage!)
            return
        }
        
        saveClassToCoreData()
        
        DoneHUD.shared.showInView(self.view, message: "Saved") {
            self.delegate?.classViewController(self, didCommitChanges: true)
        }
    }
    
    private func saveClassToCoreData() {
        let newClass = NSEntityDescription.insertNewObject(forEntityName: "Class", into: CoreDataManager.shared.managedContext) as! Class
        
        newClass.name = self.classNameField.text ?? ""
        newClass.firstLectureDate = self.firstLectureDateField.date! as NSDate
        newClass.lastLectureDate = self.lastLectureDateField.date! as NSDate
        
        for day in lectureDays {
            let lectureDay = NSEntityDescription.insertNewObject(forEntityName: "ClassDay", into: CoreDataManager.shared.managedContext) as! ClassDay
            
            lectureDay.day = Int16(dayNames.index(of: day.0)! + 1)
            
            var components = Calendar.current.dateComponents([.hour, .minute], from: day.1)
            lectureDay.startTime = Int16(components.hour! * 60 + components.minute!)
            
            components = Calendar.current.dateComponents([.hour, .minute], from: day.2)
            lectureDay.endTime = Int16(components.hour! * 60 + components.minute!)
            
            lectureDay.forClass = newClass
            
            newClass.addToDays(lectureDay)
        }
        
        CoreDataManager.shared.saveContext()
    }
}

fileprivate extension NewClassViewController
{
    func getLectureDayEntry(forText text: String) -> UIView {
        let bgView = UIView()
        bgView.backgroundColor = .clear
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.font = UIFont(name: "Avenir Next", size: 12)
        textField.isUserInteractionEnabled = false
        textField.text = text
        
        let button = UIButton()
        button.setTitle("Remove", for: .normal)
        button.accessibilityIdentifier = dayField.selectedItem!
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.titleLabel?.font = UIFont(name: "Avenir Next", size: 14)
        button.addTarget(self, action: #selector(removeDay(_:)), for: .touchUpInside)
        
        bgView.addSubview(textField)
        bgView.addSubview(button)
        
        bgView.addConstraintsWithFormat(format: "H:|[v0]-8-[v1(75)]|", views: textField, button)
        bgView.addConstraintsWithFormat(format: "V:|[v0]|", views: textField)
        bgView.addConstraintsWithFormat(format: "V:|[v0]|", views: button)
        
        return bgView
    }
    
    func setupPickers() {
        firstLectureDateField.dropDownMode = .datePicker
        firstLectureDateField.inputAccessoryView = PickerToolbar(for: firstLectureDateField)
        firstLectureDateField.isOptionalDropDown = false
        
        lastLectureDateField.dropDownMode = .datePicker
        lastLectureDateField.inputAccessoryView = PickerToolbar(for: lastLectureDateField)
        lastLectureDateField.isOptionalDropDown = false
        
        fromTimeField.dropDownMode = .timePicker
        fromTimeField.inputAccessoryView = PickerToolbar(for: fromTimeField)
        fromTimeField.isOptionalDropDown = false
        
        toTimeField.dropDownMode = .timePicker
        toTimeField.inputAccessoryView = PickerToolbar(for: toTimeField)
        toTimeField.isOptionalDropDown = false
        
        dayField.dropDownMode = .textPicker
        dayField.inputAccessoryView = PickerToolbar(for: dayField)
        dayField.isOptionalDropDown = false
        dayField.itemList = dayNames
    }
}

extension NewClassViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.classNameField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if self.classNameField.isEditing {
            self.classNameField.endEditing(true)
        }
    }
}

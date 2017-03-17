//
//  NewClassViewController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 3/17/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit

fileprivate enum DayName: String {
    case Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
}

class NewClassViewController: UIViewController
{
    @IBOutlet weak var classNameField: UITextField!
    @IBOutlet weak var firstLectureDateField: IQDropDownTextField!
    @IBOutlet weak var lastLectureDateField: IQDropDownTextField!
    @IBOutlet weak var daysStackView: UIStackView!
    @IBOutlet weak var dayField: IQDropDownTextField!
    @IBOutlet weak var fromTimeField: IQDropDownTextField!
    @IBOutlet weak var dayViewHeightConstrait: NSLayoutConstraint!
    @IBOutlet weak var toTimeField: IQDropDownTextField!
    
    private lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        toolbar.isTranslucent = true
        toolbar.tintColor = .blue
        toolbar.sizeToFit() 
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donePicker))
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([space, doneButton, space], animated: false)
        toolbar.isUserInteractionEnabled = true
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.classNameField.delegate = self
        
        firstLectureDateField.dropDownMode = .datePicker
        firstLectureDateField.inputAccessoryView = toolbar
        
        lastLectureDateField.dropDownMode = .datePicker
        lastLectureDateField.inputAccessoryView = toolbar
        
        fromTimeField.dropDownMode = .timePicker
        fromTimeField.inputAccessoryView = toolbar
        fromTimeField.isOptionalDropDown = false
        
        toTimeField.dropDownMode = .timePicker
        toTimeField.inputAccessoryView = toolbar
        toTimeField.isOptionalDropDown = false
        
        dayField.dropDownMode = .textPicker
        dayField.inputAccessoryView = toolbar
        dayField.isOptionalDropDown = false
        dayField.itemList = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
    }
    
    @IBAction func addDay(_ sender: Any) {
        guard daysStackView.arrangedSubviews.count < 7 else {
            return
        }
        
        let text = "\(dayField.selectedItem!),  \(fromTimeField.selectedItem!) - \(toTimeField.selectedItem!)"
        
        let bgView = UIView()
        bgView.backgroundColor = .clear
        
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .white
        textField.font = UIFont(name: "Avenir Next", size: 14)
        textField.isUserInteractionEnabled = false
        textField.text = text
         
        let button = UIButton()
        button.setTitle("Remove", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.setTitleColor(.white, for: .highlighted)
        button.titleLabel?.font = UIFont(name: "Avenir Next", size: 15)
        button.addTarget(self, action: #selector(removeDay(_:)), for: .touchUpInside)
        
        bgView.addSubview(textField)
        bgView.addSubview(button)
        
        bgView.addConstraintsWithFormat(format: "H:|[v0]-8-[v1(75)]|", views: textField, button)
        bgView.addConstraintsWithFormat(format: "V:|[v0]|", views: textField)
        bgView.addConstraintsWithFormat(format: "V:|[v0]|", views: button)
        
        daysStackView.addArrangedSubview(bgView)
            
        UIView.animate(withDuration: 0.5) { 
            self.dayViewHeightConstrait.constant += self.daysStackView.spacing + 30.0
        }
    }
    
    @IBAction func cancelAction(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard daysStackView.arrangedSubviews.count > 0 else {
            let alert = UIAlertController(title: "Error", message: "Class should have at least one day", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                alert.dismiss(animated: true, completion: nil)
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
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
    
    @objc fileprivate func donePicker() {
        if firstLectureDateField.isEditing {
            firstLectureDateField.resignFirstResponder()
        } else if lastLectureDateField.isEditing {
            lastLectureDateField.resignFirstResponder()
        } else if dayField.isEditing {
            dayField.resignFirstResponder()
        } else if fromTimeField.isEditing {
            fromTimeField.resignFirstResponder()
        } else {
            toTimeField.resignFirstResponder()
        }
    }
    
    @objc fileprivate func removeDay(_ sender: UIButton) {
        sender.superview?.removeFromSuperview()
        
        UIView.animate(withDuration: 0.5) { 
            self.dayViewHeightConstrait.constant -= self.daysStackView.spacing + 30.0
        }
    }
}

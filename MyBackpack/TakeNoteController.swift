//
//  TakeNoteController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/25/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import RichEditorView

class NoteController: UIViewController
{
    private static let textViewPadding: CGFloat = 4.0
    private var textViewBottomConstraint: NSLayoutConstraint!
    private var editor: EditingCommands!
    
    lazy var textView: UITextView = {
        let textView = UITextView()
        
        textView.isEditable = true
        textView.backgroundColor = .white
        textView.keyboardAppearance = .dark
        textView.font = UIFont(name: "AvenirNext-Regular", size: 14)
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.autocorrectionType = .no
        
        self.view.addSubview(textView)
        
        textView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: textViewPadding).isActive = true
        textView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: textViewPadding).isActive = true
        textView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -textViewPadding).isActive = true
        self.textViewBottomConstraint = textView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -textViewPadding)
        self.textViewBottomConstraint.isActive = true
        
        return textView
    }()
    
    lazy var toolbar: UIToolbar = {
        let toolbar = UIToolbar(frame: CGRect(x: 0.0, y: 0.0, width: self.view.frame.width, height: 40.0))
        
        toolbar.isTranslucent = false
        toolbar.barTintColor = .white
        toolbar.tintColor = UIColor(red: 0.5, green: 0.0, blue: 0.25, alpha: 1.0)
        
        let bottomLine = UIView(frame: CGRect(x: 0.0, y: toolbar.frame.height - 1.0, width: toolbar.frame.width, height: 1.0))
        bottomLine.backgroundColor = .gray
        toolbar.addSubview(bottomLine)
        
        let topLine = UIView(frame: CGRect(x: 0.0, y: 0.0, width: toolbar.frame.width, height: 1.0))
        topLine.backgroundColor = .gray
        toolbar.addSubview(topLine)
        
        return toolbar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        textView.inputAccessoryView = toolbar
        
        let superscriptItem = UIBarButtonItem(image: UIImage(named: "superscript"), style: .plain, target: self, action: #selector(action(_:)))
        let subscriptItem = UIBarButtonItem(image: UIImage(named: "subscript"), style: .plain, target: self, action: #selector(action(_:)))
        let boldItem = UIBarButtonItem(image: UIImage(named: "bold"), style: .plain, target: self, action: #selector(action(_:)))
        let italicItem = UIBarButtonItem(image: UIImage(named: "italic"), style: .plain, target: self, action: #selector(action(_:)))
        let underlineItem = UIBarButtonItem(image: UIImage(named: "underline"), style: .plain, target: self, action: #selector(action(_:)))
        let increaseFontItem = UIBarButtonItem(image: UIImage(named: "increase_font"), style: .plain, target: self, action: #selector(action(_:)))
        let decreaseFontItem = UIBarButtonItem(image: UIImage(named: "decrease_font"), style: .plain, target: self, action: #selector(action(_:)))
        let alignLeftItem = UIBarButtonItem(image: UIImage(named: "align_left"), style: .plain, target: self, action: #selector(action(_:)))
        let alignCenterItem = UIBarButtonItem(image: UIImage(named: "align_center"), style: .plain, target: self, action: #selector(action(_:)))
        let alignRightItem = UIBarButtonItem(image: UIImage(named: "align_right"), style: .plain, target: self, action: #selector(action(_:)))
        
        let flex = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        let items = [boldItem, flex, italicItem, flex, underlineItem, flex, superscriptItem, flex, subscriptItem, flex, increaseFontItem, flex, decreaseFontItem, flex, alignLeftItem, flex, alignCenterItem, flex, alignRightItem]
        
        var tag = 0
        for index in stride(from: 0, to: items.count, by: 2) {
            items[index].tag = tag
            tag += 1
        }
        
        toolbar.setItems(items, animated: false)
        
        self.editor = EditingCommands(forTextView: self.textView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardEvent(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        textView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
        textView.resignFirstResponder()
    }
    
    @objc private func keyboardEvent(_ notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardHeight = (userInfo[UIKeyboardFrameEndUserInfoKey] as! CGRect).height
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
        let animationCurveCase = userInfo[UIKeyboardAnimationCurveUserInfoKey] as! UInt
        
        textViewBottomConstraint.constant = notification.name == NSNotification.Name.UIKeyboardWillShow ? -keyboardHeight - NoteController.textViewPadding : -NoteController.textViewPadding
        
        UIView.animate(withDuration: animationDuration, delay: 0.0, options: UIViewAnimationOptions(rawValue: animationCurveCase << 16), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc private func action(_ barItem: UIBarButtonItem) {
        self.editor.performCommand(EditingAction(rawValue: barItem.tag)!)
    }
}

class TakeNoteController: NSObject, ContentProvider
{
    private var takenNoteHTML: Data?
    private var navigationVC: UINavigationController?
    private let noteController: NoteController
    
    init(for parent: NewContentViewController) {
        self.parentVC = parent
        self.noteController = NoteController()
        
        super.init()
        
        setupNavigationController(withVC: noteController)
    }
    
    @objc private func done() {
        self.takenNoteHTML = try? noteController.textView.attributedText.data(from: NSRange(location: 0, length: noteController.textView.attributedText.length), documentAttributes: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType])
        self.parentVC?.contentProviderDidSuccesfullyFinished()
    }
    
    @objc private func cancel() {
        self.parentVC?.dismiss(animated: true, completion: nil)
    }
    
    private func setupNavigationController(withVC: UIViewController) {
        self.navigationVC = UINavigationController(rootViewController: withVC)
        self.navigationVC?.navigationBar.topItem?.title = "New Note"
        self.navigationVC?.navigationBar.barTintColor = UIColor(red: 128/255.0, green: 0/255.0, blue: 64/255.0, alpha: 1.0)
        self.navigationVC?.navigationBar.tintColor = .white
        self.navigationVC?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        self.navigationVC?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(done))
        
        self.navigationVC?.navigationBar.topItem?.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancel))
    }
    
    // MARK: Conforming to ContentProvider protocol
    
    weak var parentVC: NewContentViewController?
    
    var providedContentType: ContentType {
        return ContentType.Note
    }
    
    var resource: AnyObject? {
        return self.takenNoteHTML as AnyObject?
    }
    
    func presentAnimated(inScrollDirection direction: UIPageViewControllerNavigationDirection) {
        self.parentVC?.setViewControllers([self.navigationVC!], direction: direction, animated: true, completion: nil)
    }
}

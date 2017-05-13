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
    private lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: self.view.frame.height - 44, width: self.view.frame.width, height: 44))
        toolbar.options = [RichEditorDefaultOption.undo, RichEditorDefaultOption.redo, RichEditorDefaultOption.bold, RichEditorDefaultOption.italic, RichEditorDefaultOption.underline, 
                           RichEditorDefaultOption.orderedList, RichEditorDefaultOption.unorderedList, RichEditorDefaultOption.alignLeft, RichEditorDefaultOption.alignCenter, 
                           RichEditorDefaultOption.alignRight]
        return toolbar
    }()
    
    var editorView: RichEditorView!
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.editorView = RichEditorView(frame: CGRect(x: 8, y: 4, width: view.frame.width - 16, height: view.frame.height - 4))
        editorView.backgroundColor = .white
        editorView.clipsToBounds = true
        view.backgroundColor = .white
        view.addSubview(editorView)
        toolbar.editor = editorView
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHide), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.editorView.runJS("document.getElementById('editor').focus()")
    }
    
    @objc private func keyboardWillShowOrHide(notification: NSNotification) {
        
        let info = notification.userInfo ?? [:]
        let duration = TimeInterval((info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.25)
        let curve = UInt((info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0)
        let options = UIViewAnimationOptions(rawValue: curve)
        let keyboardRect = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        
        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            print("Start")
            self.view.addSubview(self.toolbar)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self.editorView.frame = CGRect(x: 8, y: 4, width: self.view.frame.width - 16, height: self.editorView.frame.height - keyboardRect.height - 44)
                self.toolbar.frame.origin.y = self.view.frame.height - (keyboardRect.height + self.toolbar.frame.height)
            }, completion: nil)
        } else if notification.name == NSNotification.Name.UIKeyboardWillHide {
            print("Finish")
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                self.editorView.frame = CGRect(x: 8, y: 4, width: self.view.frame.width - 16, height: self.view.frame.height - 4)
                self.toolbar.frame.origin.y = self.view.frame.height
            }, completion: { success in self.toolbar.removeFromSuperview() })
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

class TakeNoteController: NSObject, ContentProvider
{
    private var takenNoteHTMLText: String?
    private var navigationVC: UINavigationController?
    private let noteController: NoteController
    
    init(for parent: NewContentViewController) {
        self.parentVC = parent
        self.noteController = NoteController()
        
        super.init()
        
        setupNavigationController(withVC: noteController)
    }
    
    @objc private func done() {
        self.takenNoteHTMLText = noteController.editorView.html
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
        return self.takenNoteHTMLText as AnyObject?
    }
    
    func presentAnimated(inScrollDirection direction: UIPageViewControllerNavigationDirection) {
        self.parentVC?.setViewControllers([self.navigationVC!], direction: direction, animated: true, completion: nil)
    }
    
}

//
//  TakeNoteController.swift
//  My Backpack
//
//  Created by Sergiy Momot on 2/25/17.
//  Copyright © 2017 Sergiy Momot. All rights reserved.
//

import UIKit
import RichEditorView

class TakeNoteController: NSObject, ContentProvider
{
    private var takenNoteHTMLText: String?
    private var navigationVC: UINavigationController?
    private var editorView: RichEditorView
    
    private lazy var toolbar: RichEditorToolbar = {
        let toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: (self.navigationVC?.view.bounds.width)!, height: 44))
        toolbar.options = [RichEditorOptions.undo, RichEditorOptions.redo, RichEditorOptions.bold, RichEditorOptions.italic,
                           RichEditorOptions.subscript, RichEditorOptions.superscript, RichEditorOptions.underline,
                           RichEditorOptions.textColor, RichEditorOptions.header(1)]
        toolbar.tintColor = .red
        return toolbar
    }()
    
    init(for parent: NewContentViewController) {
        self.parentVC = parent
        let noteController = UIViewController()
        self.editorView = RichEditorView(frame: noteController.view.frame)
        
        super.init()
        
        editorView.backgroundColor = .white
        noteController.view.addSubview(editorView)
        
        setupNavigationController(withVC: noteController)
        
        toolbar.editor = editorView
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHide), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowOrHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc private func done() {
        self.parentVC.contentProviderDidSuccesfullyFinished()
    }
    
    @objc private func cancel() {
        self.parentVC.dismiss(animated: true, completion: nil)
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
    
    @objc private func keyboardWillShowOrHide(notification: NSNotification) {
        
        let info = notification.userInfo ?? [:]
        let duration = TimeInterval((info[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.floatValue ?? 0.25)
        let curve = UInt((info[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0)
        let options = UIViewAnimationOptions(rawValue: curve)
        let keyboardRect = (info[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? CGRect.zero
        
        if notification.name == NSNotification.Name.UIKeyboardWillShow {
            self.navigationVC?.childViewControllers.first?.view?.addSubview(self.toolbar)
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                if let view = self.navigationVC?.childViewControllers.first?.view {
                    self.toolbar.frame.origin.y = view.frame.height - (keyboardRect.height + self.toolbar.frame.height)
                }
            }, completion: nil)
        } else if notification.name == NSNotification.Name.UIKeyboardWillHide {
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                if let view = self.navigationVC?.childViewControllers.first?.view {
                    self.toolbar.frame.origin.y = view.frame.height
                }
            }, completion: nil)
        }
    }
    
    // MARK: Conforming to ContentProvider protocol
    
    var parentVC: NewContentViewController
    
    var providedContentType: ContentType {
        return ContentType.Note
    }
    
    var resource: AnyObject? {
        return self.takenNoteHTMLText as AnyObject?
    }
    
    func presentAnimated(inScrollDirection direction: UIPageViewControllerNavigationDirection) {
        
        self.parentVC.setViewControllers([self.navigationVC!], direction: direction, animated: true, completion: { success in self.editorView.becomeFirstResponder() })
    }
    
}

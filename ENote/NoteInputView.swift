//
//  NoteInputView.swift
//  ENote
//
//  Created by min-mac on 16/12/1.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit

class NoteInputView: UIView {
    
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var addNoteButton: UIButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    let width = UIScreen.main.bounds.width
    
    var currentHeight: CGFloat = 150.0
    let fixHeight: CGFloat = 70.0
    
    var finishedAddNoteHandler: ((String) -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.frame.size.width = width
        self.frame.size.height = currentHeight
        
        noteTextView.layer.cornerRadius = 5
        addNoteButton.layer.cornerRadius = 5
        cancelButton.layer.cornerRadius = 5
        
        noteTextView.layer.borderColor = UIColor(red: 225 / 255.0, green: 225 / 255.0, blue: 225 / 255.0, alpha: 1.0).cgColor
        noteTextView.layer.borderWidth = 1.0
        
        noteTextView.delegate = self
        
        print("Finished load from Xib")
    }
    
    
    // MARK: - IBAction
    @IBAction func cancel(_ sender: UIButton) {
        self.noteTextView.resignFirstResponder()
    }
    
    @IBAction func addNote(_ sender: UIButton) {
        
        if let finishedHandler = finishedAddNoteHandler {
            finishedHandler(noteTextView.text)
        }
    
        self.noteTextView.resignFirstResponder()
    }
}

//MARK: - UITextViewDelegate
extension NoteInputView: UITextViewDelegate {
    
    func textViewDidChange(_ textView: UITextView) {
        
        // 根据textView的内容大小, 调整输入框的高度
        if textView.contentSize.height + fixHeight > currentHeight {
            // 计算应该增加的高度
            let heightenCount = textView.contentSize.height + fixHeight - currentHeight
            
            // 设置新的原点
            var newOrigin = self.frame.origin
            newOrigin.y -= heightenCount
            self.frame.origin = newOrigin
            
            // 更新当前整个View的高度
            currentHeight = textView.contentSize.height + fixHeight
            self.frame.size.height = currentHeight
            
        }
    }
    
}

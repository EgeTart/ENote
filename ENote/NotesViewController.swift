//
//  ViewController.swift
//  ENote
//
//  Created by min-mac on 16/11/28.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class NotesViewController: UIViewController {

    @IBOutlet weak var sentenceContainerView: UIView!
    @IBOutlet weak var sentenceImageView: UIImageView!
    @IBOutlet weak var sentenceLabel: UILabel!
    
    @IBOutlet weak var addNoteItem: UIBarButtonItem!
    @IBOutlet weak var notesTableView: UITableView!
    
    var sentence: Sentence!
    
    var noteInputView: NoteInputView!
    
    let databaseManager = DatabaseManager.sharedManager
    let notesManager = NotesManager.sharedManager
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseManager.updateHistoryTable()
        
        notesTableView.dataSource = self
        notesTableView.delegate = self
        notesTableView.tableFooterView = UIView()
        
        notesTableView.rowHeight = UITableViewAutomaticDimension
        notesTableView.estimatedRowHeight = 50
        
        notesTableView.register(UINib(nibName: "NoteCell", bundle: Bundle.main), forCellReuseIdentifier: "NoteCell")
 
        NotificationCenter.default.addObserver(self, selector: #selector(NotesViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NotesViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func currentDateInFormatte(formatte: String) -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatte
        
        let dateInFormatte = dateFormatter.string(from: date)
        
        return dateInFormatte
    }

    func getDailySentence() {
        
        self.navigationController?.navigationBar.isHidden = true
        
        let currentDate = currentDateInFormatte(formatte: "yyyy-MM-dd")
        
        Alamofire.request("http://open.iciba.com/dsapi/", method: .get, parameters: ["date": currentDate], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if let result = response.result.value as? Dictionary<String, Any> {
                self.sentence = Sentence(dict: result)
                self.sentenceLabel.text = self.sentence.englishSentence
                
                self.sentenceImageView.sd_setImageTmp(with: URL(string: self.sentence.pictureURL!)!, placeholderImage: UIImage(named: "saffron"), completed: { (_, _, _, _) in
                    self.dismissSentenceContainerView()
                })
            }
            else {
                self.sentenceImageView.image = UIImage(named: "saffron")
                self.dismissSentenceContainerView()
            }
        }
    }
    
    func dismissSentenceContainerView() {
        
        UIView.animate(withDuration: 2.0, delay: 2.0, options: [], animations: {
            self.sentenceImageView.frame.size.width = self.view.frame.width * 1.5
            self.sentenceImageView.frame.size.height = self.view.frame.height * 1.5
            self.sentenceImageView.center = self.sentenceContainerView.center
            self.sentenceContainerView.alpha = 0

        }, completion: {_ in
            self.sentenceContainerView.removeFromSuperview()
            self.navigationController?.navigationBar.isHidden = false
        })
    }
    
    func finishedAddNoteHandler(note: String) {
        print(note)
        
        databaseManager.insertNote(content: note)
        
        notesTableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
    }
    
    // MARK: - IBAction
    @IBAction func addNote(_ sender: UIBarButtonItem) {
        
        noteInputView = Bundle.main.loadNibNamed("NoteInputView", owner: nil, options: nil)!.first as! NoteInputView
        noteInputView.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
        noteInputView.noteTextView.becomeFirstResponder()
        
        noteInputView.finishedAddNoteHandler = self.finishedAddNoteHandler
        
        self.view.addSubview(noteInputView)
        self.view.bringSubview(toFront: noteInputView)
        
        addNoteItem.isEnabled = false
    }
    
    @IBAction func showStatisticsController(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "ToStatistics", sender: self)
    }
    
}

// MARK: - UITableViewDataSource
extension NotesViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notesManager.notes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let note = notesManager.notes[indexPath.row]
        
        let noteCell = tableView.dequeueReusableCell(withIdentifier: "NoteCell", for: indexPath) as! NoteCell
        noteCell.contentLable.text = note.content
    
        if note.state {
            noteCell.contentLable.textColor = UIColor(red: 153.0 / 255.0, green: 153.0 / 255.0, blue: 153.0 / 255.0, alpha: 1.0)
        }
        else {
            noteCell.contentLable.textColor = UIColor(red: 51.0 / 255.0, green: 51.0 / 255.0, blue: 51.0 / 255.0, alpha: 1.0)
        }
        
        return noteCell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let note = notesManager.notes[indexPath.row]
        
        return !note.state
    }
}


// MARK: - UITableViewDelegate
extension NotesViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let note = notesManager.notes[indexPath.row]
        
        if note.state {
            return nil
        }
        
        let updateStateAction = UITableViewRowAction(style: .normal, title: "完成", handler: {action, indexPath in
            
            let note = self.notesManager.notes[indexPath.row]
            self.databaseManager.updateNoteState(id: note.id)

            let newIndex = self.notesManager.notes.index(where: { (updatedNote: Note) -> Bool in
                return updatedNote.id == note.id
            })
            
            let newIndexPath = IndexPath(row: newIndex!, section: 0)
            tableView.moveRow(at: indexPath, to: newIndexPath)
            tableView.reloadRows(at: [newIndexPath], with: .automatic)
            
        })
        updateStateAction.backgroundColor = UIColor(red: 0.4, green: 0.6, blue: 0.9, alpha: 1.0)
        
        
        let deleteNoteAction = UITableViewRowAction(style: .default, title: "删除", handler: {action, indexPath in
            
            let note = self.notesManager.notes[indexPath.row]
            self.databaseManager.deleteNote(id: note.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        })
        
        return [deleteNoteAction, updateStateAction]
    }
}


//MARK: - 键盘事件
extension NotesViewController {
    
    func keyboardWillShow(notification: Notification) {
        print("keyboard show")
        
        let keyboardFram = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        var noteInputViewOrigin = keyboardFram.origin
        noteInputViewOrigin.y -= noteInputView.frame.height
        
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        UIView.animate(withDuration: duration, animations: {
            self.noteInputView.frame.origin = noteInputViewOrigin
        }, completion: nil)
        
        print(duration)
    }
    
    func keyboardWillHide(notification: Notification) {
        let duration = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        
        addNoteItem.isEnabled = true
        
        UIView.animate(withDuration: duration, animations: {
            self.noteInputView.frame.origin = CGPoint(x: 0, y: self.view.frame.height)
        }, completion: nil)
    }
}

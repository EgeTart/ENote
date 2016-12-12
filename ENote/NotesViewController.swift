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
    
    @IBOutlet weak var addNoteItem: UIBarButtonItem!
    @IBOutlet weak var notesTableView: UITableView!
    
    @IBOutlet weak var sentenceScrollView: UIScrollView!
    
    @IBOutlet weak var pageControl: UIPageControl!
    var sentences = [Sentence]()
    
    var noteInputView: NoteInputView!
    
    let databaseManager = DatabaseManager.sharedManager
    let notesManager = NotesManager.sharedManager
    
    let optionNames = ["数据统计", "历史便签"]
    let optionIconNames = ["statistics_icon", "history_icon"]
    
    let width = UIScreen.main.bounds.width
    
    let sentenceCount = 5
    
    var timer: Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseManager.updateHistoryTable()
        
        notesTableView.dataSource = self
        notesTableView.delegate = self
        notesTableView.tableFooterView = UIView()
        
        notesTableView.rowHeight = UITableViewAutomaticDimension
        notesTableView.estimatedRowHeight = 50
        
        notesTableView.register(UINib(nibName: "NoteCell", bundle: Bundle.main), forCellReuseIdentifier: "NoteCell")
        
        for subView in notesTableView.subviews {
            if subView.isKind(of: UIScrollView.self) {
                (subView as! UIScrollView).delegate = nil
            }
        }
        
        pageControl.numberOfPages = sentenceCount
        
        //databaseManager.deleteAllHistoryData()
//        let dispatchQueue = DispatchQueue.global(qos: .default)
//        dispatchQueue.async { 
//            self.databaseManager.fillMockData()
//        }
        
        getDailySentence(isLastDay: 1 == sentenceCount, count: 1)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(NotesViewController.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(NotesViewController.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - 获取每日一句功能的代码段
    func getDailySentence() {
        
//        let operationQueue = OperationQueue()
//        var operations = [BlockOperation]()
//        
//        for i in 0..<sentenceCount {
//            
//            let operation = BlockOperation {
//                let date = dateInFormatte(date: Date(timeInterval: -24 * 60 * 60 * Double(i), since: Date()), formatte: "yyyy-MM-dd")
//                
//                self.getDailySentence(date: date, isLastDay: i == self.sentenceCount - 1)
//            }
//            
//            let blockOperation = BlockOperation(block: { 
//                <#code#>
//            })
//            
//            if i > 0 {
//                print(i)
//                operation.addDependency(operations[i - 1])
//            }
//            operations.append(operation)
//        }
//        
//        operationQueue.addOperations(operations, waitUntilFinished: false)
        
        self.getDailySentence(isLastDay: 1 == sentenceCount, count: 1)
    }
    
    func getDailySentence(isLastDay: Bool, count: Int) {
        
        let date = dateInFormatte(date: Date(timeInterval: -24 * 60 * 60 * Double(count - 1), since: Date()), formatte: "yyyy-MM-dd")
        
        Alamofire.request("http://open.iciba.com/dsapi/", method: .get, parameters: ["date": date], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if let result = response.result.value as? Dictionary<String, Any> {
                let sentence = Sentence(dict: result)
                self.sentences.append(sentence)
                
                if isLastDay {
                    DispatchQueue.main.async {
                        self.setupSentenceScrollView()
                    }
                }
                else {
                    self.getDailySentence(isLastDay: count + 1 == self.sentenceCount, count: count + 1)
                }
            }
        }
        
    }
    
    func setupSentenceScrollView() {
        
        let height = width / 2.0
        
        notesTableView.tableHeaderView?.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        sentenceScrollView.delegate = self
        sentenceScrollView.contentSize = CGSize(width: width * CGFloat(sentences.count + 2), height: height)
        
        sentences.insert(sentences[sentenceCount - 1], at: 0)
        sentences.append(sentences[1])
        
        for (index, sentence) in sentences.enumerated() {
            print(sentence.pictureURL!)
            let offset = width * CGFloat(index)
        
            let dailySentenceView = Bundle.main.loadNibNamed("DailySentenceView", owner: nil, options: nil)?.first as! DailySentenceView
            
            dailySentenceView.frame.origin = CGPoint(x: offset, y: 0)
            dailySentenceView.sentenceImageView.sd_setImage(with: URL(string: sentence.pictureURL!)!)
            dailySentenceView.sentenceLabel.text = sentence.englishSentence
            
            sentenceScrollView.addSubview(dailySentenceView)
            
        }
        
        sentenceScrollView.contentOffset = CGPoint(x: width, y: 0)
        
        fireTimer()
    }
    
    func nextSentence() {
        
        let currentPage = pageControl.currentPage + 1
        
        sentenceScrollView.setContentOffset(CGPoint(x: width * CGFloat(currentPage + 1), y: 0), animated: true)
        
    }
    
    func updateCurrentPage(scrollView: UIScrollView) {
        var currentPage = Int(scrollView.contentOffset.x / self.view.frame.width) - 1
        
        if currentPage == -1 {
            currentPage = sentenceCount - 1
        }
        else if currentPage == sentenceCount {
            currentPage = 0
        }
        
        pageControl.currentPage = currentPage
    }
    
    func checkBounds(scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x == 0.0 {
            scrollView.setContentOffset(CGPoint(x: width * CGFloat(sentenceCount), y: 0), animated: false)
        }
        else if scrollView.contentOffset.x == (width * CGFloat(sentenceCount + 1)) {
            scrollView.setContentOffset(CGPoint(x: width, y: 0), animated: false)
        }
    }
    
    func fireTimer() {
        timer = Timer.init(timeInterval: 5.0, target: self, selector: #selector(NotesViewController.nextSentence), userInfo: nil, repeats: true)
        
        let runLoop = RunLoop.main
        runLoop.add(timer, forMode: .commonModes)
    }
    // MARK: - －－－－－－－－－－－－－
    
    // 添加一条便签之后的回调方法
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
        
        let yPosition = self.navigationController!.navigationBar.frame.maxY
        let relyPoint = CGPoint(x: 30, y: yPosition - 5.0)
        
        let popupMenu = YBPopupMenu.show(at: relyPoint, titles: optionNames, icons: optionIconNames, menuWidth: 132, delegate: self)
        popupMenu!.isShadowShowing = true
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

// MARK: - YBPopupMenuDelegate
extension NotesViewController: YBPopupMenuDelegate {
    func ybPopupMenuDidSelected(at index: Int, ybPopupMenu: YBPopupMenu!) {
        if index == 0 {
            self.performSegue(withIdentifier: "ToStatistics", sender: self)
        }
        else {
            self.performSegue(withIdentifier: "ToHistoryNotes", sender: self)
        }
    }
}


// MARK: - UIScrollViewDelegate
extension NotesViewController: UIScrollViewDelegate {
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        
        if scrollView == sentenceScrollView {
            timer.invalidate()
            timer = nil
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        
        if scrollView == sentenceScrollView {
            fireTimer()
        }

    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        if scrollView === sentenceScrollView {
            updateCurrentPage(scrollView: scrollView)
            
            checkBounds(scrollView: scrollView)
        }
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
        if scrollView === sentenceScrollView {
            updateCurrentPage(scrollView: scrollView)
            
            checkBounds(scrollView: scrollView)
        }
    }
    
}

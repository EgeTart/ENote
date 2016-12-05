//
//  HistoryNotesViewController.swift
//  ENote
//
//  Created by min-mac on 16/12/4.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit

class HistoryNotesViewController: UIViewController {

    @IBOutlet weak var notesCollectionView: UICollectionView!
    
    let databaseManager = DatabaseManager.sharedManager
    
    var beginDate = Date(timeInterval: -24 * 60 * 60, since: Date())
    
    var historyNotes = [[Note]]()
    
    var sectionTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyNotes = databaseManager.queryHistoryNotes(beginDate: beginDate)
        
        sectionTitles = historyNotes.map({ (notes: [Note]) -> String in
            return notes[0].date
        })
        
        notesCollectionView.register(UINib(nibName: "HistoryNoteCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HistoryNoteCell")
        
        notesCollectionView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        
        notesCollectionView.dataSource = self
        
        if let layout = notesCollectionView.collectionViewLayout as? HistoryNotesLayout {
            layout.delegate = self
        }
    }
    
    func heightForContent(content: String, font: UIFont, width: CGFloat) -> CGFloat {
        
        let rect = NSString(string: content).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(rect.height)
    }
}

extension HistoryNotesViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return historyNotes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return historyNotes[section].count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let historyNoteCell = collectionView.dequeueReusableCell(withReuseIdentifier: "HistoryNoteCell", for: indexPath) as! HistoryNoteCell
        
        let note = historyNotes[indexPath.section][indexPath.item]
        
        historyNoteCell.dateLabel.text = note.date
        historyNoteCell.contentLabel.text = note.content
        
        if note.state {
            historyNoteCell.stateImageView.image = UIImage(named: "finish_icon")
        }
        else {
            historyNoteCell.stateImageView.image = UIImage(named: "unfinish_icon")
        }
        
        return historyNoteCell
    }
}


extension HistoryNotesViewController: HistoryNoteLayoutDelegate {
    func collectionView(_ collectionView: UICollectionView, heightForContentAtIndexPath indexPath: IndexPath, withWidth width: CGFloat) -> CGFloat {
        
        let note = historyNotes[indexPath.section][indexPath.item]
        
        let font = UIFont(name: "Helvetica Neue", size: 18)!
        let contentHeight = heightForContent(content: note.content, font: font, width: width)
        
        return contentHeight
    }
}

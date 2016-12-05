//
//  HistoryNotesViewController.swift
//  ENote
//
//  Created by min-mac on 16/12/4.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit
import MJRefresh

class HistoryNotesViewController: UIViewController {

    @IBOutlet weak var notesCollectionView: UICollectionView!
    
    let databaseManager = DatabaseManager.sharedManager
    
    var beginDate = Date(timeInterval: -24 * 60 * 60, since: Date())
    let fiveDaysInSeconds = -24 * 60 * 60 * 5.0
    
    var historyNotes = [[Note]]()
    
    var sectionTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        historyNotes = databaseManager.queryHistoryNotes(beginDate: beginDate)
        
        sectionTitles = historyNotes.map({ (notes: [Note]) -> String in
            return notes[0].date
        })
        
        notesCollectionView.register(UINib(nibName: "HistoryNoteCell", bundle: Bundle.main), forCellWithReuseIdentifier: "HistoryNoteCell")
        notesCollectionView.register(UINib(nibName: "NotesHeaderView", bundle: Bundle.main), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "NotesHeader")
        
        notesCollectionView.contentInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        
        notesCollectionView.dataSource = self
        
        if let layout = notesCollectionView.collectionViewLayout as? HistoryNotesLayout {
            layout.delegate = self
        }
        
        //notesCollectionView.mj_footer = MJRefreshFooter.init(refreshingTarget: self, refreshingAction: #selector(HistoryNotesViewController.loadMoreHistoryNotes))
        
        let footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(HistoryNotesViewController.loadMoreHistoryNotes))
        footer?.setTitle("上拉加载更多", for: .pulling)
        footer?.setTitle("正在加载.....", for: .refreshing)
        footer?.setTitle("全部加载完毕", for: .noMoreData)
        
        notesCollectionView.mj_footer = footer
    }
    
    func loadMoreHistoryNotes() {
        
        beginDate = Date(timeInterval: fiveDaysInSeconds, since: beginDate)
        
        let originCount = historyNotes.count
        
        let notes = databaseManager.queryHistoryNotes(beginDate: beginDate)
        historyNotes.append(contentsOf: notes)
        
        if notes.count == 0 {
            print("no more notes")
            notesCollectionView.mj_footer.endRefreshingWithNoMoreData()
        }
        
        let titles = notes.map { (notes: [Note]) -> String in
            return notes[0].date
        }
        sectionTitles.append(contentsOf: titles)
        
        notesCollectionView.mj_footer.endRefreshing()
        
        print(sectionTitles)
        print(historyNotes.count)
        
        let range = Range<Int>(uncheckedBounds: (lower: originCount, upper: historyNotes.count))
        let indexSet = IndexSet(integersIn: range)
        
        notesCollectionView.insertSections(indexSet)
        let indexPath = IndexPath(item: 0, section: originCount)
        
        notesCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        notesCollectionView.scrollsToTop = true
        
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        let sectionTitle = sectionTitles[indexPath.section]
        
        let notesHeaderView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NotesHeader", for: indexPath) as! NotesHeaderView
        notesHeaderView.dateLabel.text = sectionTitle
        
        return notesHeaderView
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

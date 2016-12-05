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
    
    var backupHistoryNotes: [[Note]]!
    var backupSectionTitles: [String]!
    var contentOffset: CGPoint!
    
    lazy var searchController = UISearchController(searchResultsController: nil)
    
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
        
        setupRefreshFooter()
        
        NotificationCenter.default.addObserver(self, selector: #selector(HistoryNotesViewController.deviceOrientionChanged(notification:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    func setupRefreshFooter() {
        let footer = MJRefreshBackNormalFooter(refreshingTarget: self, refreshingAction: #selector(HistoryNotesViewController.loadMoreHistoryNotes))
        footer?.setTitle("上拉加载更多", for: .idle)
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
        
        let range = Range<Int>(uncheckedBounds: (lower: originCount, upper: historyNotes.count))
        let indexSet = IndexSet(integersIn: range)
        
        notesCollectionView.insertSections(indexSet)
        let indexPath = IndexPath(item: 0, section: originCount)
        
        notesCollectionView.scrollToItem(at: indexPath, at: .top, animated: true)
        notesCollectionView.scrollsToTop = true
        
    }
    
    func searchHistoryNotes(content: String) {
        
        if backupHistoryNotes == nil {
            backupHistoryNotes = historyNotes
            backupSectionTitles = sectionTitles
            contentOffset = notesCollectionView.contentOffset
        }
        
        notesCollectionView.mj_footer = nil
        
        historyNotes = databaseManager.queryHistoryNotes(content: content)
        
        sectionTitles = historyNotes.map({ (notes: [Note]) -> String in
            return notes[0].date
        })
        
        notesCollectionView.reloadData()
        notesCollectionView.contentOffset = CGPoint(x: 0, y: 0)
        
    }
    
    func deviceOrientionChanged(notification: Notification) {
        notesCollectionView.reloadData()
    }
    
    func heightForContent(content: String, font: UIFont, width: CGFloat) -> CGFloat {
        
        let rect = NSString(string: content).boundingRect(with: CGSize(width: width, height: CGFloat(MAXFLOAT)), options: .usesLineFragmentOrigin, attributes: [NSFontAttributeName: font], context: nil)
        
        return ceil(rect.height)
    }
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {

        searchController.hidesNavigationBarDuringPresentation = true
        searchController.searchBar.delegate = self
        
        present(searchController, animated: true, completion: nil)
    }
    
    @IBAction func undo(_ sender: UIBarButtonItem) {
        if backupHistoryNotes != nil {
            historyNotes = backupHistoryNotes
            sectionTitles = backupSectionTitles
            
            notesCollectionView.reloadData()
            notesCollectionView.contentOffset = contentOffset
            backupHistoryNotes = nil
            backupSectionTitles = nil
            
            setupRefreshFooter()
        }
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

extension HistoryNotesViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print(searchBar.text!)
        
        let searchText = searchBar.text!.trimmingCharacters(in: CharacterSet.whitespaces)
        dismiss(animated: true, completion: nil)
        
        if searchText != "" {
            searchHistoryNotes(content: searchText)
        }
        
        searchBar.text = nil
    }
}

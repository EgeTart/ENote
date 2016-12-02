//
//  NotesManager.swift
//  ENote
//
//  Created by min-mac on 16/12/1.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import Foundation

class NotesManager {
    
    var notes = [Note]()
    
    static let sharedManager = NotesManager()
    
    let databaseManager = DatabaseManager.sharedManager
    
    private init() {
        notes = databaseManager.todayNodes()
    }
    
    func updateTodayNotes() {
        notes = databaseManager.todayNodes()
    }
}

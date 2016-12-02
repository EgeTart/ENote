//
//  DatabaseManager.swift
//  ENote
//
//  Created by min-mac on 16/12/1.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import Foundation
import FMDB

class DatabaseManager {
    
    static let sharedManager = DatabaseManager()
    
    private var database: FMDatabase!
    
    private init() {
        createTables()
    }
    
    // MARK: - 私有方法
    
    private func createTables() {
        
        // 获取数据库文件所在路径
        let documentDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0]
        let documentPath = URL(fileURLWithPath: documentDirectory, isDirectory: true, relativeTo: nil)
        let databasePath = documentPath.appendingPathComponent("notes.sqlite3").absoluteString
        
        print(databasePath)
        database = FMDatabase(path: databasePath)
        
        if !database.open() {
            print("数据库打开失败")
            return
        }
        
        // 执行创建表的SQL语句
        let historyNotesTable = "CREATE TABLE IF NOT EXISTS history_notes(id INTEGER PRIMARY KEY AUTOINCREMENT, note_date DATE NOT NULL, content TEXT NOT NULL, state BOOLEAN NOT NULL)"
        let historyNotesTableState = database.executeStatements(historyNotesTable)
        
        let todayNotesTable = "CREATE TABLE IF NOT EXISTS today_notes(id INTEGER PRIMARY KEY AUTOINCREMENT, note_date DATE NOT NULL DEFAULT (datetime('now', 'localtime')), content TEXT NOT NULL UNIQUE, state BOOLEAN NOT NULL DEFAULT false)"
        let todayNotesTableState = database.executeStatements(todayNotesTable)
        
        if historyNotesTableState && todayNotesTableState {
            print("成功创建表")
        }
        else {
            print("创建表失败")
        }
    }
    
    
    // MARK: - 公有方法
    
    // 添加一条待做事件
    func insertNote(content: String) {
        let insertNoteSql = "INSERT INTO today_notes (content) VALUES(?)"
        
        do {
            try database.executeUpdate(insertNoteSql, values: [content])
            NotesManager.sharedManager.updateTodayNotes()
        }
        catch {
            print(error)
        }
    }
    
    // 更新事件状态
    func updateNoteState(id: Int) {
        let updateNoteSql = "UPDATE today_notes SET state = (?) WHERE id = (?)"
        
        do{
            try database.executeUpdate(updateNoteSql, values: [true, id])
            NotesManager.sharedManager.updateTodayNotes()
        }
        catch {
            print(error)
        }
    }
    
    // 删除事件
    func deleteNote(id: Int) {
        let deleteNoteSql = "DELETE FROM today_notes WHERE id = (?)"
        
        do {
            try database.executeUpdate(deleteNoteSql, values: [id])
            NotesManager.sharedManager.updateTodayNotes()
        }
        catch {
            print(error)
        }
    }
    
    func todayNodes() -> [Note] {
        let queryAllNoteSql = "SELECT * FROM today_notes ORDER BY note_date DESC"
        var notes = [Note]()
        var finishedNotes = [Note]()
        
        do {
            let noteRecords = try database.executeQuery(queryAllNoteSql, values: nil)
            
            while noteRecords.next() {
                let id = noteRecords.int(forColumn: "id")
                let content = noteRecords.string(forColumn: "content")
                let date = noteRecords.date(forColumn: "note_date")
                let state = noteRecords.bool(forColumn: "state")
                
                let note = Note(id: Int(id), content: content!, date: date!, state: state)
                
                if state {
                    finishedNotes.append(note)
                }
                else {
                    notes.append(note)
                }
                
                print(note.date)
            }
            
            notes.append(contentsOf: finishedNotes)
            
        }
        catch {
            print(error)
        }
        
        return notes
    }
}

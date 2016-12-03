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
        
        let todayNotesTable = "CREATE TABLE IF NOT EXISTS today_notes(id INTEGER PRIMARY KEY AUTOINCREMENT, note_date DATETIME NOT NULL DEFAULT (datetime('now', 'localtime')), content TEXT NOT NULL UNIQUE, state BOOLEAN NOT NULL DEFAULT 0)"
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
                
            }
            
            notes.append(contentsOf: finishedNotes)
            
        }
        catch {
            print(error)
        }
        
        return notes
    }
    
    func updateHistoryTable() {
        let updateHistoryNotesSql = "INSERT INTO history_notes (content, note_date, state) SELECT content, note_date, state FROM today_notes WHERE date(note_date) != date('now')"
        
        let deleteExpireNotesSql = "DELETE FROM today_notes WHERE date(note_date) != date('now')"
        
        do {
            try database.executeUpdate(updateHistoryNotesSql, values: nil)
            try database.executeUpdate(deleteExpireNotesSql, values: nil)
        }
        catch {
            print(error)
        }
        
        NotesManager.sharedManager.updateTodayNotes()
    }
    
    func historyDataStatistics(beginTime: Date, endTime: Date) -> [DailyNotesStatistics] {
        
        let queryFinishedNotesSql = "SELECT date(note_date), count(state) AS finish_count FROM history_notes WHERE state = 1 AND date(?) <= note_date AND date(note_date) <= date(?) GROUP BY date(note_date)"
        
        let queryUnfinishedNoteSql = "SELECT date(note_date), count(state) AS unfinish_count FROM history_notes WHERE state = 0 AND date(?) <= note_date AND date(note_date) <= date(?) GROUP BY date(note_date)"
        
        let beginTimeInFormatte = dateInFormatte(date: beginTime, formatte: "yyyy-MM-dd")
        let endTimeInFormatte = dateInFormatte(date: endTime, formatte: "yyyy-MM-dd")
        
        var notesStatistics = [DailyNotesStatistics]()
        
        do {
            let finishedRecord = try database.executeQuery(queryFinishedNotesSql, values: [beginTimeInFormatte, endTimeInFormatte])
            let unfinishRecord = try database.executeQuery(queryUnfinishedNoteSql, values: [beginTimeInFormatte, endTimeInFormatte])
            
            while finishedRecord.next() && unfinishRecord.next() {
                let date = finishedRecord.string(forColumnIndex: 0)!
                let finishedCount = Int(finishedRecord.longLongInt(forColumn: "finish_count"))
                let unfinishedCount = Int(unfinishRecord.longLongInt(forColumn: "unfinish_count"))
                
                let dailyNotesStatistics = DailyNotesStatistics(date: date, finishedCount: finishedCount, unfinishedCount: unfinishedCount)
                
                notesStatistics.append(dailyNotesStatistics)
            }
        }
        catch {
            print(error)
        }
        
        return notesStatistics
    }

    // 虚假数据填充函数
    func fillData() {
        let dataPart1 = ["今天上午10点", "今天中午", "下午6点",
                      "晚上7点", "今天晚上", "下午6点之前", "晚上7点开始", "晚上10点以后"]
        
        let dataPart2 = ["看完数据库原理与应用第三章, 做好知识归纳和总结", "跑内环",
                      "编写iOS项目中的数据库模块, 做好相应的功能测试",
                      "完成需求分析说明书的撰写工作，根据需求分析画出功能流程图",
                      "学习Javascript和React Native, 运行官方例子, 从中学习代码结构和功能实现",
                      "做好课程设计, 完成代码打包和文档编写",
                      "学习Swift3.0, 根据官方文档学习新的语法和API, 到著名的论坛去看相关的博客",
                      "看美剧, 练习英语听力能力, 英语为六级考试做好准备"]
        
        for i in 1...1200 {
            let index1 = Int(arc4random() % 8)
            let index2 = Int(arc4random() % 8)
            
            let content = dataPart1[index1] + dataPart2[index2]
            let state = Int(arc4random() % 2)
            
            let beforeDay = i / 5 + 1
            
            let insertDataSql = "INSERT INTO history_notes (content, note_date, state) VALUES (?, datetime('now', '-\(beforeDay) day'), ?)"
            
            print(insertDataSql)
            
            do {
                try database.executeUpdate(insertDataSql, values: [content, state])
            }
            catch {
                print(error)
            }
        }
    }
}

//
//  DailyNotesStatistics.swift
//  ENote
//
//  Created by min-mac on 16/12/2.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import Foundation

class NotesStatistics {
    var date: String!
    var timeLabel: String!
    var finishedCount: Int!
    var unfinishedCount: Int!
    
    init(date: String, timeLabel: String, finishedCount: Int, unfinishedCount: Int) {
        self.date = date
        self.timeLabel = timeLabel
        self.finishedCount = finishedCount
        self.unfinishedCount = unfinishedCount
    }
    
}

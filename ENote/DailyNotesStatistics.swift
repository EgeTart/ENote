//
//  DailyNotesStatistics.swift
//  ENote
//
//  Created by min-mac on 16/12/2.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import Foundation

class DailyNotesStatistics {
    var date: String!
    var finishedCount: Int!
    var unfinishedCount: Int!
    
    init(date: String, finishedCount: Int, unfinishedCount: Int) {
        self.date = date
        self.finishedCount = finishedCount
        self.unfinishedCount = unfinishedCount
    }
    
}

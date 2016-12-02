//
//  Note.swift
//  ENote
//
//  Created by min-mac on 16/12/1.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import Foundation

class Note {
    var id: Int
    var content: String
    var date: Date
    var state: Bool
    
    init(id: Int, content: String, date: Date, state: Bool) {
        self.id = id
        self.content = content
        self.date = date
        self.state = state
    }
}

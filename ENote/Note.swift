//
//  Note.swift
//  ENote
//
//  Created by min-mac on 16/12/1.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import Foundation

class Note: NSObject {
    var id: Int
    var content: String
    var date: String
    var state: Bool
    
    init(id: Int, content: String, date: String, state: Bool) {
        self.id = id
        self.content = content
        self.date = date
        self.state = state
    }
    
    override var description: String {
        return date + ": " + content
    }
}

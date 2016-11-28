//
//  Sentence.swift
//  ENote
//
//  Created by min-mac on 16/11/28.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import Foundation

class Sentence {
    var englishSentence: String?
    var pictureURL: String?
    
    init(dict: Dictionary<String, Any>) {
        self.englishSentence = dict["content"] as? String
        self.pictureURL = dict["picture2"] as? String
    }
}

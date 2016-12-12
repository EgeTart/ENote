//
//  DailySentenceView.swift
//  ENote
//
//  Created by min-mac on 16/12/12.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit

class DailySentenceView: UIView {

    @IBOutlet weak var sentenceImageView: UIImageView!
    @IBOutlet weak var sentenceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let width = UIScreen.main.bounds.width
        let height = width / 2.0
        
        self.frame.size = CGSize(width: width, height: height)
    }
}

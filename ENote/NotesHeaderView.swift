//
//  NotesHeaderView.swift
//  ENote
//
//  Created by min-mac on 16/12/5.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit

class NotesHeaderView: UICollectionReusableView {

    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.frame.size.height = 30.0
        self.frame.size.width = UIScreen.main.bounds.width
    }
    
}

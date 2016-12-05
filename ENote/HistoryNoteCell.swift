//
//  HistoryNoteCell.swift
//  ENote
//
//  Created by min-mac on 16/12/4.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit

class HistoryNoteCell: UICollectionViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var contentLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.backgroundColor = UIColor(patternImage: UIImage(named: "texture")!)
        
        self.layer.cornerRadius = 5.0
    }

}

//
//  NoteCell.swift
//  ENote
//
//  Created by min-mac on 16/12/2.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit

class NoteCell: UITableViewCell {

    @IBOutlet weak var noteContainerView: UIView!
    @IBOutlet weak var contentLable: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        //noteContainerView.backgroundColor = UIColor(red: 233.0 / 255.0, green: 240.0 / 255.0, blue: 158.0 / 255.0, alpha: 0.7)
        noteContainerView.backgroundColor = UIColor(patternImage: UIImage(named: "texture")!)
        noteContainerView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5).cgColor
        noteContainerView.layer.shadowRadius = 3.0
        noteContainerView.layer.shadowOffset = CGSize(width: 2, height: 4)
        noteContainerView.layer.shadowOpacity = 1.0
        
        noteContainerView.layer.cornerRadius = 5.0
    }

}

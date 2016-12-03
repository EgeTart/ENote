//
//  Helper.swift
//  ENote
//
//  Created by min-mac on 16/12/2.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import Foundation


func dateInFormatte(date: Date, formatte: String) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = formatte
    
    let dateInFormatte = dateFormatter.string(from: date)
    
    return dateInFormatte
}

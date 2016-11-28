//
//  ViewController.swift
//  ENote
//
//  Created by min-mac on 16/11/28.
//  Copyright © 2016年 EgeTart. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class ViewController: UIViewController {

    @IBOutlet weak var sentenceContainerView: UIView!
    @IBOutlet weak var sentenceImageView: UIImageView!
    @IBOutlet weak var sentenceLabel: UILabel!
    
    var sentence: Sentence!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        getDailySentence()
    }
    
    func currentDateInFormate() -> String {
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let dateInString = dateFormatter.string(from: date)
        
        return dateInString
    }

    func getDailySentence() {
        
        let currentDate = currentDateInFormate()
        
        Alamofire.request("http://open.iciba.com/dsapi/", method: .get, parameters: ["date": currentDate], encoding: URLEncoding.default, headers: nil).responseJSON { (response) in
            
            if let result = response.result.value as? Dictionary<String, Any> {
                self.sentence = Sentence(dict: result)
                self.sentenceLabel.text = self.sentence.englishSentence
                
                self.sentenceImageView.sd_setImageTmp(with: URL(string: self.sentence.pictureURL!)!, placeholderImage: UIImage(named: "saffron"), completed: { (_, _, _, _) in
                    self.dismissSentenceContainerView()
                })
            }
            else {
                self.sentenceImageView.image = UIImage(named: "saffron")
                self.dismissSentenceContainerView()
            }
        }
    }
    
    func dismissSentenceContainerView() {
        
        UIView.animate(withDuration: 2.0, delay: 2.0, options: [], animations: {
            self.sentenceImageView.frame.size.width = self.view.frame.width * 1.5
            self.sentenceImageView.frame.size.height = self.view.frame.height * 1.5
            self.sentenceImageView.center = self.sentenceContainerView.center
            self.sentenceContainerView.alpha = 0

        }, completion: {_ in
            self.sentenceContainerView.removeFromSuperview()
        })
        
    }
}


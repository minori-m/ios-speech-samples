//
//  NoteDetailViewController.swift
//  memotest
//
//  Created by minori on 2018/03/16.
//  Copyright © 2018年 minori. All rights reserved.
//

import Foundation
import UIKit

class NoteDetailViewController: UIViewController,UITextViewDelegate{

    
    
    @IBOutlet weak var contentView: UITextView!
    
    //var defaultsContent : String = ""
    var userDefaults = UserDefaults.standard
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contentView.text = (userDefaults.object(forKey:"contents") as! Array<String>)[0]
//        self.view.addSubview(content)
       
        print(userDefaults.object(forKey:"contents") as! Array<String>)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

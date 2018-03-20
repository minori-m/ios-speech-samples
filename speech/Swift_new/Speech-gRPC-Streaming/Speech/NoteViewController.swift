//
//  NoteViewController.swift
//  memotest
//
//  Created by minori on 2018/03/15.
//  Copyright © 2018年 minori. All rights reserved.
//

import Foundation
import UIKit

class NoteViewController : UIViewController,UITableViewDataSource,UITableViewDelegate
{
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //上記でセットしたidentifierのsegueであれば、
        //推移先のcontrollerの変数（ここではUIImage）に推移元のcontrollerのUIImageをセット
//        if segue.identifier == "allToDetail" {
//            let nav = segue.destination as! UINavigationController
//            let noteVC = nav.ViewController as! NoteDetailViewController
//            subVC.willEdit = imageView.image!
//        }
    }
    
    var userDefaults = UserDefaults.standard

    @IBOutlet var table: UITableView!

    override func viewDidLoad() {
        print("NoteViewController called")
        
        super.viewDidLoad()

        table.delegate = self
        table.dataSource = self
        table.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        table.estimatedRowHeight = 66
        table.rowHeight = UITableViewAutomaticDimension
    }

    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        print("cellnum called")
        if(userDefaults.object(forKey: "date") != nil){
        print("count",(userDefaults.object(forKey: "date")as! Array<String>).count)
        return (userDefaults.object(forKey: "date")as! Array<String>).count
        }else{
            return 0
        }
    }

    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("cellcontents called")
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tableCell",
                                             for: indexPath)


        // Tag番号 1 で UILabel for dateインスタンスの生成
        let dateLabel = cell.viewWithTag(1) as! UILabel
        
        //dateLabel.text = String(describing: dateArray[indexPath.row])
//        print(indexPath.row)
        
        // Tag番号 ２ で UILabel for contentsインスタンスの生成
        let contentsLabel = cell.viewWithTag(2) as! UILabel
        
        if (userDefaults.object(forKey: "date") != nil) {
            dateLabel.text = (userDefaults.object(forKey: "date") as! Array<String>)[indexPath.row]
            contentsLabel.text = (userDefaults.object(forKey: "contents") as! Array<String>)[indexPath.row]
        }
        
//        contentsLabel.text = String(describing: contentsArray[indexPath.row])
        contentsLabel.sizeToFit()
//        print(indexPath.row)

        //debug.text = "tableView"
        return cell
    }
    
    
}

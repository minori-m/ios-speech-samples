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
    
    //notedetailviewcontrollerへの値渡し
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //上記でセットしたidentifierのsegueであれば、
        //推移先のcontrollerの変数（ここではUIImage）に推移元のcontrollerのUIImageをセット
        if segue.identifier == "allToDetail" {
            
            let noteDetailViewController:NoteDetailViewController = segue.destination as! NoteDetailViewController
            print(String(describing: self.table.indexPathForSelectedRow))
            let indexPathSection : Int = (self.table.indexPathForSelectedRow?.row)!
            // 変数:遷移先ViewController型 = segue.destinationViewController as 遷移先ViewController型
            // segue.destinationViewController は遷移先のViewController
            
            noteDetailViewController.cellNum = indexPathSection
            print(indexPathSection)
        }

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
        
        print("indexpath.row=",indexPath.row)
        
        if (userDefaults.object(forKey: "date") != nil) {
            dateLabel.text = (userDefaults.object(forKey: "date") as! Array<String>)[indexPath.row]
            print(userDefaults.object(forKey: "date") as! Array<String>)
            print(userDefaults.object(forKey: "contents") as! Array<String>)
                
            contentsLabel.text = (userDefaults.object(forKey: "contents") as! Array<String>)[indexPath.row]
            
        }
        
//        contentsLabel.text = String(describing: contentsArray[indexPath.row])
        contentsLabel.sizeToFit()
        

        //debug.text = "tableView"
        return cell
    }
    
    
}

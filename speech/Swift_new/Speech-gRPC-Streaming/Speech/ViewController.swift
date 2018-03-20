//
//  ViewController.swift
//  memotest
//
//  Created by minori on 2018/02/18.
//  Copyright © 2018年 minori. All rights reserved.
//

import UIKit
import AVFoundation
import googleapis
import MediaPlayer


class ViewController: UIViewController ,
UITextViewDelegate{
//    class ViewController: UIViewController ,
//    UITableViewDataSource,UITableViewDelegate,UITableViewDelegate{
    
    @IBOutlet weak var debug: UILabel!
    //@IBOutlet var table: UITableView!
    @IBOutlet weak var recordingView: UITextView!
    
    
    
    var userDefaults = UserDefaults.standard
    
    @IBAction func resetButton(_ sender: Any) {
        userDefaults.removeObject(forKey: "contents")
        userDefaults.removeObject(forKey: "date")
    }
    
    var micStatus:Int = 0
    var dataNum : Int = 0
    var audioData: NSMutableData!
    let SAMPLE_RATE = 16000
    
    var dateArray:Array<String> = []
    
    var contentsArray:Array<String> = []
    
    var dateString:String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        table.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
//        table.estimatedRowHeight = 66
//        table.rowHeight = UITableViewAutomaticDimension
        
        AudioController.sharedInstance.delegate = self
        
        Konashi.shared().readyHandler = {() -> Void in
            Konashi.pinMode(KonashiDigitalIOPin.LED2, mode: KonashiPinMode.output)
            Konashi.digitalWrite(KonashiDigitalIOPin.LED2, value: KonashiLevel.high)
            Konashi.pinMode(KonashiDigitalIOPin.S1,mode:KonashiPinMode.input)
            Konashi.shared().digitalInputDidChangeValueHandler = {_,_  in
                print("sw=",  Konashi.digitalRead(KonashiDigitalIOPin.S1))
            }
        }
    }
    
//    //Table Viewのセルの数を指定
//    func tableView(_ table: UITableView,
//                   numberOfRowsInSection section: Int) -> Int {
//        print("count")
//        return dateArray.count
//
//    }
//
//    //各セルの要素を設定する
//    func tableView(_ table: UITableView,
//                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//
//        // tableCell の ID で UITableViewCell のインスタンスを生成
//        let cell = table.dequeueReusableCell(withIdentifier: "tableCell",
//                                             for: indexPath)
//
//
//        // Tag番号 1 で UILabel for dateインスタンスの生成
//        let dateLabel = cell.viewWithTag(1) as! UILabel
//        dateLabel.text = String(describing: dateArray[indexPath.row])
//        print(indexPath.row)
//
//        // Tag番号 ２ で UILabel for contentsインスタンスの生成
//        let contentsLabel = cell.viewWithTag(2) as! UILabel
//        contentsLabel.text = String(describing: contentsArray[indexPath.row])
//        contentsLabel.sizeToFit()
//        print(indexPath.row)
//
//        debug.text = "tableView"
//        return cell
//    }
    
    
    @IBAction func recordAudio(_ sender: NSObject) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
        dataNum = 0
//        if(dataNum<5){
//            dataNum+=1
//        }else{
//            dataNum=0
//        }
    }
    
    @IBAction func stopAudio(_ sender: NSObject) {
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
        
        //print(dataNum)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
}

extension ViewController: AudioControllerDelegate {
    func processSampleData(_ data: Data) -> Void {
        audioData.append(data)
        print("processsample")
        // We recommend sending samples in 100ms chunks
        let chunkSize : Int /* bytes/chunk */ = Int(0.1 /* seconds/chunk */
            * Double(SAMPLE_RATE) /* samples/second */
            * 2 /* bytes/sample */);
        
        if (audioData.length > chunkSize) {
            SpeechRecognitionService.sharedInstance.streamAudioData(audioData, completion: { [weak self] (response, error) in
                guard let strongSelf = self else {
                    return
                }
                
                if let error = error {
                    strongSelf.contentsArray.append(error.localizedDescription)
                    
                    print(strongSelf.contentsArray)
                } else if let response = response {
                    var finished = false
                    print(response)
                    var i:Int=0
                    for result in response.resultsArray! {
                        if let result = result as? StreamingRecognitionResult {
                            if result.isFinal {
                                finished = true
                            }
                            if i==0{
                                print((result.alternativesArray[0] as AnyObject).transcript)
                                i=1
                            }
                        }
                    }
                    
                    //print(((response.resultsArray[0] as! StreamingRecognitionResult).alternativesArray[0] as AnyObject).transcript)
                    print(String(describing:type (of:response)))
                    print(String(describing:type (of:response.description)))
                    
                    //時刻取得
                    let now = NSDate()
                    
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy/MM/dd \n HH:mm:ss"
                    
                    strongSelf.dateString = formatter.string(from: now as Date)
                    
                     strongSelf.recordingView.text = ((response.resultsArray[0] as! StreamingRecognitionResult).alternativesArray[0] as AnyObject).transcript
                    
                    if(self?.dataNum == 0){
//                        strongSelf.recordingView.text = ((response.resultsArray[0] as! StreamingRecognitionResult).alternativesArray[0] as AnyObject).transcript
////                        strongSelf.contentsArray.add (((response.resultsArray[0] as! StreamingRecognitionResult).alternativesArray[0] as AnyObject).transcript)
                    //strongSelf.dateArray[0] = dateString
                    }
//                    self?.dataNum = 1
//                    }else{
//
////                        strongSelf.contentsArray[strongSelf.contentsArray.count-1] = ((response.resultsArray[0] as! StreamingRecognitionResult).alternativesArray[0] as AnyObject).transcript
////                        strongSelf.dateArray[strongSelf.dateArray.count-1] = dateString
//                    }
//                    print(strongSelf.contentsArray)
                    //NSLog(String(describing: strongSelf.contentsArray[(self?.dataNum)!]))
                    if finished {
                        strongSelf.stopAudio(strongSelf)
                    }
                }
            })
            self.audioData = NSMutableData()
        }
        print(StreamingRecognizeResponse_SpeechEventType.endOfSingleUtterance)
        self.userDefaults.set(contentsArray, forKey: "contents")
        self.userDefaults.synchronize()
        
        //table.reloadData()
    }
    
    @IBAction func find(sender: UIButton) {
        Konashi.find()
    }
    
    @IBAction func saveButton(_ sender: Any) {
        if (self.recordingView.text != "" && self.recordingView.text != "!saved"){
            print("recorded")
            if(userDefaults.object(forKey: "date") != nil){
            print("defaults not nil")
                self.contentsArray = userDefaults.object(forKey: "contents") as! Array<String>
            self.dateArray = userDefaults.object(forKey: "date") as! Array<String>
            }

            self.contentsArray.append(self.recordingView.text)
            self.dateArray.append(dateString)

            userDefaults.set(self.contentsArray, forKey: "contents")
            userDefaults.set(self.dateArray, forKey: "date")

            self.recordingView.text = "!saved"
            print("saveButton")
        }else{
            self.recordingView.text = "please record new one"
        }
    }
    
    
}
    



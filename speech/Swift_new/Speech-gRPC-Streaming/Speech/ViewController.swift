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
UITableViewDataSource,UITableViewDelegate{
    
    @IBOutlet weak var debug: UILabel!
    @IBOutlet var table: UITableView!
    var micStatus:Int = 0
    var dataNum : Int = 0
    var audioData: NSMutableData!
    let SAMPLE_RATE = 16000
    let userDefaults = UserDefaults.standard
    
    var dateArray:NSMutableArray = []
    
    var contentsArray:NSMutableArray = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        table.register(UINib(nibName: "TableViewCell", bundle: nil), forCellReuseIdentifier: "TableViewCell")
        table.estimatedRowHeight = 66
        table.rowHeight = UITableViewAutomaticDimension
        
        AudioController.sharedInstance.delegate = self
        //UIApplication.shared.beginReceivingRemoteControlEvents()
        //base.ViewDidLoad ();
//        let commandCenter = MPRemoteCommandCenter.shared();
//        commandCenter.togglePlayPauseCommand.addTarget (self,action : Selector(("remoteToggledPlayPause:")))
        
//        //初期時点ではマイクはオフ
//        micStatus = 0
//        //初期時点ではメモデータ数は0
//        dataNum = -1
//        print("ViewController")
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    //Table Viewのセルの数を指定
    func tableView(_ table: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        print("count")
        return dateArray.count
        
    }
    
    //各セルの要素を設定する
    func tableView(_ table: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // tableCell の ID で UITableViewCell のインスタンスを生成
        let cell = table.dequeueReusableCell(withIdentifier: "tableCell",
                                             for: indexPath)
        
        
        // Tag番号 1 で UILabel for dateインスタンスの生成
        let dateLabel = cell.viewWithTag(1) as! UILabel
        dateLabel.text = String(describing: dateArray[indexPath.row])
        print(indexPath.row)
        
        // Tag番号 ２ で UILabel for contentsインスタンスの生成
        let contentsLabel = cell.viewWithTag(2) as! UILabel
        contentsLabel.text = String(describing: contentsArray[indexPath.row])
        contentsLabel.sizeToFit()
        print(indexPath.row)
        
        debug.text = "tableView"
        return cell
    }
    
    
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
    
//    override func remoteControlReceived(with event: UIEvent?) {
//        let rc = event!.subtype
//        let p =  self.becomeFirstResponder()
//        print("received remote control \(rc.rawValue)")
//        switch rc{
//        case .remoteControlTogglePlayPause:
//            print("toggle")
//            default:break
//        }
//    }
  
//    override func ViewDidLoad(){
//    base.ViewDidLoad ();
//    var commandCenter = MPRemoteCommandCenter.Shared;
//    commandCenter.TogglePlayPauseCommand.AddTarget (ToggledPlayPauseButton);
//    }
    
//    func remoteToggledPlayPause(event:MPRemoteCommandEvent)
//{
//    print("Toggled")
//    //return MPRemoteCommandHandlerStatus.success
//    }
    
    
//    func addRemoteControlEvent() {
//        let commandCenter = MPRemoteCommandCenter.shared()
//
//        commandCenter.togglePlayPauseCommand.addTarget(self, action: Selector(("remoteTogglePlayPause:")))
//        //commandCenter.playCommand.addTarget(self, action: "remotePlay:")
//        print("addRemote")
//    }
//
//    func remoteTogglePlayPause(event: MPRemoteCommandEvent) {
//        // イヤホンのセンターボタンを押した時の処理
//        debug.text=("toggle")
//        print("toggle")
//    }
            //        if micStatus==0{
    //            //マイクオン
    //            micStatus = 1
    //            //時刻取得
    //            let now = NSDate()
    //
    //            let formatter = DateFormatter()
    //            formatter.dateFormat = "yyyy/MM/dd HH:mm:ss"
    //
    //            let dateString = formatter.string(from: now as Date)
    //            dateArray[dataNum] = dateString
    //            //data数を加算
    //            if dataNum<5{
    //                dataNum+=1
    //            } else {
    //                dataNum = 0
    //            }
    //            startStreaming()
    //            print("micstatus : on")
    //            debug.text=("on")
    //        } else if micStatus==1{
    //            //マイクオフ
    //           stopStreaming()
    //        }
    //
    //    }
    //    func remotePlay(event: MPRemoteCommandEvent) {
    //        // プレイボタンが押された時の処理
    //        // （略）
    //       debug.text=("play")
    //        print("play")
    //    }
    
    //    private func startStreaming() {
    //        let audioSession = AVAudioSession.sharedInstance()
    //        try! audioSession.setCategory(AVAudioSessionCategoryRecord)
    //        audioData = NSMutableData()
    //        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
    //        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
    //        _ = AudioController.sharedInstance.start()
    //    }
    //
    //    private func stopStreaming() {
    //        _ = AudioController.sharedInstance.stop()
    //        SpeechRecognitionService.sharedInstance.stopStreaming()
    //    }
    
    
    
    
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
                    strongSelf.contentsArray.add(error.localizedDescription)
                    
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
                    
                    let dateString = formatter.string(from: now as Date)
                    
                    if(self?.dataNum == 0){
                        
                        strongSelf.contentsArray.add (((response.resultsArray[0] as! StreamingRecognitionResult).alternativesArray[0] as AnyObject).transcript)
                    strongSelf.dateArray.add(dateString)
                    self?.dataNum = 1
                    }else{
                        strongSelf.contentsArray[strongSelf.contentsArray.count-1] = ((response.resultsArray[0] as! StreamingRecognitionResult).alternativesArray[0] as AnyObject).transcript
                        strongSelf.dateArray[strongSelf.dateArray.count-1] = dateString
                    }
                    print(strongSelf.contentsArray)
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
        
        table.reloadData()
    }
}
    



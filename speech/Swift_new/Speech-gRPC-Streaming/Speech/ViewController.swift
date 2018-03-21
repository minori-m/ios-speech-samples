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
UITextViewDelegate,AVSpeechSynthesizerDelegate{
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
   
    var audioData: NSMutableData!
    let SAMPLE_RATE = 16000
    
    var dateArray:Array<String> = []
    
    var contentsArray:Array<String> = []
    
    var dateString:String = ""
    
    //0:none&saved, 1:under recording, 2:wait for saving
    var status:Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        talker.delegate = self as? AVSpeechSynthesizerDelegate
        AudioController.sharedInstance.delegate = self
        
        
        Konashi.shared().readyHandler = {() -> Void in
            Konashi.pinMode(KonashiDigitalIOPin.LED2, mode: KonashiPinMode.output)
            Konashi.digitalWrite(KonashiDigitalIOPin.LED2, value: KonashiLevel.high)
            Konashi.pinMode(KonashiDigitalIOPin.S1,mode:KonashiPinMode.input)
            var doubleClickSta:Int = 0
            Konashi.shared().digitalInputDidChangeValueHandler = {_,_  in
                //print("sw=",  Konashi.digitalRead(KonashiDigitalIOPin.S1).rawValue)
//                if (Konashi.digitalRead(KonashiDigitalIOPin.S1).rawValue == 1){
//                    let startTime = NSDate()
//                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.02) {
//                        while(Konashi.digitalRead(KonashiDigitalIOPin.S1).rawValue == 1){
//                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.005){
//                                print("delayed")
//                            }
//                        }
//                    }
//                    if (NSDate().timeIntervalSince(startTime as Date) < 500){
//                        print("short")
//                    } else{
//                        print("long")
//                    }
//                }
                doubleClickSta += 1
                if (Konashi.digitalRead(KonashiDigitalIOPin.S1).rawValue == 1){
                    print("buttun pushed")
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { // change 2 to desired number of seconds
                        
                        //single click
                        if (doubleClickSta == 2){
                            //start streaming と同じ
                            if (self.status == 0){
                                print("recording...")
                                self.recordAudio(self)
                            }else if (self.status == 1){
                                //stop audioと同じ
                                print("stop")
                                self.stopAudio(self)
                            }else if (self.status == 2){
                                print("save")
                                self.saveButton(self)
                            }
                        }else if (doubleClickSta>3){
                            print("doubleClick")
                            if (self.status == 2){
                                self.recordingView.text = ""
                                self.status = 0
                            }
                        }
                        
                        doubleClickSta = 0
                    }
                    
                }
            }
        }
    }
    

    
    @IBAction func recordAudio(_ sender: NSObject) {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryPlayAndRecord)
        } catch {
            
        }
        audioData = NSMutableData()
        _ = AudioController.sharedInstance.prepare(specifiedSampleRate: SAMPLE_RATE)
        SpeechRecognitionService.sharedInstance.sampleRate = SAMPLE_RATE
        _ = AudioController.sharedInstance.start()
        self.status = 1

    }
    
    let talker:AVSpeechSynthesizer = AVSpeechSynthesizer()
    var recorded: String?
    
    
    
    @IBAction func stopAudio(_ sender: NSObject) {
        
        if(self.status == 1){
        _ = AudioController.sharedInstance.stop()
        SpeechRecognitionService.sharedInstance.stopStreaming()
        
            self.status = 2
        print("self = ", self.recordingView.text)
            
        //読み上げ
        if self.talker.isSpeaking {
            self.talker.stopSpeaking(at: .immediate)
        }
        
        let utterance = AVSpeechUtterance(string: self.recordingView.text)
        utterance.voice = AVSpeechSynthesisVoice(language:"jp-JP")
        utterance.rate = 0.55
        utterance.volume = 1
        
        self.talker.speak(utterance)
        print(String(describing:StreamingRecognizeResponse_SpeechEventType.self))
        }
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
                    strongSelf.recordingView.text = error.localizedDescription
                    //strongSelf.contentsArray.append(error.localizedDescription)
                    
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
                    strongSelf.recorded = ((response.resultsArray[0] as! StreamingRecognitionResult).alternativesArray[0] as AnyObject).transcript
                    print(String(describing:type (of:((response.resultsArray[0] as! StreamingRecognitionResult).alternativesArray[0] as AnyObject).transcript!!)))
                    
                    
                    if finished {
                        strongSelf.stopAudio(strongSelf)
                        strongSelf.status = 2
                        print("finished")
                    }
                }
            })
            self.audioData = NSMutableData()
        }
        //print(StreamingRecognizeResponse_SpeechEventType.endOfSingleUtterance)
        
        
        //table.reloadData()
    }
    
    
    //Konashi 接続
    @IBAction func find(sender: UIButton) {
        Konashi.find()
    }
    
    //保存時の処理
    @IBAction func saveButton(_ sender: Any) {
        if (self.recordingView.text != "" && self.recordingView.text != "!saved" && self.status == 2){
            print("recorded")
            if(userDefaults.object(forKey: "date") != nil){
            print("defaults not nil")
            self.contentsArray = userDefaults.object(forKey: "contents") as! Array<String>
            self.dateArray = userDefaults.object(forKey: "date") as! Array<String>
            }

            self.contentsArray.append(self.recordingView.text)
            self.dateArray.append(self.dateString)
            
            print("in saveButton",contentsArray,dateArray)
            
            userDefaults.set(self.contentsArray, forKey: "contents")
            userDefaults.set(self.dateArray, forKey: "date")

            self.recordingView.text = "!saved"
            print("saveButton")
            self.status = 0
        }else{
            self.recordingView.text = "please record new one"
        }
    }
    
    
    
}
    



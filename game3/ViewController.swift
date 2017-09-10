//
//  ViewController.swift
//  game3
//
//  Created by CUAUHTEMOC HERNANDEZ on 9/8/17.
//  Copyright © 2017 TheGroup1. All rights reserved.
//

import UIKit
import CoreMotion
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var countdownLabel: UILabel!
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var StartButton: UIButton!
  
    var countdownTimer: Timer!
    var totalTime = 3
    var motionManager: CMMotionManager?
    var audioPlayer = AVAudioPlayer()
    var arr: [Double] = []
    var sum: Double = 0
    var batter = Batter()
    var player = Player()
    var strikes: Int = 0
    var hits: Int = 0
    var currentGamePoints: Int = 0
    var leaderboard: [Int] = []
    
    let myQueue = OperationQueue()
    
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    func updateTime() {
        countdownLabel.text = "\(timeFormatted(totalTime))"
        if totalTime != 0 {
            totalTime -= 1
        } else {
            totalTime = 3
            countdownLabel.text = "Swing!"
            if checkIfMotionIsAvailable() {
                startGyroUpdates(manager: motionManager!, queue: myQueue)
            } else {
                countdownLabel.text = "No motion sensor detected"
            }
            countdownTimer.invalidate()
        }
    }
    
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        return String(format: "%2d", seconds)
    }
    
    
    func getZrotation(data: CMGyroData!) -> Bool{
        if data.rotationRate.z < 3 {
            if arr.count > 0 {
                for i in arr {
                    sum += i
                }
                player.setHitScore(hitScore: Int((sum/Double(arr.count)*3)))
                DispatchQueue.main.async {
                    print("Batter: \(self.batter.getHitScore()), Player: \(self.player.getHitScore()) ")
                    if self.batter.checkIfHit(playersNum: self.player.getHitScore()){
                        self.hits += 1
                    } else {
                        self.countdownLabel.text = "Strike!"
                        self.currentGamePoints += self.player.getHitScore()
                        self.strikes += 1
                    }
                    self.speedLabel.text = "\(self.player.hitScore) points!"
                }
                sum = 0
                arr = []
                return true
            } else {
                return false
            }
        } else {
            arr.append(data.rotationRate.z)
            return false
        }
    }
    
    func strikerSound(){
        if strikes == 1 {
    
                do{
                    audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:   Bundle.main.path(forResource: "strike1", ofType: "mp3")!))
                    audioPlayer.prepareToPlay()
                }
                catch{
                    print(error)
                }
            
        }
    }
    
    
    func startGyroUpdates(manager: CMMotionManager, queue: OperationQueue){
        manager.gyroUpdateInterval = 1/60
        manager.startGyroUpdates(to: queue){
            (data: CMGyroData?, error: Error?) in
            if let checkData = data {
                if self.getZrotation(data: checkData) {
                    manager.stopGyroUpdates()
                    DispatchQueue.main.async {
                        self.checkStrikeOut()
                    }
                }
            } else if let errors = error{
                print(errors)
            }
        }
    }
    
    func checkIfMotionIsAvailable() -> Bool{
        motionManager = CMMotionManager()
        if let manager = motionManager {
            if manager.isDeviceMotionAvailable {
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    func resetGame(){
        strikes = 0
        hits = 0
        currentGamePoints = 0
    }
    
    func checkStrikeOut(){
        if strikes == 3 {
            countdownLabel.text = "You WIN!"
            leaderboard.append(currentGamePoints)
            resetGame()
        } else if hits == 1 {
            countdownLabel.text = "The batter hit the ball, You Lose"
            resetGame()
        }
    }
    
    func BubbleSort(arr: [Int]){
        for i in 0..<arr.count {
            if arr[i] < arr[i + 1] {
                var temp = arr[i];
            }
        }
    }
    
    @IBAction func startButton(_ sender: UIButton) {
        startTimer()
        audioPlayer.play()
        batter.generateHitScore()
    }
    
    @IBAction func leaderboardButton(_ sender: UIButton) {
        countdownLabel.text = ""
        
    }
    
    func accessSoundFiles(){
        do{
            audioPlayer = try AVAudioPlayer(contentsOf: URL.init(fileURLWithPath:   Bundle.main.path(forResource: "3,2,1,Swing", ofType: "m4a")!))
            audioPlayer.prepareToPlay()
        }
        catch{
            print(error)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        accessSoundFiles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}




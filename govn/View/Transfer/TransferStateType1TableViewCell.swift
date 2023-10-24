//
//  TransferStateType1TableViewCell.swift
//  indogo
//
//  Created by mac on 2020/8/31.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class TransferStateType1TableViewCell: UITableViewCell {
    @IBOutlet weak var boxV: UIView!
    @IBOutlet weak var barV: UIView!
    @IBOutlet weak var barTitleL: UILabel!
    @IBOutlet weak var barNumberV: UIView!
    @IBOutlet weak var n0L: UILabel!
    @IBOutlet weak var n1L: UILabel!
    @IBOutlet weak var n2L: UILabel!
    @IBOutlet weak var n3L: UILabel!
    @IBOutlet weak var n4L: UILabel!
    @IBOutlet weak var n5L: UILabel!
    @IBOutlet weak var barTimeL: UILabel!
    @IBOutlet weak var plotView: UIView!
    @IBOutlet weak var pureTextV: UIView!
    @IBOutlet weak var pureNameL: UILabel!
    @IBOutlet weak var pureValueL: UILabel!
    @IBOutlet weak var pureCodeL: UILabel!
    @IBOutlet weak var pinCodeL: UILabel!
    @IBOutlet weak var upTotalL: UILabel!
    
    @IBOutlet weak var upV: UIView!
    @IBOutlet weak var upIconIgV: UIImageView!
    @IBOutlet weak var upIDL: UILabel!
    @IBOutlet weak var upValueL: UILabel!
    @IBOutlet weak var upNoteL: UILabel!
    @IBOutlet weak var questionImgV: UIImageView!
    
    @IBOutlet weak var midL: UILabel!
    
    @IBOutlet weak var downV: UIView!
    @IBOutlet weak var downIconIgV: UIImageView!
    @IBOutlet weak var downNameL: UILabel!
    @IBOutlet weak var downIDL: UILabel!
    @IBOutlet weak var downValueL: UILabel!
    @IBOutlet weak var downNoteL: UILabel!
    
    @IBOutlet weak var downType2V: UIView!
    @IBOutlet weak var downType2L1: UILabel!
    @IBOutlet weak var downType2L2: UILabel!
    @IBOutlet weak var downType2L3: UILabel!
    @IBOutlet weak var downType2L4: UILabel!
    @IBOutlet weak var downType2L5: UILabel!
    
    @IBOutlet weak var failV: UIView!
    @IBOutlet weak var failIconIgV: UIImageView!
    @IBOutlet weak var failNameL: UILabel!
    @IBOutlet weak var failIDL: UILabel!
    @IBOutlet weak var failValueL: UILabel!
    @IBOutlet weak var failNoteL: UILabel!
    
    @IBOutlet weak var failType2V: UIView!
    @IBOutlet weak var failType2L1: UILabel!
    @IBOutlet weak var failType2L2: UILabel!
    @IBOutlet weak var failType2L3: UILabel!
    @IBOutlet weak var failType2L4: UILabel!
    @IBOutlet weak var failType2L5: UILabel!
    
    @IBOutlet weak var plotWholeLineV: UIView!
    @IBOutlet weak var plotBar1V: UIView!
    @IBOutlet weak var plotBar2V: UIView!
    @IBOutlet weak var plotBar3V: UIView!
    @IBOutlet weak var plotBar4V: UIView!
    
    @IBOutlet weak var plotL1: UILabel!
    @IBOutlet weak var plotL2: UILabel!
    @IBOutlet weak var plotL3: UILabel!
    @IBOutlet weak var plotL4: UILabel!
    
    @IBOutlet weak var plotC1V: UIView!
    @IBOutlet weak var plotC1SubV: UIView!
    
    @IBOutlet weak var plotC2V: UIView!
    @IBOutlet weak var plotC2SubV: UIView!
    
    @IBOutlet weak var plotC3V: UIView!
    @IBOutlet weak var plotC3SubV: UIView!
    
    @IBOutlet weak var plotC4V: UIView!
    @IBOutlet weak var plotC4SubV: UIView!
    
    var countDownTimer:Timer!
    var startCountDown = false
    var expireTime:Date!
    
    func setTransferState(Stae stateStr:String) {
        startCountDown = false
        plotBar1V.isHidden = true
        plotBar2V.isHidden = true
        plotBar3V.isHidden = true
        plotBar4V.isHidden = true
        
        plotBar1V.backgroundColor = Color_Main_Red
        plotBar2V.backgroundColor = Color_Main_Red
        plotBar3V.backgroundColor = Color_Main_Red
        plotBar4V.backgroundColor = Color_Main_Red
        
        plotC1V.backgroundColor = .black
        plotC2V.backgroundColor = .black
        plotC3V.backgroundColor = .black
        plotC4V.backgroundColor = .black
        
        plotL1.font = UIFont.systemFont(ofSize: 13)
        plotL2.font = UIFont.systemFont(ofSize: 13)
        plotL3.font = UIFont.systemFont(ofSize: 13)
        plotL4.font = UIFont.systemFont(ofSize: 13)
        
        if stateStr == "1" {
            plotBar1V.isHidden = false
            plotC1V.backgroundColor = Color_Main_Red
            plotL1.font = UIFont.boldSystemFont(ofSize: 13)
            
        } else if stateStr == "2" {
            plotBar1V.isHidden = false
            plotBar2V.isHidden = false
            
            plotC1V.backgroundColor = Color_Main_Red
            plotC2V.backgroundColor = Color_Main_Red
            
            plotL1.font = UIFont.boldSystemFont(ofSize: 13)
            plotL2.font = UIFont.boldSystemFont(ofSize: 13)
            
        } else if stateStr == "3" {
            plotBar1V.isHidden = false
            plotBar2V.isHidden = false
            plotBar3V.isHidden = false
            
            plotC1V.backgroundColor = Color_Main_Red
            plotC2V.backgroundColor = Color_Main_Red
            plotC3V.backgroundColor = Color_Main_Red
            
            plotL1.font = UIFont.boldSystemFont(ofSize: 13)
            plotL2.font = UIFont.boldSystemFont(ofSize: 13)
            plotL3.font = UIFont.boldSystemFont(ofSize: 13)
            
            
        } else if stateStr == "4" {
            plotBar1V.isHidden = false
            plotBar2V.isHidden = false
            plotBar3V.isHidden = false
            plotBar4V.isHidden = false
            
            plotC1V.backgroundColor = Color_Main_Red
            plotC2V.backgroundColor = Color_Main_Red
            plotC3V.backgroundColor = Color_Main_Red
            plotC4V.backgroundColor = Color_Main_Red
            
            plotL1.font = UIFont.boldSystemFont(ofSize: 13)
            plotL2.font = UIFont.boldSystemFont(ofSize: 13)
            plotL3.font = UIFont.boldSystemFont(ofSize: 13)
            plotL4.font = UIFont.boldSystemFont(ofSize: 13)
            
        } else if stateStr == "5" {
            
        }
        
    }
    
    func startCountDown(Time str:String) {
        expireTime = UtilityTool().dateStringToDate(Str: str)
        
        startCountDown = true
        if countDownTimer == nil {
            countDownTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(countDown), userInfo: nil, repeats: true)
            startCountDown = true
        }
    }
    
    @objc func countDown() {
        if startCountDown {
            let diffTime = expireTime.timeIntervalSince(Date())
            if diffTime <= 0 {
                startCountDown = false
                countDownTimer.invalidate()
                countDownTimer = nil
                showTimeL(0)
            } else {
                let timeIntDiff = Int(diffTime)
                showTimeL(timeIntDiff)
            }
        }
    }
    
    func showTimeL(_ diffTime:Int) {
        let leftSecs = diffTime%60
        self.n5L.text = "\(leftSecs%10)"
        self.n4L.text = "\(Int(leftSecs/10))"
        
        let leftMins = Int(diffTime/60)%60
        self.n3L.text = "\(leftMins%10)"
        self.n2L.text = "\(Int(leftMins/10))"
        
        let leftHours = Int(diffTime/3600)
        self.n1L.text = "\(leftHours%10)"
        self.n0L.text = "\(Int(leftHours/10))"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        plotL1.text = NSLocalizedString("Transfer State Plot Text L1", comment: "")
        plotL2.text = NSLocalizedString("Transfer State Plot Text L2", comment: "")
        plotL3.text = NSLocalizedString("Transfer State Plot Text L3", comment: "")
        plotL4.text = NSLocalizedString("Transfer State Plot Text L4", comment: "")
        
        pinCodeL.text = NSLocalizedString("Transfer State 1 KODE PIN", comment: "")
        upTotalL.text = NSLocalizedString("Transfer Confirm Total Title", comment: "")
        
        /*
        plotWholeLineV.layer.cornerRadius = plotWholeLineV.frame.size.height/2
        plotWholeLineV.layer.borderColor = Color_Main_LightGray.cgColor
        plotWholeLineV.layer.borderWidth = 0.5
        */
        
        plotBar1V.layer.cornerRadius = plotBar1V.frame.size.height/2
        plotBar2V.layer.cornerRadius = plotBar2V.frame.size.height/2
        plotBar3V.layer.cornerRadius = plotBar3V.frame.size.height/2
        plotBar4V.layer.cornerRadius = plotBar4V.frame.size.height/2
        
        plotC1V.layer.cornerRadius = plotC1V.frame.size.height/2
        plotC1SubV.layer.cornerRadius = plotC1SubV.frame.size.height/2
        
        plotC2V.layer.cornerRadius = plotC2V.frame.size.height/2
        plotC2SubV.layer.cornerRadius = plotC2SubV.frame.size.height/2
        
        plotC3V.layer.cornerRadius = plotC3V.frame.size.height/2
        plotC3SubV.layer.cornerRadius = plotC3SubV.frame.size.height/2
        
        plotC4V.layer.cornerRadius = plotC4V.frame.size.height/2
        plotC4SubV.layer.cornerRadius = plotC4SubV.frame.size.height/2
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(callPhone))
        questionImgV.addGestureRecognizer(tap)
        questionImgV.isUserInteractionEnabled = true
        
    }
    
    @objc private func callPhone() {
        AppDelegate.shared().showFloatingContainer()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  CustomAlertView.swift
//  indogo
//
//  Created by mac on 2020/7/18.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

protocol CustomAlertDelegate {
    func customAlertnextAction(Ref obj:CustomAlertView)
    func customAlertnextActionSecond(Ref obj:CustomAlertView)
}

class CustomAlertView: UIView {
    
    var customDelegate:CustomAlertDelegate?

    public func initSimpleAlert(Title title:String, Content content:String, NextBtn1Str btnStr1:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = 50
        let centerY:CGFloat = self.frame.size.height/2
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 20
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.systemFont(ofSize: 25)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        labelTitleL.center = CGPoint(x: barView.center.x, y: labelTitleL.center.y)
        
        //內容
        startY += 6
        let labelContentL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        labelContentL.text = content
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        centerView.addSubview(labelContentL)
        
        //按鈕
        startY += labelContentL.frame.size.height + 35
        let nextBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        nextBtn.setTitle(btnStr1, for: .normal)
        nextBtn.backgroundColor = Color_Main_Red
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        startY += nextBtn.frame.size.height + 10
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-20)
        centerView.layer.cornerRadius = 15
        centerView.clipsToBounds = true
        
    }
    
    public func initAlert(Title title:String, Content content:String, NextBtn1Str btnStr1:String, CancelBtn1Str btnStr2:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = 50
        let centerY:CGFloat = self.frame.size.height/2
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 20
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.systemFont(ofSize: 25)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        labelTitleL.center = CGPoint(x: barView.center.x, y: labelTitleL.center.y)
        
        //內容
        startY += 6
        let labelContentL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        labelContentL.text = content
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        centerView.addSubview(labelContentL)
        
        //按鈕
        startY += labelContentL.frame.size.height + 35
        let nextBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        nextBtn.setTitle(btnStr1, for: .normal)
        nextBtn.backgroundColor = Color_Main_Red
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        startY += nextBtn.frame.size.height + 10
        
        let cancelBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        cancelBtn.setTitle(btnStr2, for: .normal)
        cancelBtn.layer.borderColor = Color_Main_Red.cgColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.setTitleColor(Color_Main_Red, for: .normal)
        cancelBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        startY += cancelBtn.frame.size.height + 20
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-20)
        centerView.layer.cornerRadius = 15
        centerView.clipsToBounds = true
        
    }
    
    //只用在刪除帳戶
    public func initSpecialAlert(Title title:String, Content content:String, NextBtn1Str btnStr1:String, CancelBtn1Str btnStr2:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = 50
        let centerY:CGFloat = self.frame.size.height/2
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 20
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.systemFont(ofSize: 25)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        labelTitleL.center = CGPoint(x: barView.center.x, y: labelTitleL.center.y)
        
        //內容
        startY += 6
        let labelContentL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        labelContentL.text = content
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        centerView.addSubview(labelContentL)
        
        //按鈕
        startY += labelContentL.frame.size.height + 35
        
        let cancelBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        cancelBtn.setTitle(btnStr2, for: .normal)
        cancelBtn.backgroundColor = Color_Main_Red
        cancelBtn.setTitleColor(.white, for: .normal)
        //cancelBtn.layer.borderColor = Color_Main_Red.cgColor
        //cancelBtn.layer.borderWidth = 1
        //cancelBtn.setTitleColor(Color_Main_Red, for: .normal)
        cancelBtn.layer.cornerRadius = cancelBtn.frame.size.height/2
        centerView.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        startY += cancelBtn.frame.size.height + 20
        
        let nextBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        nextBtn.setTitle(btnStr1, for: .normal)
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.layer.borderWidth = 1
        nextBtn.setTitleColor(Color_Main_Red, for: .normal)
        
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        startY += nextBtn.frame.size.height + 10
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-20)
        centerView.layer.cornerRadius = 15
        centerView.clipsToBounds = true
        
    }
    
    public func initAmountAlert(Title title:String, is509:Bool = false) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = 50
        let centerY:CGFloat = self.frame.size.height/2
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 20
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.systemFont(ofSize: 15)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        labelTitleL.center = CGPoint(x: barView.center.x, y: labelTitleL.center.y)
        
        let ary = AppDelegate.shared().tempTransferMaxWarningStr.components(separatedBy: " \(AppDelegate.shared().tempTransferMaxAmountStr) ")
        let content1 = ary[0]
        var content2 = ""
        
        if ary.count>1 {
            content2 = ary[1]
        }
        
        //內容1
        startY += 20
        
        let labelContentL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        if is509 {
            labelContentL.text = NSLocalizedString("Exceed Maximun Amout Content", comment: "") + AppDelegate.shared().tempTransferMaxWarningStr //content1
        } else {
            labelContentL.text = AppDelegate.shared().tempTransferMaxWarningStr
        }
        
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        labelContentL.textAlignment = .center
        labelContentL.center = CGPoint.init(x: barView.center.x, y: labelContentL.center.y)
        centerView.addSubview(labelContentL)
        
        startY += labelContentL.frame.size.height + 35
        /*
        //數字
        let numL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 54))
        numL.textAlignment = .center
        numL.textColor = .black
        numL.font = UIFont.boldSystemFont(ofSize: 50)
        numL.text = String.stringToOnlyIntString(Number: AppDelegate.shared().tempTransferMaxAmount)
        centerView.addSubview(numL)
        
        startY += 70
        
        let labelContent2L = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContent2L.textColor = .black
        labelContent2L.font = UIFont.systemFont(ofSize: 14)
        labelContent2L.text = content2
        labelContent2L.numberOfLines = 0
        labelContent2L.sizeToFit()
        labelContent2L.textAlignment = .center
        labelContent2L.center = CGPoint.init(x: barView.center.x, y: labelContent2L.center.y)
        centerView.addSubview(labelContent2L)
        
        //按鈕
        startY += labelContent2L.frame.size.height + 35
        */
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-20)
        centerView.layer.cornerRadius = 15
        centerView.clipsToBounds = true
        
        let nextBtn = UIButton.init(frame: self.bounds)
        nextBtn.backgroundColor = .clear
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.setTitle("", for: .normal)
        self.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
    }
    
    public func initTwoActionAlert(Title title:String, Content content:String, NextBtn1Str btnStr1:String, NextBtn2Str btnStr2:String, CancelBtn1Str btnStr3:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = 50
        let centerY:CGFloat = self.frame.size.height/2
        
        let closeBtn = UIButton.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width, height: self.frame.size.height))
        self.addSubview(closeBtn)
        closeBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        //背景框
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 20
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.systemFont(ofSize: 25)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        labelTitleL.center = CGPoint(x: barView.center.x, y: labelTitleL.center.y)
        
        //內容
        startY += 6
        let labelContentL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        labelContentL.text = content
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        centerView.addSubview(labelContentL)
        
        //按鈕
        startY += labelContentL.frame.size.height + 35
        let nextBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        nextBtn.setTitle(btnStr1, for: .normal)
        nextBtn.titleLabel?.adjustsFontSizeToFitWidth = true
        nextBtn.backgroundColor = .clear
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        nextBtn.layer.borderWidth = 1
        nextBtn.setTitleColor(Color_Main_Red, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        startY += nextBtn.frame.size.height + 10
        
        //按鈕2
        let nextBtn2 = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        nextBtn2.setTitle(btnStr2, for: .normal)
        nextBtn2.backgroundColor = Color_Main_Red
        nextBtn2.setTitleColor(.white, for: .normal)
        nextBtn2.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn2)
        nextBtn2.addTarget(self, action: #selector(nextActionSecond), for: .touchUpInside)
        
        startY += nextBtn2.frame.size.height + 10
        
        let cancelBtn = UIButton.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: 35))
        cancelBtn.setTitle(btnStr3, for: .normal)
        cancelBtn.layer.borderColor = Color_Main_Red.cgColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.setTitleColor(Color_Main_Red, for: .normal)
        cancelBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(cancelBtn)
        cancelBtn.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        
        startY += cancelBtn.frame.size.height + 20
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-50)
        centerView.layer.cornerRadius = 15
        centerView.clipsToBounds = true
        
    }
    
    //內容可捲動、只有一顆確認鈕的視窗：內容過長時限制高度並可上下捲動（用於後台給的長段文字，如防詐提醒）
    //不能點背景關閉，只能按確認
    //防詐提醒視窗，版型照設計稿 docs/design/compliance-202610/fraud-govn.png：
    //視窗寬約螢幕 80%、色帶下方有警告圖示、內文置中、深藍窄版膠囊按鈕置中
    public func initScrollContentAlert(Title title:String, Content content:String, NextBtn1Str btnStr1:String) {
        self.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.8)
        let divX:CGFloat = (self.frame.size.width * 0.1).rounded()
        let centerY:CGFloat = self.frame.size.height/2
        
        //此視窗不允許點背景關閉，只能按按鈕
        let centerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: 0))
        self.addSubview(centerView)
        centerView.backgroundColor = .white
        let width = centerView.frame.size.width
        var startY:CGFloat = 0
        
        let divX2:CGFloat = 24
        let labelTitleL = UILabel.init(frame: CGRect.init(x:divX2 , y: startY+12, width: width-2*divX2, height: 0))
        labelTitleL.textAlignment = .center
        labelTitleL.textColor = .white
        labelTitleL.font = UIFont.boldSystemFont(ofSize: 20)
        labelTitleL.text = title
        labelTitleL.numberOfLines = 0
        labelTitleL.sizeToFit()
        labelTitleL.frame.size.width = width-2*divX2
        
        startY += 24 + labelTitleL.frame.size.height
        
        //標題列
        let barView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: width, height: startY))
        barView.addSubview(labelTitleL)
        barView.backgroundColor = Color_Main_Red
        centerView.addSubview(barView)
        
        //警告圖示（fraud_alert_icon，三款共用同一張，換檔不需改程式）
        startY += 12
        let iconSize = CGSize(width: 52, height: 54)
        let iconV = UIImageView.init(frame: CGRect.init(x: (width-iconSize.width)/2, y: startY, width: iconSize.width, height: iconSize.height))
        iconV.image = UIImage(named: "fraud_alert_icon")
        iconV.contentMode = .scaleAspectFit
        centerView.addSubview(iconV)
        startY += iconSize.height
        
        //內容（置中、可捲動）
        startY += 10
        let labelContentL = UILabel.init(frame: CGRect.init(x: 0, y: 0, width: width-2*divX2, height: 0))
        labelContentL.textColor = .black
        labelContentL.textAlignment = .center
        labelContentL.font = UIFont.systemFont(ofSize: 14)
        labelContentL.text = content
        labelContentL.numberOfLines = 0
        labelContentL.sizeToFit()
        labelContentL.frame.size.width = width-2*divX2
        
        let maxContentHeight = self.frame.size.height * 0.5
        let contentHeight = min(labelContentL.frame.size.height, maxContentHeight)
        let contentScrollV = UIScrollView.init(frame: CGRect.init(x: divX2, y: startY, width: width-2*divX2, height: contentHeight))
        contentScrollV.addSubview(labelContentL)
        contentScrollV.contentSize = labelContentL.frame.size
        contentScrollV.showsVerticalScrollIndicator = true
        centerView.addSubview(contentScrollV)
        if labelContentL.frame.size.height > maxContentHeight {
            contentScrollV.flashScrollIndicators()
        }
        
        //按鈕：深藍、寬約視窗 55%、置中
        startY += contentHeight + 22
        let btnWidth = (width * 0.55).rounded()
        let nextBtn = UIButton.init(frame: CGRect.init(x: (width-btnWidth)/2, y: startY, width: btnWidth, height: 32))
        nextBtn.setTitle(btnStr1, for: .normal)
        nextBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        nextBtn.backgroundColor = Color_Fraud_Alert_Btn
        nextBtn.setTitleColor(.white, for: .normal)
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        centerView.addSubview(nextBtn)
        nextBtn.addTarget(self, action: #selector(nextAction), for: .touchUpInside)
        
        startY += nextBtn.frame.size.height + 16
        
        //最後位置調整
        centerView.frame = CGRect.init(x: 0, y: 0, width: self.frame.size.width-2*divX, height: startY)
        centerView.center = CGPoint(x: self.frame.size.width/2, y: centerY-20)
        centerView.layer.cornerRadius = 12
        centerView.clipsToBounds = true
    }
    
    @objc func nextAction() {
        customDelegate?.customAlertnextAction(Ref: self)
    }
    
    @objc func nextActionSecond() {
        customDelegate?.customAlertnextActionSecond(Ref: self)
    }
    
    
    @objc func cancelAction() {
        self.removeFromSuperview()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

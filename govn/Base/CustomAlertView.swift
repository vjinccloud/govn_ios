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

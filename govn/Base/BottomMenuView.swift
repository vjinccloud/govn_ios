//
//  BottomMenuView.swift
//  indogo
//
//  Created by mac on 2020/8/12.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class BottomMenuView: UIView {
    
    let spaceWidth:CGFloat = 15
    var buttonWidth:CGFloat = 0
    let totalButtons:Int = 5
    var btnNormalAry:[String] = []
    var btnChosedAry:[String] = []
    var btnFuncType:[BottomMenuType] = []
    var btnImgVAry:[UIImageView] = []
    var realHeightWithoutSafetyBottom:CGFloat = 0
    var numL:UILabel!
    var topLine:UIView!
    
    func initFirst(RealHeight height:CGFloat) {
        //扣除底部安全距離的高度
        realHeightWithoutSafetyBottom = height
        
        self.backgroundColor = UtilityTool().hexStringToUIColor(hex: "#333333")
        buttonWidth = (self.frame.size.width-2*spaceWidth)/CGFloat(totalButtons)
        btnNormalAry.append("w_sand")
        btnChosedAry.append("r_sand")
        btnFuncType.append(.transaction)
        
        btnNormalAry.append("w_record")
        btnChosedAry.append("r_record")
        btnFuncType.append(.transState)
        
        btnNormalAry.append("w_share")
        btnChosedAry.append("r_share")
        btnFuncType.append(.sharing)
        
        btnNormalAry.append("w_notice")
        btnChosedAry.append("r_notice")
        btnFuncType.append(.notice)
        
        btnNormalAry.append("w_mamber")
        btnChosedAry.append("r_mamber")
        btnFuncType.append(.profile)
        
        topLine = UIView.init(frame: CGRect.init(x: 0, y: 0, width: buttonWidth, height: 2))
        topLine.backgroundColor = UIColor.init(red: 26/255, green: 143/255, blue: 246/255, alpha: 1)
        self.addSubview(topLine)
        
        for i in 0..<totalButtons {
            let img = UIImageView.init(frame: CGRect.init(x: 0, y: 0, width: 32, height: 32))
            img.image = UIImage.init(named: btnNormalAry[i])
            img.center = CGPoint.init(x: spaceWidth + (CGFloat(i)+0.5)*buttonWidth, y: realHeightWithoutSafetyBottom/2)
            self.addSubview(img)
            
            let btn = UIButton.init(frame: CGRect.init(x: spaceWidth + CGFloat(i)*buttonWidth, y: 0, width: buttonWidth, height: realHeightWithoutSafetyBottom))
            btn.tag = i
            Dlog(btn.frame)
            btn.addTarget(self, action: #selector(changeMenuAction(_:)), for: .touchUpInside)
            self.addSubview(btn)
            btnImgVAry.append(img)
            
            //通知另外加數字
            if i == 3 {
                numL = UILabel.init(frame: CGRect.init(x: btn.frame.origin.x + btn.frame.size.width/2 + 10, y: 2, width: 20, height: 20))
                self.addSubview(numL)
                numL.textColor = .black
                numL.layer.backgroundColor = UIColor.lightGray.cgColor
                numL.layer.cornerRadius = numL.frame.size.height/2
                numL.font = UIFont.boldSystemFont(ofSize: 15)
                numL.textAlignment = .center
                numL.adjustsFontSizeToFitWidth = true
                numL.isHidden = true
            }
        }
        
        setReadNum()
    }
    
    func setReadNum() {
        if AppDelegate.shared().noticeNotReadNum == 0 {
            numL.isHidden = true
        } else {
            var str = ""
            if AppDelegate.shared().noticeNotReadNum > 10 {
                str = "+9"
            } else {
                str = "\(AppDelegate.shared().noticeNotReadNum)"
            }
            
            numL.text = str
            numL.isHidden = false
        }
    }
    
    func setFuncNow(MenuType type:BottomMenuType) {
        AppDelegate.shared().nowBottomMenuType = type
        paintMenu()
        
        if type == .notice {
            AppDelegate.shared().changeRootOfFunc(Type: .notice)
        } else if type == .transState {
            AppDelegate.shared().changeRootOfFunc(Type: .transState)
        } else if type == .transaction {
            AppDelegate.shared().changeRootOfFunc(Type: .transaction)
        } else if type == .sharing {
            AppDelegate.shared().changeRootOfFunc(Type: .sharing)
        } else if type == .profile {
            AppDelegate.shared().changeRootOfFunc(Type: .member)
        }
    }
    
    func paintMenu() {
        for i in 0..<totalButtons {
            let img = btnImgVAry[i]
            if btnFuncType[i] == AppDelegate.shared().nowBottomMenuType {
                img.image = UIImage.init(named: btnChosedAry[i])
                
                if i==0 {
                    topLine.frame = CGRect.init(x: 0, y: 0, width: buttonWidth+spaceWidth, height: 2)
                } else if i==(totalButtons-1) {
                    topLine.frame = CGRect.init(x: CGFloat(i)*buttonWidth+spaceWidth, y: 0, width: buttonWidth+spaceWidth, height: 2)
                } else {
                    topLine.frame = CGRect.init(x: CGFloat(i)*buttonWidth+spaceWidth, y: 0, width: buttonWidth, height: 2)
                }
                
            } else {
                img.image = UIImage.init(named: btnNormalAry[i])
            }
        }
    }
    
    @objc func changeMenuAction(_ sender: Any) {
        
        let tag = (sender as AnyObject).tag
        
        let tempFunc = btnFuncType[tag!]
        setFuncNow(MenuType:tempFunc)
        /*
        if tempFunc == AppDelegate.shared().nowBottomMenuType {
            //不做事情
        } else {
            setFuncNow(MenuType:tempFunc)
        }*/
    }

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

}

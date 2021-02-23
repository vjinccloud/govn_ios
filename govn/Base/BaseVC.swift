//
//  BaseVC.swift
//  Mirmar
//
//  Created by askAir on 2018/11/12.
//  Copyright © 2018年 Mirmar. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {

    var allScreenButton: UIButton!
    var oriTitle:String!
    var bottomHeight = 80
    var topHeight:CGFloat = 60
    
    // MARK: - Bottom
    func initBottom () {
        
    }
    
    // MARK: - Utility
    //設定原始Title
    func setOriTitle (_ nowTitle:String) {
        oriTitle = nowTitle
    }
    
    func setBackButton () {
        //chevron_sys_left
        //let leftItem = UIBarButtonItem(image: UIImage(named: "chevron_sys_left.png"), style: .plain, target: self, action: #selector(backToRoot))
        //self.navigationItem.leftBarButtonItem = leftItem
    }
    
    // MARK: - View-Life
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = oriTitle
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

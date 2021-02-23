//
//  ImageSliderVC.swift
//  Mirmar
//
//  Created by askAir on 2018/11/13.
//  Copyright © 2018年 Mirmar. All rights reserved.
//

import UIKit
import ImageSlideshow
import Kingfisher

class ImageSliderVC: BaseVC {
    
    @IBOutlet weak var bgView: UIView!
    var imgaeSourceArray:NSMutableArray = NSMutableArray.init()
    var backIdx = 0
    var loadOnce = false
    
    //設置資訊，給url的array
    func setupIno (Source array:NSArray, Index idx:Int) {
        backIdx = idx
        self.view.backgroundColor = UIColor.black
        for i in 0..<array.count {
            let str = array.object(at: i) as! String
            imgaeSourceArray.add(KingfisherSource(urlString: str)!)
        }
    }
    
    //畫面出來後才初始化這裡
    func initImageSlider () {
        //請參考
        //https://cocoapods.org/pods/ImageSlideshow
        let slideshow = ImageSlideshow.init(frame: bgView.frame)
        slideshow.activityIndicator = DefaultActivityIndicator(style: .white, color: nil)
        slideshow.backgroundColor = UIColor.black
        slideshow.setImageInputs(imgaeSourceArray as! [InputSource])
        slideshow.zoomEnabled = true
        self.view .addSubview(slideshow)
        slideshow.setCurrentPage(backIdx, animated: false)
    }

    //MARK: - View Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            return
        }
        loadOnce = true
        initImageSlider()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

//
//  NoticeMainVC.swift
//  indogo
//
//  Created by mac on 2020/8/12.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit
import Alamofire
import Kingfisher
import KingfisherWebP
import SwiftyJSON

class NoticeMainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var showPhotoView: UIView!
    @IBOutlet weak var myTableView: UITableView!
    @IBOutlet weak var backL: UILabel!
    var loadOnce = false
    var nowPage = 0
    var stopLoadMore = false
    var isLoading = false
    let pageLimit = 10
    
    //MARK: - API
    func getNotice() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "page":nowPage, "limit":pageLimit]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        if nowPage == 1 {
            AppDelegate.shared().noteListObjs = []
        }
        
        let oldCount = AppDelegate.shared().noteListObjs.count
        
        AppDelegate.shared().addLoadingView()
        isLoading = true
        
        let todoEndpoint: String = API_NoticeRecordList;
        AppDelegate.shared().alamofireManagerWithTimeout.request(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                self.isLoading = false
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("todoEndpoint = \(todoEndpoint),responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    self.nowPage += 1
                    let newCount = AppDelegate.shared().noteListObjs.count
                    var count = 0
                    for i in 0..<AppDelegate.shared().noteListObjs.count {
                        let data = AppDelegate.shared().noteListObjs[i]
                        if data.readable == "0" {
                            count += 1
                        }
                    }
                    AppDelegate.shared().noticeNotReadNum = count
                    AppDelegate.shared().setBottomNotReadNum()
                    
                    Dlog("allpage = \((newCount - oldCount))")
                    if (newCount - oldCount) < self.pageLimit {
                        self.stopLoadMore = true
                    }
                    
                    self.myTableView.delegate = self
                    self.myTableView.dataSource = self
                    self.myTableView.reloadData()
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    func readNotice(Idx idx:String) {
        let ary:[String] = [idx]
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken, "notification_record_id":ary]
        let headers: HTTPHeaders = [:]
        
        Dlog("parameters=\(parameters)")
        
        let todoEndpoint: String = API_NotificationRead;
        AppDelegate.shared().alamofireManagerWithTimeout.request(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
        }
    }
    
    func goTransferList() {
        AppDelegate.shared().changeRootOfFunc(Type: .transState)
    }
    
    func getPointHistory() {
        let parameters:Parameters = ["token":AppDelegate.shared().sessionToken]
        let headers: HTTPHeaders = [:]
        
        AppDelegate.shared().addLoadingView()
        
        let todoEndpoint: String = API_PointHistoryList;
        AppDelegate.shared().alamofireManagerWithTimeout.request(todoEndpoint,method: .post,parameters: parameters,encoding: URLEncoding.default, headers:headers)
            .responseString(encoding: String.Encoding.utf8)  { response in
                AppDelegate.shared().removeLoadingView()
                
                guard response.result.error == nil else {
                    // got an error in getting the data, need to handle it
                    print("error calling on \(todoEndpoint)")
                    print(response.result.error!)
                    AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
                    return
                }
                
                let responseStr = String.init(data: response.data!, encoding: String.Encoding.utf8)
                Dlog("todoEndpoint = \(todoEndpoint),responseStr = \(responseStr ?? "")")
                
                let result = APIHandle().getResponseState(ResponseStr: responseStr!, APIStr: todoEndpoint, SubStr: "")
                
                if result == ResponseState.ok {
                    AppDelegate.shared().pointRootShowHistory = true
                    AppDelegate.shared().changeRootOfFunc(Type: .sharing)
                } else if result == ResponseState.failed {
                    AppDelegate.shared().showAlertWithWindow(self, Message: AppDelegate.shared().apiBackContentStr)
                }
        }
    }
    
    //MARK: - TableView Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate.shared().noteListObjs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let data = AppDelegate.shared().noteListObjs[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "noticeCell", for: indexPath) as! NoticeTableViewCell
        
        if data.readable == "0" {
            cell.titleL.textColor = Color_Main_Red
        } else {
            cell.titleL.textColor = .lightGray
        }
        
        cell.titleL.text = data.title
        /*
        if data.tpyeStr.hasPrefix("點數異動") {
            cell.titleL.text = NSLocalizedString("Notice Type 0", comment: "")
        } else if data.tpyeStr.hasPrefix("訂單變更") {
            cell.titleL.text = NSLocalizedString("Notice Type 1", comment: "")
        } else if data.tpyeStr.hasPrefix("公告") {
            //--should-- 只有這裡秀server給的？
            cell.titleL.text = data.title
        } else if data.tpyeStr.contains("用戶資料") {
            cell.titleL.text = NSLocalizedString("Notice Type 3", comment: "")
        }*/
        cell.contentL.text = data.content
        cell.timeL.text = getFormatTime(DateStr: data.createTime)
        cell.index = indexPath.row
        cell.parentVC = self
        cell.selectionStyle = .none
        return cell
    }
    
    func getFormatTime(DateStr str:String) -> String {
        var ansStr = ""
        let ary = str.components(separatedBy: " ")
        if ary.count != 2 {
            return ""
        }
        
        //1.時間倒過來顯示
        let date = UtilityTool().transferIndogoDate(Date: ary[0])
        ansStr = date + " | " + ary[1]
        
        return ansStr
    }
    
    func nextAction(Index index:Int) {
        let data = AppDelegate.shared().noteListObjs[index]
        //讀取送API
        if data.readable == "0" {
            readNotice(Idx: data.idStr)
        }
        
        if data.tpyeStr.hasPrefix("點數異動") {
            getPointHistory()
        } else if data.tpyeStr.hasPrefix("訂單變更") {
            goTransferList()
        } else if data.tpyeStr.hasPrefix("公告") {
            if data.photo.count > 5 {
                let imgurl = ServerURL + data.photo
                let urlhaed = URL(string: imgurl.addingPercentEncoding( withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!)
                let imgV = UIImageView.init(frame: CGRect.init(x: 30, y: 30, width: showPhotoView.frame.size.width-60, height: showPhotoView.frame.size.height-60))
                imgV.contentMode = .scaleAspectFit
                showPhotoView.addSubview(imgV)
                showPhotoView.backgroundColor = UIColor.init(red: 0, green: 0, blue: 0, alpha: 0.7)
                imgV.kf.setImage(with: urlhaed)
                showPhotoView.isHidden = false
                let btn = UIButton.init(frame: CGRect.init(x: imgV.frame.origin.x+imgV.frame.size.width-20, y: imgV.frame.origin.y-20, width: 40, height: 40))
                btn.setImage(UIImage.init(named: "close.png"), for: .normal)
                showPhotoView.addSubview(btn)
                btn.addTarget(self, action: #selector(closePhotoView), for: .touchUpInside)
                showPhotoView.isHidden = false
            }
        } else if data.tpyeStr.contains("用戶資料") {
            let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: "MemberEditVC") as? MemberEditVC
            self.navigationController?.pushViewController(nextVC!, animated: true)
        }
    }
    
    @objc func closePhotoView() {
        showPhotoView.isHidden = true
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.section == tableView.numberOfSections - 1 &&
            indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1 {
            // Notify interested parties that end has been reached
            Dlog("willDisplay, \(stopLoadMore), \(isLoading)")
            if !stopLoadMore, !isLoading {
                getNotice()
            }
        }
    }
    
    //MARK: - Button-Action
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        backL.text = NSLocalizedString("Notice Main Title", comment: "")
        showPhotoView.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if loadOnce {
            AppDelegate.shared().showTopButton()
            return
        }
        
        loadOnce = true
        
        nowPage = 1
        getNotice()
        
        //頂部兩個按鈕
        AppDelegate.shared().topMargin = self.view.safeAreaInsets.top
        AppDelegate.shared().addTopButton()
        
        AppDelegate.shared().nowBottomMenuType = .notice
        AppDelegate.shared().bottomMenu.paintMenu()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

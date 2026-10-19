//
//  TransferPurposeEmbededVC.swift
//  govn
//
//  移植自 GoPadala（compliance-202610 匯款目的）
//  GoPadala 用 loadFrom + 各 parentVC 回呼；GoVN 進確認頁的入口有五處，改成 closure 回呼，
//  統一由 UIViewController.showTransferPurposeThenConfirm 呼叫。
//  Copyright © 2022 DIM. All rights reserved.
//

import UIKit

class TransferPurposeEmbededVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var purposeBgV: UIView!
    
    @IBOutlet weak var nameBgV: UIView!
    @IBOutlet weak var resultL: UILabel!
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var purposeListTableView: UITableView!
    @IBOutlet weak var dimBgV: UIView!
    var chosePurposeIdx = -1
    
    //選好匯款目的、按確認後要做的事（進交易確認頁）
    var onConfirm: (() -> Void)?
    
    //MARK: - Tableview Delegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return AppDelegate.shared().purposeObj.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let cellData = AppDelegate.shared().purposeObj[indexPath.row]
        cell.textLabel?.text = cellData.name
        cell.textLabel?.numberOfLines = 0
        if indexPath.row == chosePurposeIdx {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = .clear
        }
        
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosePurposeIdx = indexPath.row
        let cellData = AppDelegate.shared().purposeObj[indexPath.row]
        resultL.text = cellData.name
        checkBtnState()
        tableView.reloadData()
    }
    
    func checkBtnState() {
        if chosePurposeIdx != -1 {
            nextBtn.isEnabled = true
            nextBtn.backgroundColor = Color_Main_Red
            nextBtn.setTitleColor(.white, for: .normal)
        } else {
            nextBtn.isEnabled = false
            nextBtn.backgroundColor = .clear
            nextBtn.setTitleColor(Color_Main_Red, for: .normal)
        }
    }
    
    //MARK: - View-Life
    override func viewDidLoad() {
        super.viewDidLoad()

        nameL.text = NSLocalizedString("Purpose Select Title", comment: "")
        nameL.adjustsFontSizeToFitWidth = true
        resultL.text = NSLocalizedString("Purpose Select default word", comment: "")
        purposeListTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        purposeListTableView.separatorStyle = .none
        purposeListTableView.delegate = self
        purposeListTableView.dataSource = self
        
        purposeBgV.layer.cornerRadius = purposeBgV.frame.size.height/2
        nextBtn.layer.cornerRadius = nextBtn.frame.size.height/2
        nextBtn.setTitle(NSLocalizedString("ok", comment: ""), for: .normal)
        nextBtn.layer.borderWidth = 0.5
        nextBtn.layer.borderColor = Color_Main_Red.cgColor
        checkBtnState()
        //GoPadala 這裡是 IndoGo 漸層，GoVN 沒有該擴充，用主色
        nameBgV.backgroundColor = Color_Main_Red
        
        //GoPadala 版沒有關閉方式；GoVN 加上點背景可關閉（不選就不進確認頁）
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(closeAction))
        tap.delegate = self
        dimBgV.addGestureRecognizer(tap)
        
        Dlog("purpose count = \(AppDelegate.shared().purposeObj.count)")
    }
    
    @IBAction func nextAction(_ sender: Any) {
        if chosePurposeIdx < 0 || chosePurposeIdx >= AppDelegate.shared().purposeObj.count {
            return
        }
        AppDelegate.shared().transactionObj.purposes_id = AppDelegate.shared().purposeObj[chosePurposeIdx].idx
        let next = onConfirm
        removeSelf()
        next?()
    }
    
    //只有點在背景本身才關閉，點到中間的選單（清單、按鈕）不算
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == dimBgV
    }
    
    @objc func closeAction() {
        removeSelf()
    }
    
    func removeSelf() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

extension UIViewController {
    //選完收款人後：先選匯款目的，再進交易確認頁（compliance-202610）
    //清單還沒抓到時現場抓，抓不到就顯示連線錯誤，不放行
    func showTransferPurposeThenConfirm(TopBarSelectIdx topBarIdx:Int? = nil) {
        //避免連點疊出兩層
        if children.contains(where: { $0 is TransferPurposeEmbededVC }) {
            return
        }
        
        let showPurpose = { [weak self] in
            guard let self = self else { return }
            let controller = TransferPurposeEmbededVC(nibName: "TransferPurposeEmbededVC", bundle: nil)
            controller.onConfirm = { [weak self] in
                self?.pushTransactionInfoConfirm(TopBarSelectIdx: topBarIdx)
            }
            self.addChild(controller)
            self.view.addSubview(controller.view)
            controller.view.frame = self.view.bounds
            controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            controller.didMove(toParent: self)
        }
        
        if AppDelegate.shared().hasPurpose, AppDelegate.shared().purposeObj.count > 0 {
            showPurpose()
            return
        }
        
        AppDelegate.shared().addLoadingView()
        AppDelegate.shared().getPurposeList { [weak self] success in
            AppDelegate.shared().removeLoadingView()
            guard let self = self else { return }
            if success, AppDelegate.shared().purposeObj.count > 0 {
                showPurpose()
            } else {
                AppDelegate.shared().showAlertWithWindow(self, Message: NSLocalizedString("API Timeout", comment: ""))
            }
        }
    }
    
    func pushTransactionInfoConfirm(TopBarSelectIdx topBarIdx:Int? = nil) {
        var storyboardId = "TransactionInfoConfirmVC"
        if AppDelegate.shared().deviceSmall {
            storyboardId = "TransactionInfoConfirmVCSmall"
        }
        let nextVC = UIStoryboard(name: "Member", bundle: nil).instantiateViewController(withIdentifier: storyboardId) as? TransactionInfoConfirmVC
        if let idx = topBarIdx {
            nextVC!.topBarSelectIdx = idx
        }
        self.navigationController?.pushViewController(nextVC!, animated: true)
    }
}

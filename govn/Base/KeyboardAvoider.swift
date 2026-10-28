//
//  KeyboardAvoider.swift
//  govn
//
//  需求 7：標準鍵盤避讓，取代「聚焦就把欄位捲到頂」的舊寫法。
//  - 鍵盤（含用 inputView 的日期選擇器、picker）出現時，只把它蓋住捲動區的高度加進 contentInset / scrollIndicatorInsets
//  - 只有目前編輯的欄位（整列容器）會被鍵盤蓋住時，才用 scrollRectToVisible 捲最小幅度；沒被蓋住完全不捲
//  - 鍵盤收起時只把 inset 歸零，不捲回頂端
//  用法：viewDidLoad 建一個實例存在 VC 屬性；textFieldDidBeginEditing 呼叫 fieldDidBeginEditing(_:)。
//

import UIKit

final class KeyboardAvoider: NSObject {
    
    private weak var scrollView: UIScrollView?
    private weak var hostView: UIView?
    ///傳入正在編輯的欄位，回傳要保持可見的整列容器（沒有對應就回傳欄位本身）
    private let containerFor: (UIView) -> UIView
    ///欄位下緣與鍵盤頂端至少留的距離
    var gap: CGFloat = 12
    ///鍵盤頂端在 hostView 座標的 y；nil 表示鍵盤沒顯示
    private(set) var keyboardTopInHost: CGFloat? = nil
    
    /// - Parameters:
    ///   - scrollView: 要避讓的捲動區
    ///   - hostView: 通常是 VC 的 view，用來換算鍵盤座標
    ///   - containerFor: 欄位 → 整列容器的對應；預設就是欄位本身
    init(scrollView: UIScrollView, hostView: UIView, containerFor: @escaping (UIView) -> UIView = { $0 }) {
        self.scrollView = scrollView
        self.hostView = hostView
        self.containerFor = containerFor
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    ///在 textFieldDidBeginEditing 呼叫。鍵盤已經在畫面上時（例如按 Next 換欄位，高度沒變系統不一定再發 keyboardWillShow）
    ///補一次「被蓋住才捲」的檢查；鍵盤還沒出現時由 keyboardWillShow 處理。
    func fieldDidBeginEditing(_ field: UIView) {
        guard let keyboardTop = keyboardTopInHost else { return }
        scrollIntoViewIfCovered(field, keyboardTop: keyboardTop, duration: 0.25)
    }
    
    //MARK: - Notification
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let scrollView = scrollView, let hostView = hostView,
              let info = notification.userInfo,
              let frameValue = info[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        let duration = (info[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        //鍵盤 frame 是螢幕座標，換成 hostView 座標；高度用通知的值，inputView 高度不同也適用
        let keyboardFrame = hostView.convert(frameValue.cgRectValue, from: nil)
        let scrollFrame = scrollView.convert(scrollView.bounds, to: hostView)
        //捲動區底部已由 safe area 自動加了 inset（adjustedContentInset），只補鍵盤多蓋住的部分
        let overlap = max(0, scrollFrame.maxY - keyboardFrame.minY - scrollView.safeAreaInsets.bottom)
        keyboardTopInHost = keyboardFrame.minY
        
        scrollView.contentInset.bottom = overlap
        scrollView.verticalScrollIndicatorInsets.bottom = overlap
        
        if let field = KeyboardAvoider.firstResponder(in: scrollView) {
            scrollIntoViewIfCovered(field, keyboardTop: keyboardFrame.minY, duration: duration)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let scrollView = scrollView else { return }
        let duration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0.25
        keyboardTopInHost = nil
        //只把 inset 歸零，不捲回頂端；offset 超出範圍時交給 UIScrollView 自己夾回
        UIView.animate(withDuration: duration) {
            scrollView.contentInset.bottom = 0
            scrollView.verticalScrollIndicatorInsets.bottom = 0
        }
    }
    
    //MARK: - Scroll
    ///只有欄位（整列）會被鍵盤蓋住時才用 scrollRectToVisible 捲最小幅度；沒被蓋住完全不捲
    private func scrollIntoViewIfCovered(_ field: UIView, keyboardTop: CGFloat, duration: TimeInterval) {
        guard let scrollView = scrollView, let hostView = hostView else { return }
        let container = containerFor(field)
        let rectInHost = container.convert(container.bounds, to: hostView)
        let scrollFrame = scrollView.convert(scrollView.bounds, to: hostView)
        let visibleBottom = min(scrollFrame.maxY, keyboardTop)
        //欄位下緣 + 間距 仍在鍵盤上方就不動；欄位上緣被捲動區頂端遮住也不處理（使用者自己捲上去的）
        guard rectInHost.maxY + gap > visibleBottom else { return }
        
        var rectInScroll = container.convert(container.bounds, to: scrollView)
        rectInScroll.size.height += gap
        scrollView.layoutIfNeeded()
        UIView.animate(withDuration: duration) {
            scrollView.scrollRectToVisible(rectInScroll, animated: false)
        }
    }
    
    ///往下找目前是第一回應者的子視圖
    private static func firstResponder(in view: UIView) -> UIView? {
        if view.isFirstResponder { return view }
        for sub in view.subviews {
            if let found = firstResponder(in: sub) { return found }
        }
        return nil
    }
}

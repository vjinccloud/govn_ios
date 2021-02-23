//
//  TransferMemberChoseTableViewCell.swift
//  indogo
//
//  Created by mac on 2020/8/27.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class TransferMemberChoseTableViewCell: UITableViewCell {

    @IBOutlet weak var styleImgV: UIImageView!
    @IBOutlet weak var phoneL: UILabel!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var choseBtn: UIButton!
    
    var chosed = false
    var index:Int = 0
    var parentVC:TransferPointVC!
    
    @IBAction func choseAction(_ sender: Any) {
        if chosed {
            chosed = false
        } else {
            chosed = true
        }
        setUpImgIcon()
        parentVC.callFromCell(Index: index, Result: chosed)
    }
    
    func setUpImgIcon() {
        if chosed {
            choseBtn.setImage(UIImage.init(named: "big_select.png"), for: .normal)
        } else {
            choseBtn.setImage(UIImage.init(named: "big_unselect.png"), for: .normal)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

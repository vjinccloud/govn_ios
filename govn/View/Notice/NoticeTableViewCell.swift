//
//  NoticeTableViewCell.swift
//  indogo
//
//  Created by mac on 2020/8/17.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class NoticeTableViewCell: UITableViewCell {

    @IBOutlet weak var titleL: UILabel!
    @IBOutlet weak var contentL: UILabel!
    @IBOutlet weak var timeL: UILabel!
    var index:Int!
    var parentVC:NoticeMainVC!
    
    @IBAction func pressAction(_ sender: Any) {
        parentVC.nextAction(Index: index)
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

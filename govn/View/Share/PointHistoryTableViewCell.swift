//
//  PointHistoryTableViewCell.swift
//  indogo
//
//  Created by mac on 2020/8/21.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class PointHistoryTableViewCell: UITableViewCell {

    @IBOutlet weak var cell1V: UIView!
    @IBOutlet weak var cell2V: UIView!
    @IBOutlet weak var cell3V: UIView!
    @IBOutlet weak var cell4V: UIView!
    
    @IBOutlet weak var cell1L: UILabel!
    @IBOutlet weak var cell2L: UILabel!
    @IBOutlet weak var cell3L: UILabel!
    @IBOutlet weak var cell4L: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cell1L.adjustsFontSizeToFitWidth = true
        cell3L.adjustsFontSizeToFitWidth = true
        cell4L.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  RecipientTableViewCell.swift
//  indogo
//
//  Created by mac on 2020/8/29.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class RecipientTableViewCell: UITableViewCell {

    @IBOutlet weak var logoImgV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var bankL: UILabel!
    @IBOutlet weak var checkImgV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameL.adjustsFontSizeToFitWidth = true
        bankL.adjustsFontSizeToFitWidth = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

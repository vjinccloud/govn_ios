//
//  BankListTableViewCell.swift
//  indogo
//
//  Created by mac on 2020/9/13.
//  Copyright © 2020 DIM. All rights reserved.
//

import UIKit

class BankListTableViewCell: UITableViewCell {
    @IBOutlet weak var bankIconImgV: UIImageView!
    @IBOutlet weak var bankL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        bankL.adjustsFontSizeToFitWidth = true
        self.backgroundColor = .white
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

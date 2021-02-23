//
//  SelectRecitientNameTableViewCell.swift
//  govn
//
//  Created by mac on 2021/1/2.
//  Copyright © 2021 DIM. All rights reserved.
//

import UIKit

class SelectRecitientNameTableViewCell: UITableViewCell {
    
    @IBOutlet weak var choseImgV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var idL: UILabel!
    @IBOutlet weak var phoneL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

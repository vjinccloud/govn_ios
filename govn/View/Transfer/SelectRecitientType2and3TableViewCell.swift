//
//  SelectRecitientType2and3TableViewCell.swift
//
//  Created by mac on 2021/1/3.
//  Copyright © 2021 DIM. All rights reserved.
//

import UIKit

class SelectRecitientType2and3TableViewCell: UITableViewCell {

    @IBOutlet weak var choseImgV: UIImageView!
    @IBOutlet weak var nameL: UILabel!
    @IBOutlet weak var idL: UILabel!
    @IBOutlet weak var phoneL: UILabel!
    @IBOutlet weak var adrL: UILabel!
    
    @IBOutlet weak var nameTL: UILabel!
    @IBOutlet weak var idTL: UILabel!
    @IBOutlet weak var phoneTL: UILabel!
    @IBOutlet weak var adrTL: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  RateCell.swift
//  DovizTakip
//
//  Created by Sezer on 6.11.2022.
//

import UIKit

class RateCell: UITableViewCell {


    
    @IBOutlet weak var lbl_rate: UILabel!
    @IBOutlet weak var lbl_currencyName: UILabel!
    @IBOutlet weak var img_flag: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}

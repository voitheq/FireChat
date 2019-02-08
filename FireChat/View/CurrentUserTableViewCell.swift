//
//  CustomTableViewCell.swift
//  FireChat
//
//  Created by Wojciech Karaś on 06/02/2019.
//  Copyright © 2019 Wojciech Karaś. All rights reserved.
//

import UIKit

class CurrentUserTableViewCell: UITableViewCell {

    @IBOutlet weak var background: UIView!
    @IBOutlet weak var messageTextLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        background.layer.cornerRadius = 8
        background.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

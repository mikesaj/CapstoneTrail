//
//  CustomTableViewCell.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-20.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class CustomTableViewCell: UITableViewCell {
    
    @IBOutlet weak var friendName: UILabel!
    //@IBOutlet weak var friendEmail: UILabel!
    @IBOutlet weak var inviteButton: UIButton!
    


    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  GroupListViewCell.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-25.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class GroupListViewCell: UITableViewCell {

    
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var groupLocation: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

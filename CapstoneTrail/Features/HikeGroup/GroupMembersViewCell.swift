//
//  GroupMembersViewCell.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-03-31.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class GroupMembersViewCell: UITableViewCell {

    @IBOutlet weak var memberName: UILabel!
    @IBOutlet weak var memberLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

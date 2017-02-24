//
//   Configure the view for the selected state     }  } ScheduleViewCell.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-02-21.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

class ScheduleViewCell: UITableViewCell {

    @IBOutlet weak var scheduleTitle: UILabel!
    @IBOutlet weak var viewScheduleButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

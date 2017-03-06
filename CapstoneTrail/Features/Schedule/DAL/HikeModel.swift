//
//  HikeModel.swift
//  CapstoneTrail
//
//  Created by Michael Sajuyigbe on 2017-03-05.
//  Copyright © 2017 MSD. All rights reserved.
//

import Foundation
import UIKit

class HikeModel: NSObject {
    
    var uid:              String?
    var name:             String?
    var isPublic:         Bool?
    var locationName:     String?
    var groupDescription: String?
    var longitude:        String?
    var latitude:         String?
    var members =        [String]()
    var userInvitation = [String]()
    var owneruid:   String?
    
    
    var hikeId:     NSMutableArray! = NSMutableArray()
    var trailId:    NSMutableArray! = NSMutableArray()
    var trail:      NSMutableArray! = NSMutableArray()
    var hikeDate:   NSMutableArray! = NSMutableArray()
    
}

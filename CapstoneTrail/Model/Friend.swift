//
//  Friend.swift
//  CapstoneTrail
//
//  Created by Alessandro Santos on 2017-02-17.
//  Copyright © 2017 MSD. All rights reserved.
//

import UIKit

//Represents the friends collection of the database
class Friend: NSObject {
    
    var uid: String?
    var sender_uid: String?
    var receiver_uid: String?
    var isAccepted: Bool?
    var isBlocked: Bool?
}

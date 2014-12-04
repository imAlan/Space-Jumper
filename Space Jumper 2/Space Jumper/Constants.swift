//
//  Constants.swift
//  Space Jumper
//
//  Created by Kong Huang on 12/3/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import Foundation

struct Constants {
    static let BACK_BIT_MASK: UInt32 = 0x1 << 0;
    static let JUMPER_BIT_MASK: UInt32 = 0x1 << 1;
    static let GROUND_BIT_MASK: UInt32 = 0x1 << 2;
    static let METEORITE_BIT_MASK: UInt32 = 0x1 << 3;
    static let DEADLYMETEORITE_BIT_MASK: UInt32 = 0x1 << 4;
    static let POWERUP_BIT_MASK: UInt32 = 0x1 << 5;
}
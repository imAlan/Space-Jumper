//
//  singleton.swift
//  Space Jumper
//
//  Created by Alan Chen on 12/2/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import Foundation

class singleton
{
    class var sharedInstance :singleton
    {
        struct Singleton
        {
            static let instance = singleton()
        }
        return Singleton.instance
    }
    var current_score = 0
}

let instance = singleton.sharedInstance
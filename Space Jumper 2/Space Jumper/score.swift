//
//  score.swift
//  Space Jumper
//
//  Created by Kong Huang on 12/3/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import Foundation

import Foundation

struct score {    
    static func registerScore(tscore: Int) {
        println(tscore)
        if(tscore > score.bestScore()) {
            var reset1 = true
            setBestScore(tscore)
        }
    }
    
    // If reset is True then set best score to 0
    static func setBestScore(bestScore: Int, reset: Bool = false) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if reset{
            userDefaults.setInteger(0, forKey: "bestScore")
        }
        else{
            userDefaults.setInteger(bestScore, forKey: "bestScore")
        }
        userDefaults.synchronize()
    }
    
    static func bestScore() -> NSInteger {
        return NSUserDefaults.standardUserDefaults().integerForKey("bestScore")
    }
}
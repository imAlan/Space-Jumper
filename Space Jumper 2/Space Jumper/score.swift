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
        if(tscore > score.bestScore()) {
            setBestScore(tscore)
        }
    }
    
    static func setBestScore(bestScore: Int) {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setInteger(bestScore, forKey: "bestScore")
        userDefaults.synchronize()
    }
    
    static func bestScore() -> NSInteger {
        return NSUserDefaults.standardUserDefaults().integerForKey("bestScore")
    }
}
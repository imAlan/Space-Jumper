//
//  File.swift
//  Space Jumper
//
//  Created by Kong Huang on 12/3/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import Foundation

struct math {
    static var seed: UInt32 = 0
    
    func setRandomSeed(seed: UInt32) {
        math.seed = seed;
        srand(seed)
    }
    
    func randomFloatBetween(min: Float, max: Float) -> Float {
        let randMaxNumerator = Float(rand() % RAND_MAX)
        let randMaxDivisor = Float(RAND_MAX) * 1.0
        let random: Float = Float((randMaxNumerator / randMaxDivisor) * (max-min)) + Float(min)
        return random
    }
}

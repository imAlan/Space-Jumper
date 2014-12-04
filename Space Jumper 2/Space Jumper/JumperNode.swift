//
//  JumperNode.swift
//  Space Jumper
//
//  Created by Kong Huang on 12/3/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import Foundation

import Foundation
import SpriteKit

class JumperNode: SKSpriteNode {
    
    let VERTICAL_SPEED = 1.0;
    let VERTICAL_DELTA = 5.0;
    
    var deltaPosY = 0.0;
    var goingUp = false;
    
    var jump: SKAction!
    var jumpForever: SKAction!
    
    class func instance() -> JumperNode {
        let alienTexture1 = SKTexture(imageNamed: "Alien");
        let alienTexture2 = SKTexture(imageNamed: "Alien");
        let alienTexture3 = SKTexture(imageNamed: "Alien");
        alienTexture1.filteringMode = SKTextureFilteringMode.Nearest;
        alienTexture2.filteringMode = SKTextureFilteringMode.Nearest;
        alienTexture3.filteringMode = SKTextureFilteringMode.Nearest;
        
        let result = JumperNode(texture:SKTexture(imageNamed: "Alien"));
        
        result.jump = SKAction.animateWithTextures([alienTexture1, alienTexture2, alienTexture3], timePerFrame: 0.2)
        result.jumpForever = SKAction.repeatActionForever(result.jump);
        
        result.runAction(result.jumpForever, withKey: "jumpForever");
        
        return result;
    }
    
    func update(currentTime: NSTimeInterval) {
        if(self.physicsBody == nil) {
            if(self.deltaPosY > VERTICAL_DELTA) {
                self.goingUp = false;
            }
            if(self.deltaPosY < -VERTICAL_DELTA) {
                self.goingUp = true;
            }
            
            let displacement = self.goingUp ? VERTICAL_SPEED : -VERTICAL_SPEED;
            self.position = CGPointMake(self.position.x, self.position.y);
            self.deltaPosY += displacement;
            
        } else {
            self.zRotation = CGFloat(M_PI) * self.physicsBody!.velocity.dy * 0.0005;
        }
    }
    
    func startPlaying() {
        self.deltaPosY = 0;
        self.physicsBody = SKPhysicsBody(rectangleOfSize: self.size);
        self.physicsBody!.categoryBitMask = Constants.JUMPER_BIT_MASK;
        self.physicsBody!.mass = 0.1;
        self.removeActionForKey("jumpForever");
    }
    
    func move() {
        if(self.physicsBody != nil) {
            self.physicsBody!.velocity = CGVectorMake(0, 0);
            self.physicsBody!.applyImpulse(CGVectorMake(0, 20));
            self.runAction(self.jump)
        }
    }
    
}
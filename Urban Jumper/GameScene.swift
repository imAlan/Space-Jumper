//
//  GameScene.swift
//  Urban Jumper
//
//  Created by Alan Chen on 10/16/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    var jumper = SKSpriteNode()
    var building = SKNode()
    enum ColliderType: UInt32{
        case jumper = 1
        case building = 2
    }
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        
        //Physics
        self.physicsWorld.gravity = CGVectorMake(CGFloat(0.0), CGFloat(-5.0))
        
        //Bird
        var JumperTexture = SKTexture(imageNamed: "Alien")
        JumperTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        jumper = SKSpriteNode(texture: JumperTexture)
        jumper.setScale(0.5)
        jumper.position = CGPoint(x: self.frame.size.width * 0.15, y: self.frame.size.height * 0.6)
        
        jumper.physicsBody = SKPhysicsBody(circleOfRadius: jumper.size.height/2.0)
        jumper.physicsBody?.dynamic = true
        jumper.physicsBody?.allowsRotation = false
        jumper.physicsBody?.categoryBitMask = ColliderType.jumper.rawValue
        jumper.physicsBody?.contactTestBitMask = ColliderType.building.rawValue
        jumper.physicsBody?.collisionBitMask = ColliderType.building.rawValue
        
        self.addChild(jumper)
        
        //Ground
        
        var buildingTexture = SKTexture(imageNamed: "ground")
        
        var sprite = SKSpriteNode(texture: buildingTexture)
        sprite.setScale(2.0)
        sprite.position = CGPointMake(self.size.width/4, sprite.size.height/2)
        self.addChild(sprite)
        
        building.position = CGPointMake(0, buildingTexture.size().height)
        building.physicsBody = SKPhysicsBody(rectangleOfSize: CGSizeMake(self.frame.size.width, buildingTexture.size().height * 2.0))
        building.physicsBody?.dynamic = false
        building.physicsBody?.categoryBitMask = ColliderType.building.rawValue
        building.physicsBody?.contactTestBitMask = ColliderType.jumper.rawValue
        building.physicsBody?.collisionBitMask = ColliderType.jumper.rawValue
        self.addChild(building)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
           let location = touch.locationInNode(self)
            
            let jump = SKAction()
            

            jumper.runAction(jump, withKey: "jumping")
            jumper.physicsBody?.velocity = CGVectorMake(0, 0)
            jumper.physicsBody?.applyImpulse(CGVectorMake(0, 25))
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}

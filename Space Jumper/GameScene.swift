//
//  GameScene.swift
//  Space Jumper
//
//  Created by Alan Chen on 11/20/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    @IBOutlet weak var scoreLabel: UILabel!
    var jumper = SKSpriteNode()
    var sprite = SKSpriteNode()
    var meteorMoveAndRemove = SKAction()
    var score = 0
    
    enum ColliderType: UInt32{
        case jumper = 1
        case meteorite = 2
    }
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        //Background
        var space = SKSpriteNode(imageNamed: "space.jpg")
        self.addChild(space)
        
        //Physics
        self.physicsWorld.gravity = CGVectorMake(CGFloat(0.0), CGFloat(-5.0))
        
        //Bird
        var JumperTexture = SKTexture(imageNamed: "Alien")
        JumperTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        jumper = SKSpriteNode(texture: JumperTexture)
        jumper.setScale(0.4)
        jumper.position = CGPoint(x: self.frame.size.width * 0.15, y: self.frame.size.height * 0.6)
        
        jumper.physicsBody = SKPhysicsBody(circleOfRadius: jumper.size.height/2.0)
        jumper.physicsBody?.dynamic = true
        jumper.physicsBody?.allowsRotation = false
        jumper.physicsBody?.categoryBitMask = ColliderType.jumper.rawValue
        jumper.physicsBody?.contactTestBitMask = ColliderType.meteorite.rawValue
        jumper.physicsBody?.collisionBitMask = ColliderType.meteorite.rawValue
        
        self.addChild(jumper)
        
        //Metorite
        
        var meteoriteTexture = SKTexture(imageNamed: "metorite_1.png")
        
        sprite = SKSpriteNode(texture: meteoriteTexture)
        
        sprite.position = CGPointMake(self.size.width/7, 4 * sprite.size.height/2)
        sprite.setScale(1)
        self.addChild(sprite)
        
        sprite.physicsBody = SKPhysicsBody(rectangleOfSize: sprite.size)
        sprite.physicsBody?.dynamic = false
        sprite.physicsBody?.categoryBitMask = ColliderType.meteorite.rawValue
        sprite.physicsBody?.contactTestBitMask = ColliderType.jumper.rawValue
        sprite.physicsBody?.collisionBitMask = ColliderType.jumper.rawValue
        
        let distanceToMove = CGFloat(self.frame.size.width + 1.0 * sprite.size.width)
        let moveMeteors = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        let removeMeteors = SKAction.removeFromParent()
        meteorMoveAndRemove = SKAction.sequence([moveMeteors, removeMeteors])
        sprite.runAction(meteorMoveAndRemove)
        
        // actually spawn meteors and shit
        let spawn = SKAction.runBlock({() in self.spawnMeteorites()})
        // find a way to randomize this time interval
        let delayMeteors = SKAction.waitForDuration(NSTimeInterval(0.6))
        
        let spawnThenDelay = SKAction.sequence([spawn, delayMeteors])
        let spawnThenDelayForever = SKAction.repeatActionForever(spawnThenDelay)
        
        self.runAction(spawnThenDelayForever)
    }
    
    func spawnMeteorites(){
        var size_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var position_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        score += 100
        scoreLabel.text = "Score: \(score)"
        
        var meteoriteFile = "metorite_1.png"
        var meteorTexture = SKTexture(imageNamed: meteoriteFile)
        
        let meteor = SKSpriteNode(texture: meteorTexture)
        
        // randomize setscale
        meteor.setScale(0.6 * size_random)
        while(meteor.size.width < 15.0){
            size_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            meteor.setScale(0.6*size_random)
        }
        
        // controlling meteor movements
        let distanceToMove = CGFloat(self.frame.size.width + 1.0 * meteor.size.width)
        
        // randomize speed
        let moveMeteors = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.005 * size_random * distanceToMove))
        let removeMeteors = SKAction.removeFromParent()
        meteorMoveAndRemove = SKAction.sequence([moveMeteors, removeMeteors])
        
        
        // randomize y position (self.frame.size.height/2.0)
        meteor.position = CGPointMake(self.frame.size.width + meteor.size.width/2.0,
                                      (self.frame.size.height * 1/2 * position_random) + self.frame.size.height * 1/4)
        meteor.physicsBody = SKPhysicsBody(rectangleOfSize: meteor.size)
        meteor.physicsBody?.dynamic = false
        
        // adjust movement parameters
        meteor.runAction(meteorMoveAndRemove)
        self.addChild(meteor)
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        /* Called when a touch begins */
        
        for touch: AnyObject in touches {
            let location = touch.locationInNode(self)
            
            let jump = SKAction()
            
            
            jumper.runAction(jump, withKey: "jumping")
            jumper.physicsBody?.velocity = CGVectorMake(0, 0)
            jumper.physicsBody?.applyImpulse(CGVectorMake(0, 17))
        }
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
    }
}

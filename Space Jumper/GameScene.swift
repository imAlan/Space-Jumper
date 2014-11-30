//
//  GameScene.swift
//  Space Jumper
//
//  Created by Alan Chen on 11/20/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    weak var gameViewController:GameViewController!
    @IBOutlet weak var scoreLabel: UILabel!
    
    // background
    var space: SKSpriteNode!
    var jumpOffPad: SKSpriteNode!
    
    // obstacles
    var distanceToMove: CGFloat!
    var moveMeteors: SKAction!
    var removeMeteors: SKAction!
    var meteorMoveAndRemove: SKAction!
    
    // character
    var jumper:SKSpriteNode!
    
    // game
    
    // time
    var lastUpdateTimeInterval: CFTimeInterval = -1.0
    var deltaTime: CGFloat = 0.0
    var current_time = 0.0
    var diff_sec = 0
    // collision
    
    // counters
    var score = 0
    var count = 0
    var limit = 50
    
    // colliders
    // add different collidertypes (powerups!)
    
    enum ColliderType: UInt32{
        case jumper = 1
        case meteorite = 2
        case deadlymeteorite = 3
    }
    
    override func didMoveToView(view: SKView) {
        /* Setup your scene here */
        initSetup()
        setupBackground()
        setupJumper()
        setupGround()
    }
    
    func initSetup(){
        //Physics
        self.physicsWorld.gravity = CGVectorMake(CGFloat(0.0), CGFloat(-5.0))
        self.physicsWorld.contactDelegate = self
        
        // movement initial
        distanceToMove = CGFloat(self.frame.size.width * 0.5)
        moveMeteors = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        removeMeteors = SKAction.removeFromParent()
        meteorMoveAndRemove = SKAction.sequence([moveMeteors, removeMeteors])
    }
    
    func setupBackground(){
        //Background
        space = SKSpriteNode(imageNamed: "space2.jpg")
        space.name = "background"
        self.addChild(space)
        
        space.setScale(0.5)
        space.position = CGPoint(x: self.frame.size.width / 2, y: self.frame.size.height / 2)
        
        // figure how to do parallax scrolling without lag
    }
    
    func setupJumper(){
        // setting up alien jumper
        // animation code would go here
        var JumperTexture = SKTexture(imageNamed: "Alien")
        JumperTexture.filteringMode = SKTextureFilteringMode.Nearest
        
        jumper = SKSpriteNode(texture: JumperTexture)
        jumper.name = "jumper"
        
        jumper.setScale(0.4)
        jumper.position = CGPoint(x: self.frame.size.width * 0.15, y: self.frame.size.height * 0.6)
        
        jumper.physicsBody = SKPhysicsBody(circleOfRadius: jumper.size.height/2.0)
        jumper.physicsBody?.dynamic = true
        jumper.physicsBody?.allowsRotation = false
        jumper.physicsBody?.categoryBitMask = ColliderType.jumper.rawValue
        jumper.physicsBody?.contactTestBitMask = ColliderType.meteorite.rawValue | ColliderType.deadlymeteorite.rawValue
        jumper.physicsBody?.collisionBitMask = ColliderType.meteorite.rawValue | ColliderType.deadlymeteorite.rawValue
        
        self.addChild(jumper)        
    }
    
    func setupGround(){
        // setting up jump off pad
        var meteoriteTexture = SKTexture(imageNamed: "metorite_1.png")
        
        jumpOffPad = SKSpriteNode(texture: meteoriteTexture)
        jumpOffPad.name = "platformmeteorite"
        self.addChild(jumpOffPad)
        
        jumpOffPad.position = CGPointMake(self.size.width/7, 4 * jumpOffPad.size.height/2)
        jumpOffPad.setScale(1)
        
        jumpOffPad.runAction(meteorMoveAndRemove)
        
        jumpOffPad.physicsBody = SKPhysicsBody(rectangleOfSize: jumpOffPad.size)
        jumpOffPad.physicsBody?.dynamic = false
        jumpOffPad.physicsBody?.categoryBitMask = ColliderType.meteorite.rawValue
        jumpOffPad.physicsBody?.contactTestBitMask = ColliderType.jumper.rawValue
        jumpOffPad.physicsBody?.collisionBitMask = ColliderType.jumper.rawValue
        
        // off screen collsion would go here
    }
    
    func spawnMeteorites(){
        // generating meteors
        var size_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var position_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        score += 100
        gameViewController.scoreLabel.text = "Score: \(score)"
        
        var meteoriteFile = "metorite_1.png"
        var meteorTexture = SKTexture(imageNamed: meteoriteFile)
        
        let meteor = SKSpriteNode(texture: meteorTexture)
        meteor.name = "meteor"
        self.addChild(meteor)
        
        meteor.physicsBody?.categoryBitMask = ColliderType.deadlymeteorite.rawValue
        // randomize setscale
        meteor.setScale(0.6 * size_random)
        while(meteor.size.width < 15.0){
            size_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
            meteor.setScale(0.6*size_random)
        }
        
        // controlling meteor movements
        distanceToMove = CGFloat(self.frame.size.width + 1.0 * meteor.size.width)
        
        // randomize speed
        moveMeteors = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.005 * size_random * distanceToMove))
        removeMeteors = SKAction.removeFromParent()
        meteorMoveAndRemove = SKAction.sequence([moveMeteors, removeMeteors])
        
        
        // randomize y position (self.frame.size.height/2.0)
        meteor.position = CGPointMake(self.frame.size.width + meteor.size.width/2.0,
                                      (self.frame.size.height * 1/2 * position_random) + self.frame.size.height * 1/4)
        meteor.physicsBody = SKPhysicsBody(rectangleOfSize: meteor.size)
        meteor.physicsBody?.dynamic = false
        
        // adjust movement parameters
        meteor.runAction(meteorMoveAndRemove)
    }
    
    func spawnPowerUp(){
        
    }
    
    func spawnPremadeType1(){
        
    }
    
    func spawnPremadeType2(){
        
    }
    
    func changeBackground(){
        
    }
    
    func didBeginContact(contact:SKPhysicsContact)
    {
        //println("A:\(contact.bodyA.node!.name!)   B:\(contact.bodyB.node!.name!)")
        if(contact.bodyA.node!.name! == "meteor" && contact.bodyB.node!.name! == "jumper")
        {
            // Game Over
            self.paused = true
            //self.removeAllActions()
            self.gameViewController.gameOver(self)
        }
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
        // spawn meteors every 5 frames
        if current_time == 0.0{
            current_time = currentTime
        }
        diff_sec = Int((currentTime - current_time)/1.5)
        
        println("limit: \(limit)  count: \(count)")
        count++
        if (count == limit || count > limit){
            spawnMeteorites()
            count = 0
        }
        
        //Change number of spawn meteorites base on time
        if diff_sec < 5
        {
            limit = 50
        }
        else if diff_sec < 10
        {
            limit = 45
        }
        else if diff_sec < 15
        {
            limit = 40
        }
        else if diff_sec < 20
        {
            limit = 30
        }
        else if diff_sec < 25
        {
            limit = 35
        }
        else if diff_sec < 30
        {
            limit = 30
        }
        else if diff_sec < 35
        {
            limit = 25
        }
        else if diff_sec < 40
        {
            limit = 20
        }
        else if diff_sec < 45
        {
            limit = 15
        }
        else if diff_sec < 50
        {
            limit = 10
        }
        else
        {
            limit = 8
        }
        
    }
}

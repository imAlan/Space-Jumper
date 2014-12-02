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
    var ground: SKSpriteNode!
    var ground2: SKSpriteNode!
    
    // obstacles
    var distanceToMove: CGFloat!
    var moveObject: SKAction!
    var removeObject: SKAction!
    var objectMoveAndRemove: SKAction!
    
    var meteors: [SKSpriteNode]!
    
    // character
    var jumper:SKSpriteNode!
    var pink_jumper:SKSpriteNode!
    
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
    var limit = 60
    var powerUpTimer = 0
    
    // booleans
    
    var poweredUp = false
    
    // colliders
    // add different collidertypes (powerups!)
    
    enum ColliderType: UInt32{
        case jumper = 1
        case meteorite = 2
        case deadlymeteorite = 3
        case powerUp = 4
        case ground = 5
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
        moveObject = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        removeObject = SKAction.removeFromParent()
        objectMoveAndRemove = SKAction.sequence([moveObject, removeObject])
    }
    
    func setupBackground(){
        //Background
        space = SKSpriteNode(imageNamed: "space.jpg")
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
        jumper.position = CGPoint(x: self.frame.size.width * 0.15, y: self.frame.size.height * 0.5)
        
        jumper.physicsBody = SKPhysicsBody(circleOfRadius: jumper.size.height/2.0)
        jumper.physicsBody?.dynamic = true
        jumper.physicsBody?.allowsRotation = false
        jumper.physicsBody?.usesPreciseCollisionDetection = true;
        jumper.physicsBody?.categoryBitMask = ColliderType.jumper.rawValue
        jumper.physicsBody?.contactTestBitMask = ColliderType.meteorite.rawValue | ColliderType.deadlymeteorite.rawValue | ColliderType.powerUp.rawValue | ColliderType.ground.rawValue
        jumper.physicsBody?.collisionBitMask = ColliderType.meteorite.rawValue | ColliderType.deadlymeteorite.rawValue | ColliderType.powerUp.rawValue | ColliderType.ground.rawValue
        
        self.addChild(jumper)
    }
    
    func setupGround(){
        // setting up jump off pad
        var meteoriteTexture = SKTexture(imageNamed: "meteorite_10.png")
        
        jumpOffPad = SKSpriteNode(texture: meteoriteTexture)
        jumpOffPad.name = "platformmeteorite"
        self.addChild(jumpOffPad)
        
        jumpOffPad.position = CGPointMake(self.size.width/7, 4 * jumpOffPad.size.height/2)
        jumpOffPad.setScale(1)
        
        jumpOffPad.runAction(objectMoveAndRemove)
        
        jumpOffPad.physicsBody = SKPhysicsBody(rectangleOfSize: jumpOffPad.size)
        jumpOffPad.physicsBody?.dynamic = false
        jumpOffPad.physicsBody?.categoryBitMask = ColliderType.meteorite.rawValue
        jumpOffPad.physicsBody?.contactTestBitMask = ColliderType.jumper.rawValue
        jumpOffPad.physicsBody?.collisionBitMask = ColliderType.jumper.rawValue
        
        // Lower Ground
        var groundTexture = SKTexture(imageNamed: "groundRock")
        ground = SKSpriteNode(texture: groundTexture)
        ground.name = "ground"
        ground.size.width = 2000
        self.addChild(ground)
        ground.position = CGPointMake(ground.size.width/7, -ground.size.height)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.categoryBitMask = ColliderType.ground.rawValue
        ground.physicsBody?.dynamic = false
        
        // Upper Ground
        ground2 = SKSpriteNode(texture: groundTexture)
        ground2.name = "ground"
        ground2.size.width = 2000
        self.addChild(ground2)
        ground2.position = CGPointMake(ground.size.width/7, self.frame.size.height)
        ground2.physicsBody = SKPhysicsBody(rectangleOfSize: ground2.size)
        ground2.physicsBody?.categoryBitMask = ColliderType.ground.rawValue
        ground2.physicsBody?.dynamic = false
    }
    
    //Generating Meteorites
    func spawnMeteorites(){
        //Random variables
        var size_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var position_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var meteorite_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var meteorite_num = Int(meteorite_random*8)
        
        score += 100
        gameViewController.scoreLabel.text = "Score: \(score)"
        
        //Setup Meteorite
        var meteoriteFile = "meteorite_\(meteorite_num).png"
        var meteorTexture = SKTexture(imageNamed: meteoriteFile)
        let meteor = SKSpriteNode(texture: meteorTexture)
        meteor.name = "meteor"
        self.addChild(meteor)
        
        meteor.physicsBody?.categoryBitMask = ColliderType.deadlymeteorite.rawValue
        // randomize setscale
        while size_random < 0.5
        {
            size_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        }
        meteor.setScale(0.7 * size_random)
        
        // controlling meteor movements
        distanceToMove = CGFloat(self.frame.size.width + 1.0 * meteor.size.width)
        
        // randomize speed
        moveObject = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.005 * size_random * distanceToMove))
        removeObject = SKAction.removeFromParent()
        objectMoveAndRemove = SKAction.sequence([moveObject, removeObject])
        
        
        // randomize y position (self.frame.size.height/2.0)
        meteor.position = CGPointMake(self.frame.size.width + meteor.size.width/2.0,
                                      (self.frame.size.height * 1/2 * position_random) + self.frame.size.height * 1/4)
        meteor.physicsBody = SKPhysicsBody(rectangleOfSize: meteor.size)
        meteor.physicsBody?.dynamic = false
        var rotateMeteorite = SKAction.rotateByAngle(CGFloat(-M_PI/2.5 ), duration: 1.0)
        var rotateMeteoriteForever = SKAction.repeatActionForever(rotateMeteorite)
        
        meteor.runAction(rotateMeteoriteForever)
        
        // adjust movement parameters
        meteor.runAction(objectMoveAndRemove)
    }
    
    func spawnSpaceship()
    {
        //Add Code Here Later
    }
    
    func spawnUFO(){
        // generating meteors
        var size_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var position_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var meteorite_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var meteorite_num = Int(meteorite_random*4)
        
        score += 100
        gameViewController.scoreLabel.text = "Score: \(score)"
        
        var ufoFile = "ufo_\(meteorite_num).png"
        var ufoTexture = SKTexture(imageNamed: ufoFile)
        
        let ufo = SKSpriteNode(texture: ufoTexture)
        let ufo2 = SKSpriteNode(texture: ufoTexture)
        ufo.name = "ufo"
        ufo2.name = "ufo"
        self.addChild(ufo)
        self.addChild(ufo2)
        
        ufo.physicsBody?.categoryBitMask = ColliderType.deadlymeteorite.rawValue
        ufo.setScale(1.0)
        
        ufo2.physicsBody?.categoryBitMask = ColliderType.deadlymeteorite.rawValue
        ufo2.setScale(1.0)
        
        // controlling meteor movements
        distanceToMove = CGFloat(self.frame.size.width + 1.0 * ufo.size.width)
        
        // randomize speed
        moveObject = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.0025 * distanceToMove))
        removeObject = SKAction.removeFromParent()
        objectMoveAndRemove = SKAction.sequence([moveObject, removeObject])
        
        //ufo.anchorPoint = CGPointMake(0, 0)
        //ufo2.anchorPoint = CGPointMake(0, 0)
        
        var rotateUFO = SKAction.rotateByAngle(CGFloat(-M_PI/2.0), duration: 1.0)
        var rotateUFOForever = SKAction.repeatActionForever(rotateUFO)
        
        // randomize y position (self.frame.size.height/2.0)
       
        var yposition_random = abs((self.frame.size.height - (self.frame.size.height/2.5) - ufo.size.height * 3.2) * position_random) + ufo.size.height * 1.6
        ufo.position = CGPointMake(self.frame.size.width + ufo.size.width/2.0, yposition_random)
        println(yposition_random)
        ufo2.position = CGPointMake(self.frame.size.width + ufo.size.width/2.0, yposition_random + self.frame.size.height/2.5)
        ufo.physicsBody = SKPhysicsBody(rectangleOfSize: ufo.size)
        ufo2.physicsBody = SKPhysicsBody(rectangleOfSize: ufo2.size)
        
        ufo.physicsBody?.dynamic = false
        ufo2.physicsBody?.dynamic = false
        
        // adjust movement parameters
        ufo.runAction(rotateUFOForever)
        ufo.runAction(objectMoveAndRemove)
        ufo2.runAction(rotateUFOForever)
        ufo2.runAction(objectMoveAndRemove)
    }
    
    func spawnColorPowerUp(powerupNum: Int){
        println(powerupNum)
        // generating meteors
        var position_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        
        var powerUpFile = ""
        
        if powerupNum == 0
        {
            powerUpFile = "power_green.png"
        }
        else if powerupNum == 1
        {
            powerUpFile = "power_red.png"
        }
        
        var powerUpTexture = SKTexture(imageNamed: powerUpFile)
        
        let powerUp = SKSpriteNode(texture: powerUpTexture)
        powerUp.setScale(1.0)
        // set bitmask
        powerUp.physicsBody?.categoryBitMask = ColliderType.powerUp.rawValue
        
        // set scale
        if powerupNum == 0
        {
            powerUp.name = "green_powerup"
        }
        else if powerupNum == 1
        {
            powerUp.name = "red_powerup"
        }
        
        self.addChild(powerUp)
        // controlling movements
        distanceToMove = CGFloat(self.frame.size.width + 1.0 * powerUp.size.width)
        
        // speed
        moveObject = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.003 * distanceToMove))
        removeObject = SKAction.removeFromParent()
        objectMoveAndRemove = SKAction.sequence([moveObject, removeObject])
        
        // randomize y position (self.frame.size.height/2.0)
        powerUp.position = CGPointMake(self.frame.size.width + powerUp.size.width/2.0,
            (self.frame.size.height * 1/2 * position_random) + self.frame.size.height * 1/4)
        powerUp.physicsBody = SKPhysicsBody(rectangleOfSize: powerUp.size)
        
        // so it doesn't collide with other stuff
        powerUp.physicsBody?.dynamic = false
        
        // adjust movement parameters
        powerUp.runAction(objectMoveAndRemove)
    }
    
    func spawnPowerups()
    {
        var powerup_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var num = Int(powerup_random * 3)
        println(num)
        if num == 0
        {
            spawnColorPowerUp(0)
        }
        else if num == 1
        {
            spawnColorPowerUp(1)
        }
        else if num == 2
        {
            spawnUFO()
        }
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
        if(contact.bodyA.node!.name! == "meteor" || contact.bodyA.node!.name! == "ufo" || contact.bodyA.node!.name! == "ground" && contact.bodyB.node!.name! == "jumper")
        {
            // Game Over
            self.paused = true
            //self.removeAllActions()
            self.gameViewController.gameOver(self)
        }
        if(contact.bodyA.node!.name! == "red_powerup" && contact.bodyB.node!.name! == "jumper")
        {
            // powered up; make alien smaller
            poweredUp = true
            jumper.texture = SKTexture(imageNamed: "Pink_Alien")
            jumper.setScale(0.25)
            jumper.physicsBody?.dynamic = true
            powerUpTimer = 100
        }
        if(contact.bodyA.node!.name! == "green_powerup" && contact.bodyB.node!.name! == "jumper")
        {
            // powered up; make alien bigger
            poweredUp = true
            jumper.texture = SKTexture(imageNamed: "Blue_Alien")
            jumper.setScale(0.5)
            jumper.physicsBody?.dynamic = true
            powerUpTimer = 100
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
        
        //println("limit: \(limit)  count: \(count)")
        count++
        if (count == limit || count > limit){
            spawnMeteorites()
            spawnPowerups()
            count = 0
        }
        
        if (powerUpTimer > 0){
            powerUpTimer--
        }
        
        if (powerUpTimer <= 0){
            poweredUp = false
            jumper.texture = SKTexture(imageNamed: "Alien")
            jumper.physicsBody?.dynamic = true
            jumper.setScale(0.4)
        }
        
        jumper.position.x = self.frame.size.width * 0.15
        
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

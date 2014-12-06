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
    
    // numbers
    let BACK1_SCROLLING_SPEED: CGFloat = 0.5
    let BACK2_SCROLLING_SPEED: CGFloat = 1.5
    let BACK3_SCROLLING_SPEED: CGFloat = 2.5
    
    // counters
    var count = 0
    var limit = 60
    var powerUpTimer = 0
    
    // booleans
    var poweredUp = false
    var jumperDeath = false
    var inGame = false
    var gameStarted = false
    
    // background
    var back1: SKScrollingNode?
    var back2: SKScrollingNode?
    var jumpOffPad: SKSpriteNode!
    var ground: SKSpriteNode!
    var ground2: SKSpriteNode!
    
    // score
    var scoreLabel: SKLabelNode = SKLabelNode(fontNamed: "Helvetica-Bold");
    var currentScore:Int = 0
    
    // obstacles
    var distanceToMove: CGFloat!
    var moveObject: SKAction!
    var removeObject: SKAction!
    var objectMoveAndRemove: SKAction!
    var meteors: [SKSpriteNode]!
    
    // character
    var jumper:JumperNode!
    //var pink_jumper:SKSpriteNode!
    
    // time
    var lastUpdateTimeInterval: CFTimeInterval = -1.0
    var deltaTime: CGFloat = 0.0
    var current_time = 0.0
    var diff_sec = 0
    
    // delegates
    var sceneDelegate: SceneDelegate?
 
    required override init(size: CGSize) {
        super.init(size: size)
        self.physicsWorld.contactDelegate = self
        self.startGame()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func startGame() {
        /* Setup your scene here */
        jumperDeath = false
        self.removeAllChildren()
        
        inGame = true
        initSetup()
        setupBackground()
        setupScore()
        setupJumper()
        setupGround()
        
        if(self.sceneDelegate != nil) {
            self.sceneDelegate!.eventStart();
        }
    }
    
    func initSetup(){
        //Physics
        self.physicsWorld.gravity = CGVectorMake(CGFloat(0.0), CGFloat(-5.0))

        // set score to 0
        currentScore = 0
        
        // Setup PowerUp Timer
        powerUpTimer = 0
        
        // movement initial
        distanceToMove = CGFloat(self.frame.size.width)
        moveObject = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        removeObject = SKAction.removeFromParent()
        objectMoveAndRemove = SKAction.sequence([moveObject, removeObject])
    }
    
    func setupBackground(){
        back1 = SKScrollingNode.scrollingNode("Space.jpg", containerWidth:self.frame.size.width, containerHeight:self.frame.size.height);
        //self.setScale(2.0);
        back1!.scrollingSpeed = BACK1_SCROLLING_SPEED;
        back1!.anchorPoint = CGPointZero;
        back1!.setScale(0.3)
        self.addChild(self.back1!);
        
        //add background 2 and 3 later
    }
    
    func setupScore() {
        currentScore = 0;
        scoreLabel.text = "0";
        scoreLabel.fontSize = 150;
        scoreLabel.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        scoreLabel.alpha = 0.2;
        addChild(self.scoreLabel);
    }
    
    func setupJumper(){
        println("setup jumper")
        jumper = JumperNode.instance();
        jumper!.position = CGPointMake(100, CGRectGetMidY(self.frame)/1.25);
        jumper!.name = "jumper";
        jumper.setScale(0.3);
        self.addChild(jumper!);
    }
    
    func setupGround(){
        // setting up jump off pad
        var meteoriteTexture = SKTexture(imageNamed: "meteorite_10.png")
        
        jumpOffPad = SKSpriteNode(texture: meteoriteTexture)
        jumpOffPad.name = "platformmeteorite"
        self.addChild(jumpOffPad)
        
        jumpOffPad.position = CGPointMake(self.frame.width/7, self.frame.height/4)
        jumpOffPad.setScale(0.75)
        
        //jumpOffPad.runAction(objectMoveAndRemove)
        
        jumpOffPad.physicsBody = SKPhysicsBody(rectangleOfSize: jumpOffPad.size)
        jumpOffPad.physicsBody?.dynamic = false
//        jumpOffPad.physicsBody?.categoryBitMask = Constants.METEORITE_BIT_MASK
//        jumpOffPad.physicsBody?.contactTestBitMask = Constants.JUMPER_BIT_MASK
//        jumpOffPad.physicsBody?.collisionBitMask = Constants.JUMPER_BIT_MASK
        
        // Lower Ground
        var groundTextureLower = SKTexture(imageNamed: "groundRock2")
        var groundTextureUpper = SKTexture(imageNamed: "groundRock")
        ground = SKSpriteNode(texture: groundTextureLower)
        ground.name = "ground"
        ground.setScale(0.85)
        self.addChild(ground)
        ground.position = CGPointMake(CGRectGetMidX(self.frame), 0)
        ground.physicsBody = SKPhysicsBody(rectangleOfSize: ground.size)
        ground.physicsBody?.categoryBitMask = Constants.GROUND_BIT_MASK
        ground.physicsBody?.contactTestBitMask = Constants.JUMPER_BIT_MASK
        ground.physicsBody?.collisionBitMask = Constants.JUMPER_BIT_MASK
        ground.physicsBody?.dynamic = false
        
        // Upper Ground
        ground2 = SKSpriteNode(texture: groundTextureUpper)
        ground2.name = "ground"
        ground2.setScale(0.85)
        self.addChild(ground2)
        ground2.position = CGPointMake(CGRectGetMidX(self.frame), self.frame.size.height)
        ground2.physicsBody = SKPhysicsBody(rectangleOfSize: ground2.size)
        ground2.physicsBody?.categoryBitMask = Constants.GROUND_BIT_MASK
        ground2.physicsBody?.contactTestBitMask = Constants.JUMPER_BIT_MASK
        ground2.physicsBody?.collisionBitMask = Constants.JUMPER_BIT_MASK
        ground2.physicsBody?.dynamic = false
    }
    
    //Generating Meteorites
    func spawnMeteorites(){
        //Random variables
        var size_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var position_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var meteorite_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var meteorite_num = Int(meteorite_random*8)

        //Setup Meteorite
        var meteoriteFile = "meteorite_\(meteorite_num).png"
        var meteorTexture = SKTexture(imageNamed: meteoriteFile)
        let meteor = SKSpriteNode(texture: meteorTexture)
        meteor.name = "meteor"
        self.addChild(meteor)
        
        meteor.physicsBody?.categoryBitMask = Constants.DEADLYMETEORITE_BIT_MASK

        // randomize setscale
        while size_random < 0.5
        {
            size_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        }
        meteor.setScale(0.7 * size_random)
        
        // controlling meteor movements
        distanceToMove = CGFloat(self.frame.size.width + (1.0 * meteor.size.width))
        
        // randomize speed
        moveObject = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.005 * size_random * distanceToMove))
        removeObject = SKAction.removeFromParent()
        objectMoveAndRemove = SKAction.sequence([moveObject, removeObject])
        
        
        // randomize y position (self.frame.size.height/2.0)
        meteor.position = CGPointMake(self.frame.size.width + meteor.size.width/2.0,
                                      (self.frame.size.height * 1/2 * position_random) + self.frame.size.height * 1/4)
        meteor.physicsBody = SKPhysicsBody(rectangleOfSize: meteor.size)
        meteor.physicsBody?.categoryBitMask = Constants.METEORITE_BIT_MASK
        meteor.physicsBody?.contactTestBitMask = Constants.JUMPER_BIT_MASK
        meteor.physicsBody?.collisionBitMask = Constants.JUMPER_BIT_MASK
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
        var UFO_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var UFO_num = Int(UFO_random*4)
        
        var ufoFile = "ufo_\(UFO_num).png"
        var ufoTexture = SKTexture(imageNamed: ufoFile)
        
        let ufo = SKSpriteNode(texture: ufoTexture)
        let ufo2 = SKSpriteNode(texture: ufoTexture)
        ufo.name = "ufo"
        ufo2.name = "ufo"
        self.addChild(ufo)
        self.addChild(ufo2)
        
        ufo.physicsBody?.categoryBitMask = Constants.DEADLYMETEORITE_BIT_MASK
        ufo.setScale(1.0)
        
        ufo2.physicsBody?.categoryBitMask = Constants.DEADLYMETEORITE_BIT_MASK
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
        //println(yposition_random)
        ufo2.position = CGPointMake(self.frame.size.width + ufo.size.width/2.0, yposition_random + self.frame.size.height/2.5)
        ufo.physicsBody = SKPhysicsBody(rectangleOfSize: ufo.size)
        ufo2.physicsBody = SKPhysicsBody(rectangleOfSize: ufo2.size)
        
        ufo.physicsBody?.categoryBitMask = Constants.METEORITE_BIT_MASK
        ufo.physicsBody?.contactTestBitMask = Constants.JUMPER_BIT_MASK
        ufo.physicsBody?.collisionBitMask = Constants.JUMPER_BIT_MASK
        
        ufo2.physicsBody?.categoryBitMask = Constants.METEORITE_BIT_MASK
        ufo2.physicsBody?.contactTestBitMask = Constants.JUMPER_BIT_MASK
        ufo2.physicsBody?.collisionBitMask = Constants.JUMPER_BIT_MASK
        
        ufo.physicsBody?.dynamic = false
        ufo2.physicsBody?.dynamic = false
        
        // adjust movement parameters
        ufo.runAction(rotateUFOForever)
        ufo.runAction(objectMoveAndRemove)
        ufo2.runAction(rotateUFOForever)
        ufo2.runAction(objectMoveAndRemove)
    }
    
    func spawnColorPowerUp(powerupNum: Int){
        //println(powerupNum)
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
        powerUp.physicsBody?.categoryBitMask = Constants.POWERUP_BIT_MASK
        
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
        
        powerUp.physicsBody?.categoryBitMask = Constants.POWERUP_BIT_MASK
        powerUp.physicsBody?.contactTestBitMask = Constants.JUMPER_BIT_MASK
        powerUp.physicsBody?.collisionBitMask = Constants.JUMPER_BIT_MASK
        // so it doesn't collide with other stuff
        powerUp.physicsBody?.dynamic = false
        
        // adjust movement parameters
        powerUp.runAction(objectMoveAndRemove)
    }
    
    func spawnPowerups()
    {
        var powerup_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var num = Int(powerup_random * 2)
        //println(num)
        if num == 0
        {
            spawnColorPowerUp(0)
        }
        else if num == 1
        {
            spawnColorPowerUp(1)
        }
        else if num == 15
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
        println("A:\(contact.bodyA.node!.name!)   B:\(contact.bodyB.node!.name!)")
        if(
            ((contact.bodyB.node!.name! == "meteor" || contact.bodyB.node!.name! == "ufo" || contact.bodyB.node!.name! == "ground" ) && contact.bodyA.node!.name! == "jumper")
            ||
            ((contact.bodyA.node!.name! == "meteor" || contact.bodyA.node!.name! == "ufo" || contact.bodyA.node!.name! == "ground" ) && contact.bodyB.node!.name! == "jumper")
        )
        {
            println("collision jumper")
            if(!jumperDeath) {
                jumperDeath = true;
                inGame = false;
                score.registerScore(currentScore);
                instance.current_score = currentScore
                if(self.sceneDelegate != nil) {
                    self.sceneDelegate!.eventJumperDeath();
                }
            }
        }
        
        if ((contact.bodyA.node!.name! == "red_powerup" && contact.bodyB.node!.name! == "jumper")
            ||
            (contact.bodyB.node!.name! == "red_powerup" && contact.bodyA.node!.name! == "jumper"))
        {
            // powered up; make alien smaller
            poweredUp = true
            jumper.texture = SKTexture(imageNamed: "Pink_Alien")
            jumper.setScale(0.25)
            jumper.physicsBody?.dynamic = true
            powerUpTimer = 400
        }
        
        if ((contact.bodyA.node!.name! == "green_powerup" && contact.bodyB.node!.name! == "jumper")
            ||
            (contact.bodyA.node!.name! == "green_powerup" && contact.bodyB.node!.name! == "jumper"))
        {
            // powered up; make alien bigger
            poweredUp = true
            jumper.texture = SKTexture(imageNamed: "Blue_Alien")
            jumper.setScale(0.5)
            jumper.physicsBody?.dynamic = true
            powerUpTimer = 400
        }
    }
    
    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        if(jumperDeath) {
            startGame();
            gameStarted = false
        } else {
            gameStarted = true
            jumpOffPad.runAction(objectMoveAndRemove)
            jumper!.startPlaying();
            self.sceneDelegate!.eventPlay();
            jumper!.move();
        }
    }

    func updateScore(){
        currentScore++;
        scoreLabel.text = NSString(format: "%lu", self.currentScore);
    }
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        // spawn meteors every 5 frames
        
        if (inGame && gameStarted){
            updateScore()
        }
        
        if(!jumperDeath && gameStarted) {
            back1!.update(currentTime);
            jumper!.update(currentTime);

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
            println(powerUpTimer)
            if (powerUpTimer > 0){
                powerUpTimer--
            }
        
            if (powerUpTimer <= 0){
                poweredUp = false
                jumper.texture = SKTexture(imageNamed: "Alien")
                jumper.physicsBody?.dynamic = true
                //    jumper.setScale(0.4)
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
}
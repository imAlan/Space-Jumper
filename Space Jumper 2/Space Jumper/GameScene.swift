//
//  GameScene.swift
//  Space Jumper
//
//  Created by Alan Chen on 11/20/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import SpriteKit
import AVFoundation

var backgroundMusicPlayer: AVAudioPlayer!

func playBackgroundMusic(filename: String) {
    let url = NSBundle.mainBundle().URLForResource(
        filename, withExtension: nil)
    if (url == nil) {
        println("Could not find file: \(filename)")
        return
    }
    
    var error: NSError? = nil
    backgroundMusicPlayer =
        AVAudioPlayer(contentsOfURL: url, error: &error)
    if backgroundMusicPlayer == nil {
        println("Could not create audio player: \(error!)")
        return
    }
    
    backgroundMusicPlayer.numberOfLoops = -1
    backgroundMusicPlayer.prepareToPlay()
    backgroundMusicPlayer.play()
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    weak var gameViewController:GameViewController!
    
    // numbers
    let BACK1_SCROLLING_SPEED: CGFloat = 2.5
    let GROUND_SCROLLING_SPEED: CGFloat = 5.0
    var scaling = CGFloat(1.0)
    
    // counters
    var count = 0
    var limit = 60
    var powerUpTimer = 0
    var lastSpawn = 100
    var boltTime = 0

    // booleans
    var poweredUp = false
    var jumperDeath = false
    var inGame = false
    var gameStarted = false

    // background
    var back1: SKScrollingNode?
    var back2: SKScrollingNode?
    var jumpOffPad: SKSpriteNode!
    var ground: SKScrollingNode?
    var ground2: SKScrollingNode?
    
    //Mini Hack
    //TODO: Use Array
    var star: SKSpriteNode!
    var red: SKSpriteNode!
    var blue: SKSpriteNode!
    var bolt: SKSpriteNode!
    
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
    
    // music 
    var place = String()
    
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
        //println("initial setup")
        //Physics
        self.physicsWorld.gravity = CGVectorMake(CGFloat(0.0), CGFloat(-5.0))

        // Set score to 0
        currentScore = 0
        
        // Setup PowerUp Timer
        powerUpTimer = 0
        
        // Setup Difficulty
        limit = 60
        current_time = 0.0
        
        // movement initial
        distanceToMove = CGFloat(self.frame.size.width)
        moveObject = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.01 * distanceToMove))
        removeObject = SKAction.removeFromParent()
        objectMoveAndRemove = SKAction.sequence([moveObject, removeObject])
    }
    
    func setupBackground(){
        back1 = SKScrollingNode.scrollingNode("background.png", containerWidth:self.frame.size.width, containerHeight:self.frame.size.height);
        //self.setScale(2.0);
        back1!.scrollingSpeed = BACK1_SCROLLING_SPEED;
        back1!.anchorPoint = CGPointZero;
        back1!.setScale(1.0)
        self.addChild(self.back1!);
        
        // music
        playBackgroundMusic("F-777DoubleJump.mp3")
        
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
        //println("setup jumper")
        jumper = JumperNode.instance();
        jumper!.position = CGPointMake(100, CGRectGetMidY(self.frame)/1.25);
        jumper!.name = "jumper";
        jumper.setScale(0.275);
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
        
        ground = SKScrollingNode.scrollingNode("groundRock2.png", containerWidth: self.frame.size.width, containerHeight:self.frame.size.height) as SKScrollingNode;
        ground!.anchorPoint = CGPointZero;
        ground!.name = "ground"
        ground!.scrollingSpeed = GROUND_SCROLLING_SPEED;
        ground!.anchorPoint = CGPointZero;
        ground!.setScale(0.8)
        self.addChild(self.ground!)
        
        ground!.position = CGPointMake(0, -35)
        ground!.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2000, height: 115))
        ground!.physicsBody?.categoryBitMask = Constants.GROUND_BIT_MASK
        ground!.physicsBody?.contactTestBitMask = Constants.JUMPER_BIT_MASK
        ground!.physicsBody?.collisionBitMask = Constants.JUMPER_BIT_MASK
        ground!.physicsBody?.dynamic = false
        
        // Upper Ground
        ground2 = SKScrollingNode.scrollingNode("groundRock.png", containerWidth: self.frame.size.width, containerHeight:self.frame.size.height) as SKScrollingNode;
        ground2!.name = "ground"
        ground2!.scrollingSpeed = GROUND_SCROLLING_SPEED;
        ground2!.setScale(0.8)
        self.addChild(self.ground2!)
        ground2!.position = CGPointMake(0, self.frame.size.height - 25)
        ground2!.physicsBody = SKPhysicsBody(rectangleOfSize: CGSize(width: 2000, height: 1))
        ground2!.physicsBody?.categoryBitMask = Constants.GROUND_BIT_MASK
        ground2!.physicsBody?.contactTestBitMask = Constants.JUMPER_BIT_MASK
        ground2!.physicsBody?.collisionBitMask = Constants.JUMPER_BIT_MASK
        ground2!.physicsBody?.dynamic = false
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
        meteor.setScale(0.6 * size_random * scaling)
        
        // controlling meteor movements
        distanceToMove = CGFloat(self.frame.size.width + (1.0 * meteor.size.width))
        
        // randomize speed
        moveObject = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.0032 * size_random * distanceToMove))
        removeObject = SKAction.removeFromParent()
        objectMoveAndRemove = SKAction.sequence([moveObject, removeObject])
        
        
        // randomize y position (self.frame.size.height/2.0)
        meteor.position = CGPointMake(self.frame.size.width + meteor.size.width/2.0,
                                      (self.frame.size.height * 3/4 * position_random) + self.frame.size.height * 1/8)
        meteor.physicsBody = SKPhysicsBody(circleOfRadius: meteor.size.width / 2)
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
        ufo.setScale(0.6)
        
        ufo2.physicsBody?.categoryBitMask = Constants.DEADLYMETEORITE_BIT_MASK
        ufo2.setScale(0.6)
        
        // controlling meteor movements
        distanceToMove = CGFloat(self.frame.size.width + 1.0 * ufo.size.width)
        
        // randomize speed
        moveObject = SKAction.moveByX(-distanceToMove, y:0.0, duration: NSTimeInterval(0.003 * distanceToMove))
        removeObject = SKAction.removeFromParent()
        objectMoveAndRemove = SKAction.sequence([moveObject, removeObject])
        
        //ufo.anchorPoint = CGPointMake(0, 0)
        //ufo2.anchorPoint = CGPointMake(0, 0)
        
        var rotateUFO = SKAction.rotateByAngle(CGFloat(-M_PI/2.0), duration: 1.0)
        var rotateUFOForever = SKAction.repeatActionForever(rotateUFO)
        
        // randomize y position (self.frame.size.height/2.0)
       
        var yposition_random = abs((self.frame.size.height - (self.frame.size.height/2.25) - ufo.size.height * 3.2) * position_random) + ufo.size.height * 1.6
        ufo.position = CGPointMake(self.frame.size.width + ufo.size.width/2.0, yposition_random)
        //println(yposition_random)
        ufo2.position = CGPointMake(self.frame.size.width + ufo.size.width/2.0, yposition_random + self.frame.size.height/2.25)
        ufo.physicsBody = SKPhysicsBody(circleOfRadius: ufo.size.width / 2)
        ufo2.physicsBody = SKPhysicsBody(circleOfRadius: ufo2.size.width / 2)
        
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
            powerUpFile = "power_blue.png"
        }
        else if powerupNum == 1
        {
            powerUpFile = "power_red.png"
        }
        else if powerupNum == 2
        {
            powerUpFile = "star_gold.png"
        }
        else if powerupNum == 3
        {
            powerUpFile = "red_bolt.png"
        }
        
        var powerUpTexture = SKTexture(imageNamed: powerUpFile)
        
        let powerUp = SKSpriteNode(texture: powerUpTexture)
        
        powerUp.setScale(0.65)
        // set bitmask
        powerUp.physicsBody?.categoryBitMask = Constants.POWERUP_BIT_MASK
        
        // set scale
        if powerupNum == 0
        {
            powerUp.name = "blue_powerup"
            blue = powerUp
        }
        else if powerupNum == 1
        {
            powerUp.name = "red_powerup"
            red = powerUp
        }
        else if powerupNum == 2
        {
            powerUp.name = "star_gold"
            star = powerUp
        }
        else if powerupNum == 3
        {
            powerUp.name = "red_bolt"
            bolt = powerUp
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
        
        //println(powerUp)
        //meteors.append(powerUp)

        // adjust movement parameters
        powerUp.runAction(objectMoveAndRemove)
    }
    
    func spawnPowerups()
    {
        var powerup_random = CGFloat(Float(arc4random()) / Float(UINT32_MAX))
        var num = Int(powerup_random * 23)
        //println(num)
        
        if num == 0 && lastSpawn != 0
        {
            lastSpawn = 0
            spawnColorPowerUp(0)
        }
        else if num == 5 && lastSpawn != 5
        {
            lastSpawn = 5
            spawnColorPowerUp(1)
        }
        else if num == 10 && lastSpawn != 10
        {
            lastSpawn = 10
            spawnColorPowerUp(2)
        }
        else if num == 15 && lastSpawn != 15
        {
            lastSpawn = 15
            spawnColorPowerUp(3)
        }
        else if num == 20 && lastSpawn != 20
        {
            lastSpawn = 20
            spawnUFO()
        }
        //println("--\(lastSpawn)")
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
        if(
            ((contact.bodyB.node!.name! == "meteor" || contact.bodyB.node!.name! == "ufo" || contact.bodyB.node!.name! == "ground" ) && contact.bodyA.node!.name! == "jumper")
            ||
            ((contact.bodyA.node!.name! == "meteor" || contact.bodyA.node!.name! == "ufo" || contact.bodyA.node!.name! == "ground" ) && contact.bodyB.node!.name! == "jumper")
        )
        {
            //println("collision jumper")
            
            if(!jumperDeath) {
                jumperDeath = true;
                self.runAction(SKAction.playSoundFileNamed("aaa.wav", waitForCompletion: false))
                
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
            (contact.bodyA.node!.name! == "jumper" && contact.bodyB.node!.name! == "red_powerup"))
        {
            // powered up; make alien smaller
            //poweredUp = true
            jumper.texture = SKTexture(imageNamed: "Pink_Alien")
            jumper.setScale(0.225)
            jumper.physicsBody?.dynamic = true
            powerUpTimer = 200
            red.removeFromParent()
        }
        
        if ((contact.bodyA.node!.name! == "blue_powerup" && contact.bodyB.node!.name! == "jumper")
            ||
            (contact.bodyA.node!.name! == "jumper" && contact.bodyB.node!.name! == "blue_powerup"))
        {
            // powered up; make alien bigger
            //poweredUp = true
            jumper.texture = SKTexture(imageNamed: "Blue_Alien")
            jumper.setScale(0.35)
            jumper.physicsBody?.dynamic = true
            powerUpTimer = 200
            blue.removeFromParent()
        }
        
        if ((contact.bodyA.node!.name! == "star_gold" && contact.bodyB.node!.name! == "jumper")
            ||
            (contact.bodyA.node!.name! == "jumper" && contact.bodyB.node!.name! == "star_gold"))
        {
            currentScore += 300
            star.removeFromParent()
        }
        
        if ((contact.bodyA.node!.name! == "red_bolt" && contact.bodyB.node!.name! == "jumper")
            ||
            (contact.bodyA.node!.name! == "jumper" && contact.bodyB.node!.name! == "red_bolt"))
        {
            scaling = 0.5
            boltTime = 200
            bolt.removeFromParent()
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
        //println(scaling)
        /* Called before each frame is rendered */
        // spawn meteors every 5 frames
        //println(meteors)
        if (inGame && gameStarted){
            updateScore()
        }
        
        if(!jumperDeath && gameStarted) {
            back1!.update(currentTime);
            ground!.update(currentTime);
            ground2!.update(currentTime);
            jumper!.update(currentTime);

            if current_time == 0.0{
                current_time = currentTime
            }
            diff_sec = Int((currentTime - current_time)/1.5)
            
            println(diff_sec)
        
            //println("limit: \(limit)  count: \(count)")
            count++
            if (count == limit || count > limit){
                spawnMeteorites()
                spawnPowerups()
                count = 0
            }
            //println(powerUpTimer)
            
            if (boltTime > 0)
            {
                boltTime--
            }
            else
            {
                scaling = 1.0
            }
            
            if (powerUpTimer > 0)
            {
                powerUpTimer--
            }
            else
            {
                poweredUp = false
                //jumper.texture = SKTexture(imageNamed: "Alien")
                //jumper.physicsBody?.dynamic = true
                jumper.setScale(0.275)
            }
        
            jumper.position.x = self.frame.size.width * 0.15
        
            //Change number of spawn meteorites base on time
            if diff_sec < 5
            {
                limit = 24
            }
            else if diff_sec < 10
            {
                limit = 22
            }
            else if diff_sec < 15
            {
                limit = 20
            }
            else if diff_sec < 20
            {
                limit = 18
            }
            else if diff_sec < 25
            {
                limit = 16
            }
            else if diff_sec < 30
            {
                limit = 14
            }
            else if diff_sec < 35
            {
                limit = 12
            }
            else if diff_sec < 40
            {
                limit = 10
            }
            else if diff_sec < 45
            {
                limit = 8
            }
            else if diff_sec < 50
            {
                limit = 6
            }
            else
            {
                limit = 4
            }
        }
    }
}
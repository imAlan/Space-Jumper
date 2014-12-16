//
//  GameViewController.swift
//  Space Jumper
//
//  Created by Alan Chen on 11/20/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import UIKit
import SpriteKit
import QuartzCore

extension SKNode {
    class func unarchiveFromFile(file : NSString) -> SKNode? {
        if let path = NSBundle.mainBundle().pathForResource(file, ofType: "sks") {
            var sceneData = NSData(contentsOfFile: path, options: .DataReadingMappedIfSafe, error: nil)!
            var archiver = NSKeyedUnarchiver(forReadingWithData: sceneData)
            
            archiver.setClass(self.classForKeyedUnarchiver(), forClassName: "SKScene")
            let scene = archiver.decodeObjectForKey(NSKeyedArchiveRootObjectKey) as GameScene
            archiver.finishDecoding()
            return scene
        } else {
            return nil
        }
    }
}

class GameViewController: UIViewController, SceneDelegate {
    //@IBOutlet weak var scoreLabel: UILabel!
    //@IBOutlet weak var skView:SKView!
    //@IBOutlet weak var scene:GameScene!

    @IBOutlet
    var menuView: UIView!
    @IBOutlet
    var mainMenuImage: UIImageView!
    @IBOutlet
    var gameOverView: UIView!
    @IBOutlet
    var gameOverImage: UIImageView!
    
    @IBOutlet var BestScoreLabel: UILabel!
    @IBOutlet var ScoreLabel: UILabel!
    var scene: GameScene?
    var flash: UIView?
    
    override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!) {
        //scene = GameScene(size: self.view.bounds.size)
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    convenience override init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        
        // make scene
        let skView = view as SKView
        
        //Debugging Code, shows collision box
        //skView.showsNodeCount = true
        //skView.showsFPS = true
        //skView.showsPhysics = true
        
        self.scene = GameScene(size: skView.bounds.size)
        self.scene!.scaleMode = .AspectFill
        self.scene!.sceneDelegate = self
        
        // present
        self.gameOverView.alpha = 0
        self.gameOverView.transform = CGAffineTransformMakeScale(0.9, 0.9)
        
        skView.presentScene(scene)
    }
    
    func eventStart(){
        UIView.animateWithDuration(0.2, animations: {
            self.gameOverView.alpha = 0
            self.gameOverView.transform = CGAffineTransformMakeScale(0.8, 0.8)
            self.flash!.alpha = 0
            self.menuView.alpha = 1
            }, completion: {
                (Bool) -> Void in self.flash!.removeFromSuperview()
        });
    }
    
    func eventPlay(){
        UIView.animateWithDuration(0.5, animations: {
            self.menuView.alpha = 0
        });
    }
    
    func eventJumperDeath() {
        // flash the screen when you die
        self.flash = UIView(frame: self.view.frame)
        self.flash!.backgroundColor = UIColor.whiteColor()
        self.flash!.alpha = 0.9
        
        self.shakeFrame()
        //println(Score.bestScore())
        UIView.animateWithDuration(0.6, delay: 0.0, options: UIViewAnimationOptions.CurveEaseIn, animations: {
            // Display game over
            self.flash!.alpha = 0.4
            self.gameOverView.alpha = 1
            self.gameOverView.transform = CGAffineTransformMakeScale(1, 1)
            
            // Set scores
            //self.currentScore.text = NSString(format: "%li", self.scene!.score)
            self.ScoreLabel.text = NSString(format: "Score: %li", instance.current_score)
            self.BestScoreLabel.text = NSString(format: "Best Score: %li", score.bestScore())
            },
            completion: {(Bool) -> Void in self.flash!.userInteractionEnabled = false})
    }

    func shakeFrame() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        let fromPoint = CGPointMake(self.view.center.x - 4.0, self.view.center.y)
        let toPoint = CGPointMake(self.view.center.x + 4.0, self.view.center.y)
        
        let fromValue = NSValue(CGPoint: fromPoint)
        let toValue = NSValue(CGPoint: toPoint)
        animation.fromValue = fromValue
        animation.toValue = toValue
        self.view.layer.addAnimation(animation, forKey: "position")
    }
    
}

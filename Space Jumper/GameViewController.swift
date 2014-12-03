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
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var skView:SKView!
    @IBOutlet weak var scene:GameScene!

    @IBOutlet var gameView: UIView!
    @IBOutlet var menuView: UIView!
    @IBOutlet var mainMenuImage: UIImageView!
    @IBOutlet var gameOverView: UIView!
    @IBOutlet var gameOverImage: UIImageView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //if let scene = GameScene.unarchiveFromFile("GameScene") as? GameScene {
            // Configure the view.
        //    skView = self.view as SKView
        //    skView.showsFPS = true
        //    skView.showsNodeCount = true
            
        //    scene.gameViewController = self
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
        //    skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
        //    scene.scaleMode = .AspectFill
            
        //    skView.presentScene(scene)
            
        //}
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Slide)
        
        // make scene
        self.scene = GameScene(size: gameView.bounds.size)
        self.scene!.scaleMode = .AspectFill
        self.scene!.sceneDelegate = self
        
        // present
        self.gameOverView.alpha = 0
        self.gameOverView.transform = CGAffineTransformMakeScale(0.9, 0.9)
        
        self.gameView.presentScene(scene)
        
        // insert protocol functions
        // setup view functions
        // nibBundle
        // setup image conditionals
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> Int {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return Int(UIInterfaceOrientationMask.AllButUpsideDown.rawValue)
        } else {
            return Int(UIInterfaceOrientationMask.All.rawValue)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func gameOver(sender: AnyObject) {
        println("GameSceneToGameOver")
        self.dismissViewControllerAnimated(true, completion: nil)
        //self.navigationController?.popToRootViewControllerAnimated(true)
    }
}

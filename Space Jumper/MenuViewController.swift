//
//  MenuViewController.swift
//  Space Jumper
//
//  Created by George on 11/23/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var GameOverView: UIView!
    @IBOutlet weak var PlayButton: UIButton!
    var scoreLabelText:String?
    var gameOver:Bool = false
    
    @IBAction func play(sender: AnyObject) {
        //self.GameOverView.hidden = false
        self.PlayButton.hidden = true
        scoreLabel.text = String(instance.score)
        //var patternImage:UIImage = UIImage(named: "Space3.png")!
        //self.view.backgroundColor = UIColor(patternImage: patternImage)
    }
 
    @IBAction func playAgain(sender: AnyObject) {
        self.play(sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        println(instance.score)
        
        self.GameOverView.hidden = true
        self.PlayButton.hidden = false
        var patternImage:UIImage = UIImage(named: "Space5.png")!
        self.view.backgroundColor = UIColor(patternImage: patternImage)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

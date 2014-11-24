//
//  GameOverViewController.swift
//  Space Jumper
//
//  Created by George on 11/22/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import UIKit

class GameOverViewController: UIViewController {
    @IBOutlet weak var scoreLabel: UILabel!
    var scoreLabelText:String?
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        scoreLabel.text = scoreLabelText
        println("didsegue")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

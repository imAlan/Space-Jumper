//
//  MenuViewController.swift
//  Space Jumper
//
//  Created by George on 11/23/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        var patternImage:UIImage = UIImage(named: "Space5.png")!
        self.view.backgroundColor = UIColor(patternImage: patternImage)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

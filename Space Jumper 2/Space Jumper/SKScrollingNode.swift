//
//  SKScrollingNode.swift
//  Space Jumper
//
//  Created by Kong Huang on 12/3/14.
//  Copyright (c) 2014 Urban Games. All rights reserved.
//
// SKScrollingNode credits to Frederick Siu

import Foundation
import SpriteKit

class SKScrollingNode: SKSpriteNode {
    
    var scrollingSpeed: CGFloat = 0.0;
    
    class func scrollingNode(imageNamed: String, containerWidth: CGFloat, containerHeight: CGFloat) -> SKScrollingNode {
        let image = UIImage(named: imageNamed)!;
        
        let result = SKScrollingNode(color: UIColor.clearColor(), size: CGSizeMake(CGFloat(containerWidth), CGFloat(containerHeight)));
        result.scrollingSpeed = 1.0;
        
        var total:CGFloat = 0.0;
        while(total < CGFloat(containerWidth) + image.size.width) {
            let child = SKSpriteNode(imageNamed: imageNamed);
            child.anchorPoint = CGPointZero;
            child.position = CGPointMake(total, 0);
            result.addChild(child);
            total+=child.size.width;
        }
        return result;
    }
    
    func update(currentTime: NSTimeInterval) {
        let runBlock: () -> Void = {
            for child in self.children as [SKSpriteNode] {
                child.position = CGPointMake(child.position.x-CGFloat(self.scrollingSpeed), child.position.y);
                if(child.position.x <= -child.size.width) {
                    var delta = child.position.x + child.size.width;
                    child.position = CGPointMake(CGFloat(child.size.width * CGFloat(self.children.count-1)) + delta, child.position.y);
                }
            }
        }
        runBlock();
    }
}
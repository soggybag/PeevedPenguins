//
//  MSPhysicsNode.swift
//  Make School
//
//  Created by Martin Walsh on 15/03/2016.
//  Copyright © 2016 Martin Walsh. All rights reserved.
//


import SpriteKit

class MSReferenceNode: SKReferenceNode {
    
    /* Avatar node connection */
    var avatar: SKSpriteNode!
    
    override func didLoadReferenceNode(node: SKNode?) {
        
        /* Set reference to avatar node */
        avatar = childNodeWithName("//avatar") as! SKSpriteNode
    }
}


/*
import SpriteKit

class MSReferenceNode: SKReferenceNode {
    
    /* Avatar node connection */
    var avatar: SKSpriteNode!
    
    override init(fileNamed fileName: String?) {
        super.init(fileNamed: fileName)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
 
    override func didLoadReferenceNode(node: SKNode?) {
        
        /* Set reference to avatar node */
        avatar = childNodeWithName("//avatar") as! SKSpriteNode
    }
}
 
 */
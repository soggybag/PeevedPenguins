//
//  GameScene.swift
//  PeevedPenguins
//
//  Created by mitchell hudson on 4/22/16.
//  Copyright (c) 2016 mitchell hudson. All rights reserved.
//

import SpriteKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var currentLevel: Int = 1
    
    /* Game object connections */
    var catapultArm: SKSpriteNode!
    var catapult: SKSpriteNode!
    var cantileverNode: SKSpriteNode!
    var touchNode: SKSpriteNode!
    var penguinJoint: SKPhysicsJointPin?
    
    /* Physics helpers */
    var touchJoint: SKPhysicsJointSpring?
    
    var levelNode: SKNode!
    /* Camera helpers */
    var cameraTarget: SKNode?
    /* UI Connections */
    var buttonRestart: MSButtonNode!
    
    
    
    
    
    
    
    
    static func gameSceneLevel(level: Int) -> GameScene? {
        let scene = GameScene(fileNamed: "GameScene")
        scene?.currentLevel = level
        
        return scene
    }
    
    
    
    
    
    
    
    // MARK: Load Levels 
    
    func loadLevel(level: Int) {
        /* Load Level 1 */
        // TODO: Investigate other ways to load a new level...
        
        // TODO: Remove children from levelNode
        
        let resourcePath = NSBundle.mainBundle().pathForResource("Level\(level)", ofType: "sks")
        let newLevel = SKReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
        levelNode.addChild(newLevel)
    }
    
    
    
    
    
    
    
    
    
    // MARK: - Did move to view
    
    override func didMoveToView(view: SKView) {
        /* Set physics contact delegate */
        physicsWorld.contactDelegate = self
        
        catapultArm = childNodeWithName("catapultArm") as! SKSpriteNode
        catapult = childNodeWithName("catapult") as! SKSpriteNode
        cantileverNode = childNodeWithName("cantileverNode") as! SKSpriteNode
        touchNode = childNodeWithName("touchNode") as! SKSpriteNode
        
        levelNode = childNodeWithName("//levelNode")
        
        /* Set UI connections */
        
        buttonRestart = childNodeWithName("//buttonRestart") as! MSButtonNode
        
        /* Setup restart button selection handler */
        buttonRestart.selectedHandler = {
            
            
            // ********************************************
            // TODO: Replace this with code that loads a new level
            
            // TODO: Remove children from levelNode
            self.levelNode.removeAllChildren()
            
            // TODO: Load new level
            self.loadLevel(self.currentLevel)
            
            self.reset() // TODO: Fix reset...
            
            
            
            // ---------------------------------------
            /* Grab reference to our SpriteKit view */
            /*let skView = self.view as SKView!
            
            /* Load Game scene */
            let scene = GameScene.gameSceneLevel(1)!
            
            /* Ensure correct aspect mode */
            scene.scaleMode = .AspectFill
            
            /* Show debug */
            skView.showsPhysics = true
            skView.showsDrawCount = true
            skView.showsFPS = false
            
            /* Restart game scene */
            skView.presentScene(scene) */
            // --------------------------------------
            // *********************************************
        }
        
        
        
        
        /* Load Level 1 */
        loadLevel(currentLevel)
        

        
        /* Create catapult arm physics body of type alpha */
        let catapultArmBody = SKPhysicsBody(texture: catapultArm!.texture!, size: catapultArm.size)
        
        /* Set mass, needs to be heavy enough to hit the penguin with solid force */
        catapultArmBody.mass = 0.5
        
        /* No need for gravity otherwise the arm will fall over */
        catapultArmBody.affectedByGravity = false
        
        /* Improves physics collision handling of fast moving objects */
        catapultArmBody.usesPreciseCollisionDetection = true
        
        /* Assign the physics body to the catapult arm */
        catapultArm.physicsBody = catapultArmBody
        
        /* Pin joint catapult and catapult arm */
        let catapultPinJoint = SKPhysicsJointPin.jointWithBodyA(
            catapult.physicsBody!,
            bodyB: catapultArm.physicsBody!,
            anchor: CGPoint(x:220 ,y:105))
        
        physicsWorld.addJoint(catapultPinJoint)
        
        /* Spring joint catapult arm and cantilever node */
        let catapultSpringJoint = SKPhysicsJointSpring.jointWithBodyA(
            catapultArm.physicsBody!,
            bodyB: cantileverNode.physicsBody!,
            anchorA: catapultArm.position + CGPoint(x:15, y:30),
            anchorB: cantileverNode.position)
        
        catapultSpringJoint.frequency = 1.5
        
        physicsWorld.addJoint(catapultSpringJoint)
    }
    
    
    
    
    
    
    
    
    
    
    // MARK: - Touch events
    
    var startDrag: CGPoint = CGPointZero
    var penguin: SKSpriteNode!
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch begins */
        
        /* There will only be one touch as multi touch is not enabled by default */
        for touch in touches {
            
            /* Grab scene position of touch */
            let location    = touch.locationInNode(self)
            
            /* Get node reference if we're touching a node */
            let touchedNode = nodeAtPoint(location) // as! SKSpriteNode
            
            /* Is it the catapult arm? */
            if touchedNode.name == "catapultArm" {
                /* Reset touch node position */
                touchNode.position = location
                startDrag = location // *** Get the starting point of the drag
                
                /* Spring joint touch node and catapult arm */
                touchJoint = SKPhysicsJointSpring.jointWithBodyA(touchNode.physicsBody!, bodyB: catapultArm.physicsBody!, anchorA: location, anchorB: location)
                
                physicsWorld.addJoint(touchJoint!)
                
                
                /* Add a new penguin to the scene */
                let resourcePath = NSBundle.mainBundle().pathForResource("Penguin", ofType: "sks")
                let penguinRef = MSReferenceNode(URL: NSURL (fileURLWithPath: resourcePath!))
                // let penguin = MSReferenceNode(fileNamed: "Penguin")
                addChild(penguinRef)
                
                penguin = penguinRef.avatar // *** get penguin
                
                /* Position penguin in the catapult bucket area */
                penguin.position = catapultArm.position + CGPoint(x: 20, y: 50)
                
                /* Improves physics collision handling of fast moving objects */
                penguin.physicsBody?.usesPreciseCollisionDetection = true
                
                /* Setup pin joint between penguin and catapult arm */
                penguinJoint = SKPhysicsJointPin.jointWithBodyA(catapultArm.physicsBody!, bodyB: penguin.physicsBody!, anchor: penguin.position)
                physicsWorld.addJoint(penguinJoint!)
                
                /* Remove any camera actions */
                camera?.removeAllActions()
                
                /* Set camera to follow penguin */
                cameraTarget = penguin
                
            }
        }
    }
    
    
    
    
    
    
    
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch moved */
        
        /* There will only be one touch as multi touch is not enabled by default */
        for touch in touches {
            
            /* Grab scene position of touch and update touchNode position */
            let location       = touch.locationInNode(self)
            touchNode.position = location
            
        }
    }
    
    
    
    
    
    
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        /* Called when a touch ended */
        
        // *** Get the end point of the drag 
        let touch = touches.first
        let endDrag = touch!.locationInNode(self)
        let vector = CGVector(dx: (startDrag.x - endDrag.x) * 0.1 , dy: (startDrag.y - endDrag.y) * 0.1)
        
        if penguin != nil {
            penguin.physicsBody?.applyImpulse(vector) // *** Apply an impulse
        }
        
        /* Let it fly!, remove joints used in catapult launch */
        if let touchJoint = touchJoint { physicsWorld.removeJoint(touchJoint) }
        
        if let penguinJoint = penguinJoint { physicsWorld.removeJoint(penguinJoint) }
    }
    
    
    
    
    
    
    
    
    
    // MARK: - Update
    
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        /* Check we have a valid camera target to follow */
        if let cameraTarget = cameraTarget {
            
            /* Set camera position to follow target horizontally, keep vertical locked */
            camera?.position = CGPoint(x:cameraTarget.position.x, y:camera!.position.y)
            /* Clamp camera scrolling to our visible scene area only */
            camera?.position.x.clamp(283, 677)
            
            
            /* Check penguin has come to rest */
            if cameraTarget.physicsBody?.joints.count == 0 && cameraTarget.physicsBody?.velocity.length() < 0.18 {
                cameraTarget.removeFromParent()
                
                
                reset()
            }
            
            
            
        }
    }
    
    
    
    
    
    
    func reset() {
        /* Reset catapult arm */
        catapultArm.physicsBody?.velocity = CGVector(dx:0, dy:0)
        catapultArm.physicsBody?.angularVelocity = 0
        catapultArm.zRotation = 0
        
        /* Reset camera */
        let cameraReset = SKAction.moveTo(CGPoint(x:284, y:camera!.position.y), duration: 1.5)
        let cameraDelay = SKAction.waitForDuration(0.5)
        let cameraSequence = SKAction.sequence([cameraDelay, cameraReset])
        
        camera?.runAction(cameraSequence)
    }
    
    
    
    
    
    
    
    
    // MARK: - Physics Delegate
    
    func didBeginContact(contact: SKPhysicsContact) {
        /* Physics contact delegate implementation */
        
        
        // print("Contact!!!!!! \(contact.bodyA.categoryBitMask) \(contact.bodyB.categoryBitMask)")
        
        /* Get references to the bodies involved in the collision */
        let contactA:SKPhysicsBody = contact.bodyA
        let contactB:SKPhysicsBody = contact.bodyB
        
        /* Get references to the physics body parent SKSpriteNode */
        let nodeA = contactA.node as! SKSpriteNode
        let nodeB = contactB.node as! SKSpriteNode
        
        /* Check if either physics bodies was a seal */
        if contactA.categoryBitMask == 2 || contactB.categoryBitMask == 2 {
            
            /* Was the collision more than a gentle nudge? */
            if contact.collisionImpulse > 2.0 {
                
                /* Kill Seal(s) */
                if contactA.categoryBitMask == 2 { dieSeal(nodeA) }
                if contactB.categoryBitMask == 2 { dieSeal(nodeB) }
            }
            
        }
    }
    
    
    
    
    
    
    
    // MARK: - Helper methods 
    
    func dieSeal(node: SKNode) {
        /* Seal death*/
        
        /* Load our particle effect */
        let particles = SKEmitterNode(fileNamed: "SealExplosion")!
        
        /* Convert node location (currently inside Level 1, to scene space) */
        particles.position = convertPoint(node.position, fromNode: node)
        
        /* Restrict total particles to reduce runtime of particle */
        particles.numParticlesToEmit = 25
        
        /* Add particles to scene */
        addChild(particles)
        
        /* Play SFX */
        let sealSFX = SKAction.playSoundFileNamed("sfx_seal", waitForCompletion: false)
        self.runAction(sealSFX)
        
        /* Create our hero death action */
        let sealDeath = SKAction.runBlock({
            /* Remove seal node from scene */
            node.removeFromParent()
        })
        
        self.runAction(sealDeath)
        
    }
    
    
    
}
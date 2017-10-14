//
//  GameScene.swift
//  Flappy Bird
//
//  Created by André Brilho on 16/04/16.
//  Copyright (c) 2016 classroomM. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    
    static let Ghost : UInt32 = 0x1 << 1
    static let Ground : UInt32 = 0x1 << 2
    static let Wall : UInt32 = 0x1 << 3
    static let Score : UInt32 = 0x1 << 4
    
}




class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var Ground = SKSpriteNode()
    var Ghost = SKSpriteNode()
    var moveAndRemove = SKAction()
    var gameStarted = Bool()
    var score = Int()
    let scoreLbl = SKLabelNode()
    var died = Bool()
    var restartbtn = SKSpriteNode()
    
    
    func restarScene(){
    
        self.removeAllChildren()
        self.removeAllActions()
        died = false
        gameStarted = false
        score = 0

        createScene()
    

        
    }
    
    func createScene(){
    
        
       
        
        self.physicsWorld.contactDelegate = self
        
        for i in 0..<2 {
            let background = SKSpriteNode(imageNamed: "Background")
            background.anchorPoint = CGPointZero
            background.position = CGPointMake(CGFloat(i) * self.frame.width, 0)
            background.name = "background"
            background.size =  CGSize(width: self.frame.width, height: self.frame.height * 1.3)
            self.addChild(background)
        
        }
        
        scoreLbl.position = CGPoint(x: self.frame.width / 2 , y: self.frame.height / 2 + self.frame.height / 2.5)
        scoreLbl.text = "\(score)"
        scoreLbl.zPosition = 5
        scoreLbl.fontName = "04b_19"
        scoreLbl.fontSize = 50
        self.addChild(scoreLbl)
        
        //Chao
        
        Ground = SKSpriteNode(imageNamed: "Ground")
        Ground.setScale(0.5)
        Ground.position = CGPoint(x: self.frame.width / 2, y: 0 + Ground.frame.height / 2)
        
        
        Ground.physicsBody = SKPhysicsBody(rectangleOfSize: Ground.size)
        Ground.physicsBody?.categoryBitMask = PhysicsCategory.Ground
        Ground.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        Ground.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        Ground.physicsBody?.affectedByGravity = false
        Ground.physicsBody?.dynamic = false
        
        Ground.zPosition = 3
        
        self.addChild(Ground)
        
        
        //Ghost
        
        Ghost = SKSpriteNode(imageNamed: "Ghost")
        Ghost.size = CGSize(width: 60, height: 70)
        Ghost.position = CGPoint(x: self.frame.width / 2 - Ghost.frame.width, y: self.frame.height / 2)
        
        
        Ghost.physicsBody = SKPhysicsBody(circleOfRadius: Ghost.frame.height / 2)
        Ghost.physicsBody?.categoryBitMask = PhysicsCategory.Ghost
        Ghost.physicsBody?.collisionBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall
        Ghost.physicsBody?.contactTestBitMask = PhysicsCategory.Ground | PhysicsCategory.Wall | PhysicsCategory.Score
        Ghost.physicsBody?.affectedByGravity = false
        Ghost.physicsBody?.dynamic = true
        
        Ghost.zPosition = 2
        
        self.addChild(Ghost)
        
        

    
    }

    
    override func didMoveToView(view: SKView) {

        createScene()
        
    }
    
    func createBTN(){
    
        restartbtn = SKSpriteNode(imageNamed: "RestartBtn")
        restartbtn.size = CGSizeMake(200, 100)
        restartbtn.position = CGPoint(x: self.frame.width / 2, y: self.frame.height / 2)
        restartbtn.setScale(0)
        restartbtn.zPosition = 6
        self.addChild(restartbtn)
                restartbtn.runAction(SKAction.scaleTo(1.0, duration: 0.3))
        
    }
    
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */

        if gameStarted == false {
            
            gameStarted = true
        
            Ghost.physicsBody?.affectedByGravity = true
            
            let spawn = SKAction.runBlock({
                () in
                
                self.CriarParedes()
                
            })
            
            let delay = SKAction.waitForDuration(2.0)
            let spanDelay = SKAction.sequence([spawn, delay])
            let spanDelayForever = SKAction.repeatActionForever(spanDelay)
            self.runAction(spanDelayForever)
            
            let distance = CGFloat(self.frame.width + 20)
            let movePipes = SKAction.moveByX(-distance - 50, y: 0, duration: NSTimeInterval(0.008 * distance))
            let removePipes = SKAction.removeFromParent()
            
            moveAndRemove = SKAction.sequence([movePipes, removePipes])
            
            Ghost.physicsBody?.velocity = CGVectorMake(0, 0)
            Ghost.physicsBody?.applyImpulse(CGVectorMake(0, 90))
            
        } else {
        
            if died == true {
            
            
            
            } else {
      
                
                Ghost.physicsBody?.velocity = CGVectorMake(0, 0)
                Ghost.physicsBody?.applyImpulse(CGVectorMake(0, 90))
                
                
            }
            
      
        
        }
        
        for touch in touches{
        
            let location = touch.locationInNode(self)
            
            if died == true {
            
                if restartbtn.containsPoint(location){
                restarScene()
                }
                
            }
        
        }
        
        
    }
    
    
    func didBeginContact(contact: SKPhysicsContact) {
        
        let firstBody = contact.bodyA
        let secontBody = contact.bodyB
        
        if firstBody.categoryBitMask == PhysicsCategory.Score && secontBody.categoryBitMask == PhysicsCategory.Ghost ||  firstBody.categoryBitMask == PhysicsCategory.Ghost && secontBody.categoryBitMask == PhysicsCategory.Score{
        
        score++
        //    print(score)
        scoreLbl.text = "\(score)"
        
        }
        
       else if firstBody.categoryBitMask == PhysicsCategory.Ghost && secontBody.categoryBitMask == PhysicsCategory.Wall ||           firstBody.categoryBitMask == PhysicsCategory.Wall && secontBody.categoryBitMask == PhysicsCategory.Ghost {
        

            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, ErrorType) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
        
            if died == false {
                died = true
                createBTN()
            }
            

        }
        
        else if firstBody.categoryBitMask == PhysicsCategory.Ghost && secontBody.categoryBitMask == PhysicsCategory.Ground ||           firstBody.categoryBitMask == PhysicsCategory.Ground && secontBody.categoryBitMask == PhysicsCategory.Ghost {
            
            
            
            enumerateChildNodesWithName("wallPair", usingBlock: ({
                (node, ErrorType) in
                
                node.speed = 0
                self.removeAllActions()
                
            }))
            
            if died == false {
                died = true
                createBTN()
            }
            
            
        }
        
        
    }
    
    
    func CriarParedes(){
    
        let ScoreNode = SKSpriteNode()
        
        ScoreNode.size = CGSize(width: 1, height: 200)
        ScoreNode.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2)
        ScoreNode.physicsBody = SKPhysicsBody(rectangleOfSize: ScoreNode.size)
        ScoreNode.physicsBody?.affectedByGravity = false
        ScoreNode.physicsBody?.dynamic = false
        ScoreNode.physicsBody?.categoryBitMask = PhysicsCategory.Score
        ScoreNode.physicsBody?.collisionBitMask = 0
        ScoreNode.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
      //  ScoreNode.color = SKColor.blueColor()
        
        
        let wallPair = SKNode()
        wallPair.name = "wallPair"
        
        let topWall = SKSpriteNode(imageNamed: "Wall")
        let btmWall = SKSpriteNode(imageNamed: "Wall")
        
        topWall.position = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 + 350)
        btmWall.position  = CGPoint(x: self.frame.width + 25, y: self.frame.height / 2 - 350)
        
        topWall.setScale(0.5)
        btmWall.setScale(0.5)
        
        
        topWall.physicsBody = SKPhysicsBody(rectangleOfSize:  topWall.size)
        topWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        topWall.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        topWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        topWall.physicsBody?.dynamic = false
        topWall.physicsBody?.affectedByGravity = false
        
        btmWall.physicsBody = SKPhysicsBody(rectangleOfSize:  btmWall.size)
        btmWall.physicsBody?.categoryBitMask = PhysicsCategory.Wall
        btmWall.physicsBody?.collisionBitMask = PhysicsCategory.Ghost
        btmWall.physicsBody?.contactTestBitMask = PhysicsCategory.Ghost
        btmWall.physicsBody?.dynamic = false
        btmWall.physicsBody?.affectedByGravity = false
        
        topWall.zRotation = CGFloat(M_PI)
        
        wallPair.addChild(topWall)
        wallPair.addChild(btmWall)
        
        wallPair.zPosition = 1
        
        
        let randomPosition = CGFloat.random(min: -200, max: 200)
        wallPair.position.y = wallPair.position.y + randomPosition
        
        wallPair.addChild(ScoreNode)
        wallPair.runAction(moveAndRemove)
        
        self.addChild(wallPair)
        
    }
    
    
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
        if gameStarted == true {
            if died == false {
                enumerateChildNodesWithName("background", usingBlock: ({
                    (node, error) in
                    
                    var bg = node as! SKSpriteNode
                    
                    bg.position = CGPoint(x: bg.position.x - 2, y: bg.position.y)
                    
                    if bg.position.x <= -bg.size.width {
                        bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y)
                    
                    }
                    
                }))
            }
        }
        
    }
}

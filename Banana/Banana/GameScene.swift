//
//  GameScene.swift
//  Banana
//
//  Created by Mac Bellingrath on 11/28/15.
//  Copyright (c) 2015 Mac Bellingrath. All rights reserved.
//

import SpriteKit
import AVFoundation

let BananaCategoryName = "banana"
let PaddleCategoryName = "paddle"
let BlockCategoryName = "brick"
let BlockNodeCategoryName = "blockNode"

let BallCategory   : UInt32 = 0x1 << 0 // 00000000000000000000000000000001
let BottomCategory : UInt32 = 0x1 << 1 // 00000000000000000000000000000010
let BlockCategory  : UInt32 = 0x1 << 2 // 00000000000000000000000000000100
let PaddleCategory : UInt32 = 0x1 << 3 // 00000000000000000000000000001000


class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {
    
    
    var focusOnPaddle = false
    var banana: SKSpriteNode?
    var players: [AVAudioPlayer] = []
    var currentlyplayingSound = false
    
    
    override func didMoveToView(view: SKView) {
        super.didMoveToView(view)
        /* Setup your scene here */
        
        let borderBody = SKPhysicsBody(edgeLoopFromRect: self.frame)
       
        borderBody.friction = 0
        borderBody.restitution = 1
  
        
        self.physicsBody = borderBody
        
        self.physicsWorld.gravity = CGVector(dx: 0.0, dy: 0.0)
        
        physicsWorld.contactDelegate = self
        
        banana = SKSpriteNode(texture: SKTexture(imageNamed: BananaCategoryName), size: CGSize(width: 100, height: 100))
        guard let b = banana else { return }

       b.position = view.center
        b.physicsBody = SKPhysicsBody(circleOfRadius: banana!.size.width / 2.0)

        b.physicsBody?.allowsRotation = false
        b.physicsBody?.friction = 0
        b.physicsBody?.restitution = 1
        b.physicsBody?.linearDamping = 0
        b.physicsBody?.angularDamping = 0
        
        

        
        self.addChild(b)
        
        b.physicsBody?.applyImpulse(CGVectorMake(100, -100))
        
        
        
        let bottomRect = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 1)
        let bottom = SKNode()
        bottom.physicsBody = SKPhysicsBody(edgeLoopFromRect: bottomRect)
        addChild(bottom)
        
        guard let paddle = childNodeWithName(PaddleCategoryName) as? SKSpriteNode else { return }
        
        bottom.physicsBody?.categoryBitMask = BottomCategory
        banana?.physicsBody?.categoryBitMask = BallCategory
        paddle.physicsBody?.categoryBitMask = PaddleCategory
        
        banana?.physicsBody?.contactTestBitMask = BottomCategory
        
        // 1. Store some useful constants
        let numberOfBlocks = 5
        
        
        let blockWidth = SKSpriteNode(imageNamed: "brick").size.width
            let totalBlocksWidth = blockWidth * CGFloat(numberOfBlocks)
            
            let padding: CGFloat = 10.0
            let totalPadding = padding * CGFloat(numberOfBlocks - 1)
            
            // 2. Calculate the xOffset
            let xOffset = (CGRectGetWidth(frame) - totalBlocksWidth - totalPadding) / 2
            
            // 3. Create the blocks and add them to the scene
            for i in 0..<numberOfBlocks {
                
                let block = SKSpriteNode(imageNamed: "brick")
                
                block.position = CGPointMake(xOffset + CGFloat(CGFloat(i) + 0.5)*blockWidth + CGFloat(i-1)*padding, CGRectGetHeight(frame) * 0.8)
                block.physicsBody = SKPhysicsBody(rectangleOfSize: block.frame.size)
                block.physicsBody?.allowsRotation = false
                block.physicsBody?.dynamic = false
                block.physicsBody?.friction = 0.0
                block.physicsBody?.affectedByGravity = false
                block.name = BlockCategoryName
                block.physicsBody?.categoryBitMask = BlockCategory
                addChild(block)
                
            }

        
        banana?.physicsBody?.contactTestBitMask = BottomCategory | BlockCategory
        
        
        
    }
    
    
    // Persist the initial touch position of the remote
    var touchPositionX: CGFloat = 0.0
    var touchPositionY: CGFloat = 0.0
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            touchPositionX = touch.locationInNode(self).x
            touchPositionY = touch.locationInNode(self).y
        }
    }
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
        for touch in touches {
            
            guard let paddle = self.childNodeWithName("paddle") else { return }
            let location = touch.locationInNode(self)
            
            if touchPositionX != 0.0 && touchPositionY != 0.0 {
                
                // Calculate the movement on the remote
                let deltaX = touchPositionX - location.x
                let deltaY = touchPositionY - location.y
                
                // Calculate the new Sprite position
                var x = paddle.position.x - deltaX
//                var y = paddle.position.y - deltaY
                var y:CGFloat = 50
                
                // Check if the sprite will leave the screen
                if x < 0 {
                    x = 0
                } else if x > self.frame.width {
                    x = self.frame.width
                }
                if y < 0 {
                    y = 0
                } else if y > self.frame.height {
                    y = self.frame.height
                }
                
                // Move the sprite
                paddle.position = CGPoint(x: x, y: y)
                
            }
            // Persist latest touch position
            touchPositionY = location.y
            touchPositionX = location.x
        }
        
    }
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        focusOnPaddle = false
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if let banana = self.childNodeWithName(BananaCategoryName) {
        
        let maxSpeed: CGFloat = 1000.0
        let speed = sqrt(banana.physicsBody!.velocity.dx * banana.physicsBody!.velocity.dx + banana.physicsBody!.velocity.dy * banana.physicsBody!.velocity.dy)
        
        if speed > maxSpeed {
            banana.physicsBody!.linearDamping = 0.4
        }
        else {
            banana.physicsBody!.linearDamping = 0.0
           }
        }
    }
    
    func didBeginContact(contact: SKPhysicsContact) {
        // 1. Create local variables for two physics bodies
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        // 2. Assign the two physics bodies so that the one with the lower category is always stored in firstBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        // 3. react to the contact between ball and bottom
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BottomCategory {

            if let mainView = view {
               let gameOverScene = GameOverScene(fileNamed: "GameOverScene")
                gameOverScene?.gameWon = false
                mainView.presentScene(gameOverScene)
            }
            print("Hit bottom. First contact has been made.")
        }
        if firstBody.categoryBitMask == BallCategory && secondBody.categoryBitMask == BlockCategory {
            secondBody.node!.removeFromParent()
            playSound(.Banana)
        
            
            if isGameWon() {
                if let mainView = view {
                    let gameOverScene = GameOverScene(fileNamed: "GameOverScene")
                    gameOverScene?.gameWon = true
                    mainView.presentScene(gameOverScene)
                }
            }
        }
    }
    
    func isGameWon() -> Bool {
        var numberOfBricks = 0
        self.enumerateChildNodesWithName(BlockCategoryName) {
            node, stop in
            numberOfBricks = numberOfBricks + 1
        }
        return numberOfBricks == 0
    }
    
    func playSound(name: AVAudioPlayer.AssetIdentifier) {
        
        guard currentlyplayingSound == false else { return }
        
        if let player = try? AVAudioPlayer(assetIdentifier: name) {
            
            player.delegate = self
            player.play()
            currentlyplayingSound = true
            players.append(player)
            print(players.count)
            
        }
        
    }
    

}





extension AVAudioPlayer {
    
    enum AssetIdentifier: String {
        case Banana
    }
    
    
    
    
    enum AssetError: ErrorType { case AssetNotFound,AssetBadData }
    
    convenience init(assetIdentifier: AssetIdentifier) throws {
        
        guard let file = NSDataAsset(name: assetIdentifier.rawValue) else { throw AssetError.AssetNotFound }
        
        try self.init(data: file.data)
        
    }
    
}


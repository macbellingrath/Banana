//
//  GameOverScene.swift
//  Banana
//
//  Created by Mac Bellingrath on 11/28/15.
//  Copyright © 2015 Mac Bellingrath. All rights reserved.
//

import SpriteKit

let GameOverLabelCategoryName = "gameOverLabel"

class GameOverScene: SKScene {
    
    var gameWon : Bool = false {
        // 1.
        didSet {
            let gameOverLabel = childNodeWithName(GameOverLabelCategoryName) as! SKLabelNode
            gameOverLabel.text = gameWon ? "Game Won" : "Game Over"
        }
    }
    

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
     
        if let view = view {
            // 2.
            
            let gameScene = GameScene(fileNamed: "GameScene")

            view.presentScene(gameScene)
        }

    }
}
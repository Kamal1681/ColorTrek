//
//  GameScene.swift
//  Color Trek
//
//  Created by Kamal Maged on 2019-04-07.
//  Copyright © 2019 Kamal Maged. All rights reserved.
//

import SpriteKit
import GameplayKit


class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var trackArray: [SKSpriteNode]? = [SKSpriteNode]()
    var player: SKSpriteNode? 
    var target: SKSpriteNode?
    var timeLabel: SKLabelNode?
    var scoreLabel: SKLabelNode?
    var currentScore: Int = 0 {
        didSet {
            self.scoreLabel?.text = "Score: \(self.currentScore)"
            GameHandler.sharedInstance.score = currentScore
        }
    }
    var timeRemainig: TimeInterval = 60 {
        didSet {
            self.timeLabel?.text = "Time: \(Int(self.timeRemainig))"
        }
    }
    var currentTrack = 0
    var movetoTrack = false
    let moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    var backgroundNoise: SKAudioNode!
    
    
    let trackVelocities = [180, 200, 250]
    var directionArray = [Bool]()
    var velocityArray = [Int]()
    
    let playerCategory:UInt32  =    0x1 << 0
    let enemyCategory:UInt32   =    0x1 << 1
    let targetCategory:UInt32  =    0x1 << 2
    let powerUpCategory:UInt32 =    0x1 << 3
    

   
    override func didMove(to view: SKView) {

        setUpTracks()
        createHUD()
        launchGameTimer()
        createPlayer()
        createTarget()

        self.physicsWorld.contactDelegate = self
        //trackArray?.first?.color = UIColor.green
        if let musicURL = Bundle.main.url(forResource: "background", withExtension: "wav") {
            backgroundNoise = SKAudioNode(url: musicURL)
            addChild(backgroundNoise)
        }
        
        if let numberOfTracks = trackArray?.count {
            for _ in 0...numberOfTracks {
               let randomNumberForVelocity = GKRandomSource.sharedRandom().nextInt(upperBound: 3)
                velocityArray.append(trackVelocities[randomNumberForVelocity])
                directionArray.append(GKRandomSource.sharedRandom().nextBool())
                
            }
        }
        self.run(SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.spawnEnemies()
            }, SKAction.wait(forDuration: 2)])))
       
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            let location = touch.previousLocation(in: self)
            let node = self.nodes(at: location).first
            if node?.name == "up" || node?.name == "upImg" {
                moveVertically(up: true)
            }
            else if node?.name == "down" || node?.name == "downImg" {
                moveVertically(up: false)
            }
            else if node?.name == "right" || node?.name == "rightImg" {
                if currentTrack < 7 {
                    moveToNextTrack()
                }
            }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movetoTrack {
            player?.removeAllActions()
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movetoTrack {
            player?.removeAllActions()
        }
    }
    func didBegin(_ contact: SKPhysicsContact) {
        var playerBody: SKPhysicsBody
        var otherBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            playerBody = contact.bodyA
            otherBody = contact.bodyB
        } else {
            playerBody = contact.bodyB
            otherBody = contact.bodyA
        }
        if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == enemyCategory {
            self.run(SKAction.playSoundFileNamed("fail.wav", waitForCompletion: true))
            movePlayerToStart()
        } else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == targetCategory {
            nextLevel(playerPhysicsBody: playerBody)
        } else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == powerUpCategory {
            self.run(SKAction.playSoundFileNamed("powerUp.wav", waitForCompletion: true))
            otherBody.node?.removeFromParent()
            timeRemainig += 5
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        if let player = self.player {
            if player.position.y > self.size.height || player.position.y < 0 {
                movePlayerToStart()
            }
            if timeRemainig == 0 {
                gameOver()
            }
        }
        if timeRemainig <= 5 {
            timeLabel?.fontColor = UIColor.red
        }
    }
}

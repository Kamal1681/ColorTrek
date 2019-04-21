//
//  GameFunctions.swift
//  Color Trek
//
//  Created by Kamal Maged on 2019-04-17.
//  Copyright © 2019 Kamal Maged. All rights reserved.
//

import SpriteKit
import GameplayKit

extension GameScene {
    
    func spawnEnemies() {
        for i in 1...6 {
            let randomEnemyType = Enemies(rawValue: GKRandomSource.sharedRandom().nextInt(upperBound: 3))!
            
            if let newEnemy = createEnemy(type: randomEnemyType, forTrack: i) {
                self.addChild(newEnemy)
            }
        }
        self.enumerateChildNodes(withName: "Enemy", using: {(node: SKNode, nil) in
            if node.position.y < -150 || node.position.y > self.size.height + 150 {
                node.removeFromParent()
            }
        })
    }
    
    func moveToNextTrack() {
        player?.removeAllActions()
        movetoTrack = true
        guard let nextTrack = trackArray?[currentTrack + 1].position else {return}
        if let player = self.player {
            let moveAction = SKAction.move(to: CGPoint(x: nextTrack.x, y: player.position.y), duration: 0.2)
            let up = directionArray[currentTrack + 1]
            
            player.run(moveAction, completion: {
                self.movetoTrack = false
                
                if self.currentTrack < ((self.trackArray?.count)! - 1) {
                    self.player?.physicsBody?.velocity = up ? CGVector(dx: 0, dy: self.velocityArray[self.currentTrack]) : CGVector(dx: 0, dy: -self.velocityArray[self.currentTrack])
                } else {
                    self.player?.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
                }
            })
            currentTrack += 1
            self.run(moveSound)
        }
        
    }
    
    func moveVertically(up: Bool) {
        if up {
            let moveAction = SKAction.moveBy(x: 0, y: 3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        } else {
            let moveAction = SKAction.moveBy(x: 0, y: -3, duration: 0.01)
            let repeatAction = SKAction.repeatForever(moveAction)
            player?.run(repeatAction)
        }
    }
    
    func movePlayerToStart() {
        if let player = self.player {
            player.removeFromParent()
            self.player = nil
            self.createPlayer()
            self.currentTrack = 0
        }
    }
    
    func nextLevel(playerPhysicsBody: SKPhysicsBody) {
        self.run(SKAction.playSoundFileNamed("levelUp.wav", waitForCompletion: true))
        currentScore += 1
        
        let emitter = SKEmitterNode(fileNamed: "Fireworks.sks")
        playerPhysicsBody.node?.addChild(emitter!)
        
        self.run(SKAction.wait(forDuration: 2)){
            emitter?.removeFromParent()
            self.movePlayerToStart()
        }
    }
    
    func launchGameTimer() {
        let timeAction = SKAction.repeatForever(SKAction.sequence([SKAction.run {
            self.timeRemainig -= 1
            }, SKAction.wait(forDuration: 1)]))
        timeLabel?.run(timeAction)
    }
}

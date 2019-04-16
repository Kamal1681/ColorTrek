//
//  GameScene.swift
//  Color Trek
//
//  Created by Kamal Maged on 2019-04-07.
//  Copyright © 2019 Kamal Maged. All rights reserved.
//

import SpriteKit
import GameplayKit

enum Enemies: Int {
    case small
    case medium
    case large
}
class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var trackArray: [SKSpriteNode]? = [SKSpriteNode]()
    var player: SKSpriteNode? = SKSpriteNode(imageNamed: "player")
    var target: SKSpriteNode? = SKSpriteNode(imageNamed: "target")
    var currentTrack = 0
    var movetoTrack = false
    let moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    
    let trackVelocities = [180, 200, 250]
    var directionArray = [Bool]()
    var velocityArray = [Int]()
    
    var playerCategory:UInt32  =    0x1 << 0
    var enemyCategory:UInt32   =    0x1 << 1
    var targetCategory:UInt32  =    0x1 << 2
    
    func setUpTracks() {
        for i in 0...7 {
            if let track = self.childNode(withName: "\(i)") {
                trackArray?.append(track as! SKSpriteNode)
            }
        }
        
    }
    func createEnemy(type: Enemies, forTrack track: Int) -> SKShapeNode? {
        let enemySprite = SKShapeNode()
        enemySprite.name = "Enemy"
        switch type {
        case .small:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 70), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.4431, green: 0.5529, blue: 0.7451, alpha: 1)
        case .medium:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 100), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.4039, blue: 0.4039, alpha: 1)
        case .large:
            enemySprite.path = CGPath(roundedRect: CGRect(x: -10, y: 0, width: 20, height: 130), cornerWidth: 8, cornerHeight: 8, transform: nil)
            enemySprite.fillColor = UIColor(red: 0.7804, green: 0.6392, blue: 0.4039, alpha: 1)
        }
        
        guard let enemyPosition = trackArray?[track].position else {return nil}
        
        let up = directionArray[track]
        enemySprite.position.x = enemyPosition.x
        enemySprite.position.y = up ? -130 : self.size.height + 130
        
        enemySprite.physicsBody = SKPhysicsBody(edgeLoopFrom: enemySprite.path!)
        enemySprite.physicsBody?.categoryBitMask = enemyCategory
        enemySprite.physicsBody?.velocity = up ? CGVector(dx: 0, dy: velocityArray[track]) :  CGVector(dx: 0, dy: -velocityArray[track])
        return enemySprite
    }
    func createTarget() {
        target = self.childNode(withName: "target") as? SKSpriteNode
        target?.physicsBody = SKPhysicsBody(circleOfRadius: target!.size.width / 2)
        target?.physicsBody?.categoryBitMask = targetCategory
        target?.physicsBody?.affectedByGravity = false
        target?.physicsBody?.collisionBitMask = 0

    }
    func createPlayer() {
        player?.physicsBody = SKPhysicsBody(circleOfRadius: player!.size.width / 2)
        player?.physicsBody?.linearDamping = 0
        player?.physicsBody?.affectedByGravity = false
        player?.physicsBody?.categoryBitMask = playerCategory
        player?.physicsBody?.collisionBitMask = 0
        player?.physicsBody?.contactTestBitMask = enemyCategory | targetCategory
        
        guard let playerposition = trackArray?.first?.position.x else { return }
        player?.position = CGPoint(x: playerposition, y: self.size.height / 2)
        self.addChild(player!)
        
        let pulse = SKEmitterNode(fileNamed: "Pulse")!
        player?.addChild(pulse)
        pulse.position = CGPoint(x: 0, y: 0)
    }
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
    override func didMove(to view: SKView) {

        setUpTracks()
        createPlayer()
        createTarget()
        
        self.physicsWorld.contactDelegate = self
        trackArray?.first?.color = UIColor.green
        
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
    
    func moveToNextTrack() {
        player?.removeAllActions()
        movetoTrack = true
        
        guard let nextTrack = trackArray?[currentTrack + 1].position else {return}
        if let player = self.player {
           let moveAction = SKAction.move(to: CGPoint(x: nextTrack.x, y: player.position.y), duration: 0.2)
            player.run(moveAction, completion: {
                self.movetoTrack = false
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
                moveToNextTrack()
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
            print("enemy hit")
        } else if playerBody.categoryBitMask == playerCategory && otherBody.categoryBitMask == targetCategory {
            print("target hit")
        }
    }
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

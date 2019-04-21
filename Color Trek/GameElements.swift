//
//  GameElements.swift
//  Color Trek
//
//  Created by Kamal Maged on 2019-04-17.
//  Copyright © 2019 Kamal Maged. All rights reserved.
//

import SpriteKit
import GameplayKit


enum Enemies: Int {
    case small
    case medium
    case large
}

extension GameScene {
    
    
    func setUpTracks() {
        for i in 0...7 {
            if let track = self.childNode(withName: "\(i)") {
                trackArray?.append(track as! SKSpriteNode)
            }
        }
        
    }
    func createHUD() {
        timeLabel = self.childNode(withName: "time") as? SKLabelNode
        scoreLabel = self.childNode(withName: "score") as? SKLabelNode
        currentScore = 0
        timeRemainig = 60
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
        player = SKSpriteNode(imageNamed: "player")
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
}

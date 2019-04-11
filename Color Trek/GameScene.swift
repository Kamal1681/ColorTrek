//
//  GameScene.swift
//  Color Trek
//
//  Created by Kamal Maged on 2019-04-07.
//  Copyright © 2019 Kamal Maged. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    var trackArray: [SKSpriteNode]? = [SKSpriteNode]()
    var player: SKSpriteNode? = SKSpriteNode(imageNamed: "player")
    var currentTrack = 0
    var movetoTrack = false
    let moveSound = SKAction.playSoundFileNamed("move.wav", waitForCompletion: false)
    
    func setUpTracks() {
        for i in 0...7 {
            if let track = self.childNode(withName: "\(i)") {
                trackArray?.append(track as! SKSpriteNode)
            }
        }
        
    }
    func createPlayer() {
        guard let playerposition = trackArray?.first?.position.x else { return }
        player?.position = CGPoint(x: playerposition, y: self.size.height / 2)
        self.addChild(player!)
    }
    
    override func didMove(to view: SKView) {
        setUpTracks()
        createPlayer()
        trackArray?.first?.color = UIColor.green
      
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
      //  player?.removeAllActions()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !movetoTrack {
            player?.removeAllActions()
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}

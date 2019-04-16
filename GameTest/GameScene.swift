//
//  GameScene.swift
//  GameTest
//
//  Created by Siavash on 3/17/19.
//  Copyright © 2019 Siavash. All rights reserved.
//

import SpriteKit

struct PhysicsCategory {
    static let none    : UInt32 = 0
    static let all     : UInt32 = UInt32.max
    static let enemy   : UInt32 = 0b1
    static let missile : UInt32 = 0b10
}

class GameScene: SKScene {
    
    let enemies = ["enemy1.1","enemy2.1","enemy3.1"]
    let player = SKSpriteNode(imageNamed: "player2.1")
    var shipIsTouched = false
    var missileDestination = CGPoint()
    let missileSpeed: CGFloat = 800
    let missileFireRate : TimeInterval = 0.2
    
    override func didMove(to view: SKView) {
        
        physicsWorld.gravity = .zero
        physicsWorld.contactDelegate = self
        
        backgroundColor = SKColor.white
        player.position = CGPoint(x: size.width * 0.1, y: size.height * 0.5)
        player.size = CGSize(width: size.width * 0.15, height: size.width * 0.15)
        addChild(player)
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(addEnemy),
                SKAction.wait(forDuration: 3.0)
                ])
        ))
        
        run(SKAction.repeatForever(
            SKAction.sequence([
                SKAction.run(shoot),
                SKAction.wait(forDuration: 0.5)
                ])
        ))
    }
    
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat {
        return random() * (max - min) + min
    }
    
    
    func addEnemy() {
        
        let enemy = SKSpriteNode(imageNamed: enemies.randomElement() ?? "enemy1.1")
        
        enemy.physicsBody = SKPhysicsBody(rectangleOf: enemy.size)
        enemy.physicsBody?.isDynamic = true
        enemy.physicsBody?.categoryBitMask = PhysicsCategory.enemy
        enemy.physicsBody?.contactTestBitMask = PhysicsCategory.missile
        enemy.physicsBody?.collisionBitMask = PhysicsCategory.none
        
        enemy.size = CGSize(width: size.width * 0.1, height: size.width * 0.1)
        let actualY = random(min: enemy.size.height/2, max: size.height - enemy.size.height/2)
        enemy.position = CGPoint(x: size.width + enemy.size.width/2, y: actualY)
        addChild(enemy)
        let actualDuration = random(min: CGFloat(4), max: CGFloat(8))
        let actionMove = SKAction.move(to: CGPoint(x: -enemy.size.width/2, y: actualY),
                                       duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        enemy.run(SKAction.sequence([actionMove, actionMoveDone]))
    }
    
    func shoot() {
        
        let missile = SKSpriteNode(imageNamed: "missile2")
        missile.size = CGSize(width: size.width * 0.03, height: size.height * 0.03)
        let actualY = player.position.y
        addChild(missile)
        missile.position = player.position
        
        missile.physicsBody = SKPhysicsBody(circleOfRadius: missile.size.width/2)
        missile.physicsBody?.isDynamic = true
        missile.physicsBody?.categoryBitMask = PhysicsCategory.missile
        missile.physicsBody?.contactTestBitMask = PhysicsCategory.enemy
        missile.physicsBody?.collisionBitMask = PhysicsCategory.none
        missile.physicsBody?.usesPreciseCollisionDetection = true
        
        let actualDuration = CGFloat(0.5)
        let actionMove = SKAction.move(to: CGPoint(x: UIScreen.main.bounds.width, y: actualY), duration: TimeInterval(actualDuration))
        let actionMoveDone = SKAction.removeFromParent()
        missile.run(SKAction.sequence([actionMove, actionMoveDone]))
        
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            if player.contains(touch.location(in: self)) {
                shipIsTouched = true
            } else {
                missileDestination = touch.location(in: self)
                //                player.zRotation = direction(to: missileDestination, from: player.position) - CGFloat(Double.pi/2)
            }
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if (shipIsTouched == true) {
            player.position = (touches.first?.location(in: self))!
            //            player.zRotation = direction(to: missileDestination, from: player.position) - CGFloat(Double.pi/2)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if shipIsTouched {
            shipIsTouched = false
        }
    }
    
    
    func direction(to target : CGPoint, from: CGPoint) -> CGFloat {
        let x = target.x - from.x
        let y = target.y - from.y
        var angle = atan(y / x)
        if x < 0 {
            angle = angle + CGFloat.pi
        }
        return angle
    }
    
    func missileDidCollideWithEnemy(missile: SKSpriteNode, enemy: SKSpriteNode) {
        print("Hit")
        missile.removeFromParent()
        enemy.removeFromParent()
    }
}

extension GameScene: SKPhysicsContactDelegate {
    
    func didBegin(_ contact: SKPhysicsContact) {
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        if ((firstBody.categoryBitMask & PhysicsCategory.enemy != 0) &&
            (secondBody.categoryBitMask & PhysicsCategory.missile != 0)) {
            if let enemy = firstBody.node as? SKSpriteNode,
                let missile = secondBody.node as? SKSpriteNode {
                missileDidCollideWithEnemy(missile: missile, enemy: enemy)
            }
        }
    }
}

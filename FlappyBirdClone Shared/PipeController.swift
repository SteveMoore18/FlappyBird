//
//  PipeController.swift
//  FlappyBirdClone
//
//  Created by Савелий Никулин on 08.09.2021.
//

import SpriteKit

class PipeController: SKNode {
	
	private var pipes: [SKSpriteNode] = []
	private let velocity: CGFloat = -60
	private var pipeWidth: CGFloat!
	private var moveAction: SKAction!
	private let pipeXDistance: CGFloat = 190
	private var pipeXStartPosition: CGFloat!
	public let categoryBitMask: UInt32 = 0x1 << 3
	private var isMoving = false
	
	public var scoreIncrementHitbox: SKSpriteNode! // hitbox for pipes if the player passed 
	public var scoreIncrementHitBoxCategoryBitMask: UInt32 = 0x1 << 4
	public var isScoreIncrHitBoxHitted = false
	
	private var randomYPosition: CGFloat {
		let yPos = Int.random(in: (-330)...(-120))
		return CGFloat(yPos)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		for lowerPipe in children as! [SKSpriteNode] {
			if lowerPipe.name!.contains("lowerPipe") {
				pipes.append(lowerPipe)
			}
		}
		
		pipes.forEach {
			$0.position.y = randomYPosition
			// Lower pipes
			$0.physicsBody?.categoryBitMask = categoryBitMask
			$0.physicsBody?.contactTestBitMask = PlayerController.categoryBitMask
			$0.texture?.filteringMode = .nearest
			
			// Higher pipes parent from lower pipes
			($0.children.first as? SKSpriteNode)?.physicsBody?.categoryBitMask = categoryBitMask
			($0.children.first as? SKSpriteNode)?.physicsBody?.contactTestBitMask = PlayerController.categoryBitMask
			($0.children.first as? SKSpriteNode)?.texture?.filteringMode = .nearest
		}
		
		pipeWidth = pipes[0].size.width
		
		moveAction = SKAction.repeatForever(SKAction.move(by: CGVector(dx: velocity, dy: 0), duration: 0.3))
		
		// Getting from GameScene.sks
		pipeXStartPosition = pipes[0].position.x
		
		scoreIncrementHitbox = children.first { $0.name == "scoreIncrHitbox" } as? SKSpriteNode
		
		scoreIncrementHitbox.physicsBody?.categoryBitMask = scoreIncrementHitBoxCategoryBitMask
		scoreIncrementHitbox.physicsBody?.contactTestBitMask = PlayerController.categoryBitMask
	}
	
	public func update() {
		
		// if pipe out of screen then change position to the last element of the array
		// this gives the impression of an endless road
		if pipes[0].position.x < -(pipeWidth / 2) - pipeXDistance {
			pipes[0].position.x = pipes[pipes.count - 1].position.x + pipeWidth + pipeXDistance
			let temp = pipes.remove(at: 0)
			temp.position.y = randomYPosition
			pipes.append(temp)
			isScoreIncrHitBoxHitted = false
		}
		
		if !isScoreIncrHitBoxHitted {
			scoreIncrementHitbox.position.x = pipes[0].position.x + 30
			scoreIncrementHitbox.position.y = pipes[0].position.y + 269 // move between the pipes
		}
		
	}
	
	public func stop() {
		pipes.forEach { $0.removeAction(forKey: "move") }
		isMoving = false
	}
	
	public func move() {
		
		if !isMoving {
			pipes.forEach {
				$0.run(moveAction, withKey: "move")
			}
			isMoving = true
		}
		
	}
	
	public func restart() {
		
		pipes[0].position.x = pipeXStartPosition
		pipes[1].position.x = pipes[0].position.x + pipeXDistance + pipeWidth
		pipes[2].position.x = pipes[1].position.x + pipeXDistance + pipeWidth
		
		scoreIncrementHitbox.position.x = pipes[0].position.x + 30
		scoreIncrementHitbox.position.y = pipes[0].position.y + 269 // move between the pipes
	}
	
}

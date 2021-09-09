//
//  PipeController.swift
//  FlappyBirdClone
//
//  Created by Савелий Никулин on 08.09.2021.
//

import SpriteKit

class PipeController: SKNode {
	
	private var pipes: [SKSpriteNode]!
	private let velocity: CGFloat = -60
	private var pipeWidth: CGFloat!
	private var moveAction: SKAction!
	private let pipeXDistance: CGFloat = 190
	private var pipeXStartPosition: CGFloat!
	private(set) var bitCategory: UInt32!
	
	private var randomYPosition: CGFloat {
		let yPos = Int.random(in: (-330)...(-120))
		return CGFloat(yPos)
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		pipes = children as? [SKSpriteNode]
		pipes.forEach { $0.position.y = randomYPosition }
		
		pipeWidth = pipes[0].size.width
		
		moveAction = SKAction.repeatForever(SKAction.move(by: CGVector(dx: velocity, dy: 0), duration: 0.3))
		
//		move()
		
		bitCategory = pipes[0].physicsBody?.categoryBitMask
		pipeXStartPosition = pipes[0].position.x
	}
	
	public func update() {
		
		// if pipe out of screen then change position to the last element of the array
		// this gives the impression of an endless road
		if pipes[0].position.x < -(pipeWidth / 2) - pipeXDistance {
			pipes[0].position.x = pipes[pipes.count - 1].position.x + pipeWidth + pipeXDistance
			let temp = pipes.remove(at: 0)
			temp.position.y = randomYPosition
			pipes.append(temp)
		}
		
	}
	
	public func stop() {
		pipes.forEach { $0.removeAction(forKey: "move") }
	}
	
	public func move() {
		pipes.forEach {
			$0.run(moveAction, withKey: "move")
		}
		
	}
	
	public func restart() {
		
		pipes[0].position.x = pipeXStartPosition
		pipes[1].position.x = pipes[0].position.x + pipeXDistance + pipeWidth
		pipes[2].position.x = pipes[1].position.x + pipeXDistance + pipeWidth
		
	}
	
}

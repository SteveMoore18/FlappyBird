//
//  BaseController.swift
//  FlappyBirdClone
//
//  Created by Савелий Никулин on 08.09.2021.
//

import SpriteKit

class BaseController: SKNode {

	private var bases: [SKSpriteNode]!
	private let velocity: CGFloat = -60
	private var baseWidth: CGFloat!
	private var moveAction: SKAction!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		// Getting nodes from GameScene.sks -> base
		bases = children as? [SKSpriteNode]
		
		moveAction = SKAction.repeatForever(SKAction.move(by: CGVector(dx: velocity, dy: 0), duration: 0.3))
		
		// Start moving
		move()
		
		baseWidth = bases[0].size.width
		
	}
	
	public func update() {
		
		// if base out of screen then change position to the last element of the array
		// this gives the impression of an endless road
		if bases[0].position.x < -baseWidth / 2 {
			bases[0].position.x = bases[bases.count - 1].position.x + baseWidth
			let temp = bases.remove(at: 0)			
			bases.append(temp)
		}
		
	}
	
	//MARK:- Private func
	private func move() {
		bases.forEach { $0.run(moveAction, withKey: "move") }
	}
	
	private func stop() {
		bases.forEach { $0.removeAction(forKey: "move") }
	}
	
}

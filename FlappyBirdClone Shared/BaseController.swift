//
//  BaseController.swift
//  FlappyBirdClone
//
//  Created by Савелий Никулин on 08.09.2021.
//

import SpriteKit

class BaseController: SKNode {

	private var bases: [SKSpriteNode]!
	private let velocity: CGFloat = -200
	private var baseWidth: CGFloat!
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		// Getting nodes from GameScene.sks -> base
		bases = children as? [SKSpriteNode]
		
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
		bases.forEach { $0.physicsBody?.velocity.dx = velocity }
	}
	
	private func stop() {
		bases.forEach { $0.physicsBody?.velocity.dx = 0 }
	}
	
}

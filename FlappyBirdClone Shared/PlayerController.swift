//
//  PlayerController.swift
//  FlappyBirdClone
//
//  Created by Савелий Никулин on 08.09.2021.
//

import SpriteKit

class PlayerController: SKSpriteNode {
	
	private var defaultXPosition: CGFloat!
	private var defaultYPosition: CGFloat!
	
	private let redBirdTextures: [SKTexture] = [
		SKTexture(imageNamed: "redbird-downflap"),
		SKTexture(imageNamed: "redbird-midflap"),
		SKTexture(imageNamed: "redbird-upflap"),
		SKTexture(imageNamed: "redbird-midflap")
	]
	private let blueBirdTextures: [SKTexture] = [
		SKTexture(imageNamed: "bluebird-downflap"),
		SKTexture(imageNamed: "bluebird-midflap"),
		SKTexture(imageNamed: "bluebird-upflap"),
		SKTexture(imageNamed: "bluebird-midflap")
	]
	private let yellowBirdTextures: [SKTexture] = [
		SKTexture(imageNamed: "yellowbird-downflap"),
		SKTexture(imageNamed: "yellowbird-midflap"),
		SKTexture(imageNamed: "yellowbird-upflap"),
		SKTexture(imageNamed: "yellowbird-midflap")
	]
	private var randomBirdTextures: [SKTexture]? {
		let temp = Int.random(in: 0...2)
		switch temp {
			case 0:
				return redBirdTextures
			case 1:
				return blueBirdTextures
			case 2:
				return yellowBirdTextures
			default:
				break
		}
		return nil
	}
	
	public static let categoryBitMask: UInt32 = 0x1 << 1
	private var isGameOver = false
	
	private(set) var score = 0
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		redBirdTextures.forEach { $0.filteringMode = .nearest }
		blueBirdTextures.forEach { $0.filteringMode = .nearest }
		yellowBirdTextures.forEach { $0.filteringMode = .nearest }
		
		run(SKAction.repeatForever(SKAction.animate(with: randomBirdTextures!, timePerFrame: 0.15)), withKey: "animation")
		
		physicsBody?.affectedByGravity = false
		
		defaultXPosition = position.x
		defaultYPosition = position.y
		
		physicsBody?.categoryBitMask = PlayerController.categoryBitMask
		physicsBody?.collisionBitMask = BaseController.categoryBitMask // Collision only with base
	}
	
	let rotateDown = SKAction.rotate(toAngle: CGFloat(GLKMathDegreesToRadians(-90)), duration: 0.4)
	public func update() {
		if !isGameOver {
			position.x = defaultXPosition
		}
		
		// if player fall, run rotate (to 270 deg) animation
		if (physicsBody?.velocity.dy)! < 0 {
			if action(forKey: "rotateDown") == nil {
				run(rotateDown, withKey: "rotateDown")
			}
		}
		
	}
	
	public func dead() {
		physicsBody?.velocity.dy = 0
		isGameOver = true
		removeAction(forKey: "animation")
	}
	
	public func restart() {
		isGameOver = false
		changeAnimation()
		position.x = defaultXPosition
		position.y = defaultYPosition
		physicsBody?.affectedByGravity = false
		physicsBody?.velocity = .zero
		zRotation = 0
		removeAction(forKey: "rotateDown")
		score = 0
	}
	
	public func incrementScore() -> Int {
		score += 1
		return score
	}
	
	// MARK: - Private functions
	private func jump() {
		physicsBody?.velocity.dy = 0
		physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
		removeAction(forKey: "rotateDown")
		zRotation = CGFloat(GLKMathDegreesToRadians(45))
	}
	
	private func changeAnimation() {
		removeAction(forKey: "animation")
		run(SKAction.repeatForever(SKAction.animate(with: randomBirdTextures!, timePerFrame: 0.15)), withKey: "animation")
	}
	
}

extension PlayerController {
	
	#if os(macOS)
	public override func keyDown(with event: NSEvent) {
		
		switch event.keyCode {
			case 0x31: // Space
				if !event.isARepeat {
					jump()
					physicsBody?.affectedByGravity = true
				}
				break
			default:
				break
		}
		
	}
	#elseif os(iOS)
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		jump()
		physicsBody?.affectedByGravity = true
	}
	#endif
}


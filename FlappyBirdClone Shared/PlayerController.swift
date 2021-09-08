//
//  PlayerController.swift
//  FlappyBirdClone
//
//  Created by Савелий Никулин on 08.09.2021.
//

import SpriteKit

class PlayerController: SKSpriteNode {
	
	private let defaultPosition: CGFloat = -80
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
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		
		run(SKAction.repeatForever(SKAction.animate(with: randomBirdTextures!, timePerFrame: 0.15)), withKey: "animation")
		
	}
	
	public func update() {
		position.x = defaultPosition
	}
	
	// MARK: - Private functions
	private func jump() {
		physicsBody?.velocity.dy = 0
		physicsBody?.applyImpulse(CGVector(dx: 0, dy: 20))
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
				}
				break
			default:
				break
		}
		
	}
	#elseif os(iOS)
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		jump()
	}
	#endif
}


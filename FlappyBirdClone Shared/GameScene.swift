//
//  GameScene.swift
//  FlappyBirdClone Shared
//
//  Created by Савелий Никулин on 08.09.2021.
//

import SpriteKit

class GameScene: SKScene {
    
	private var baseController: BaseController!
	private var pipeController: PipeController!
	private var playerController: PlayerController!
	
	private var gameOverNode: SKSpriteNode!
	private var playButtonNode: SKSpriteNode!
	private var firstMessageNode: SKSpriteNode!
	
	private var isGameOver = false
	private var isGameStart = false
	
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
		scene.setup()
		
        return scene
    }
    
    
    override func update(_ currentTime: TimeInterval) {
        
		baseController.update()
		pipeController.update()
		playerController.update()
		
    }
	
	// MARK: - Private functions
	private func setup() {
		baseController = childNode(withName: "base") as? BaseController
		pipeController = childNode(withName: "Pipes") as? PipeController
		playerController = childNode(withName: "player") as? PlayerController
		
		physicsWorld.contactDelegate = self
		
		gameOverNode = childNode(withName: "gameOverLabel") as? SKSpriteNode
		playButtonNode = childNode(withName: "UI")?.childNode(withName: "playButton") as? SKSpriteNode
		firstMessageNode = childNode(withName: "UI")?.childNode(withName: "message") as? SKSpriteNode
	}
	
	private func gameOver() {
		isGameOver = true
		isGameStart = false
		baseController.stop()
		pipeController.stop()
		playerController.dead()
		gameOverNode.position.x = 0
		playButtonNode.position.x = 0
	}
	
	private func restart() {
		isGameOver = false
		isGameStart = false
		gameOverNode.position.x = -400
		playButtonNode.position.x = -400
		pipeController.restart()
		playerController.restart()
		baseController.move()
	}
	
	private func start() {
		isGameStart = true
//		pipeController.move()
		firstMessageNode.position.x = -400
		playButtonNode.position.x = -400
	}
	
}

// MARK: - Control
extension GameScene {
	
	#if os(macOS) 
	override func keyDown(with event: NSEvent) {
		
		if isGameStart {
			playerController.keyDown(with: event)
			pipeController.move()
		}
		
		switch event.keyCode {
			case 0x31:
				if isGameOver {
					restart()
				}
				if !isGameStart {
					start()
				}
				break
			default:
				break
		}
		
		
	}
	
	#elseif os(iOS)
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		guard let touch = touches.first else { return }
		let location = touch.location(in: self)
		let touchNode = atPoint(location)
		
		if isGameStart {
			playerController.touchesBegan(touches, with: event)
			pipeController.move()
		}
		
		if touchNode == playButtonNode {
			if isGameOver {
				restart()
			}
			if !isGameStart {
				start()
			}
		}
		
	}
	#endif
}

// MARK: - Physics
extension GameScene: SKPhysicsContactDelegate {
	
	func didBegin(_ contact: SKPhysicsContact) {
		let bodyA = contact.bodyA.categoryBitMask
		let bodyB = contact.bodyB.categoryBitMask
		
		switch bodyA | bodyB {
			case playerController.bitCategory | baseController.bitCategory:
				gameOver()
				break
			case playerController.bitCategory | pipeController.bitCategory:
				gameOver()
			default:
				break
		}
		
	}
	
}

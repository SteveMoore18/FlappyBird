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
	
	private var backgroundDay: SKSpriteNode!
	private var backgroundNight: SKSpriteNode!
	
	private var isGameOver = false
	private var isGameStart = false
	
	private var rectForEffect: SKSpriteNode!
	
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
		
		backgroundDay = childNode(withName: "backgroundDay") as? SKSpriteNode
		backgroundNight = childNode(withName: "backgroundNight") as? SKSpriteNode
		
		rectForEffect = SKSpriteNode(color: .black, size: scene!.size)
		rectForEffect.position = .zero
		rectForEffect.zPosition = 10
		rectForEffect.alpha = 0
		
		addChild(rectForEffect)
	}
	
	private func gameOver() {
		isGameOver = true
		isGameStart = false
		baseController.stop()
		pipeController.stop()
		playerController.dead()
		gameOverNode.position.x = 0
		playButtonNode.position.x = 0
		runScreenEffect(color: .white, duration: 0.15, complete: nil)
	}
	
	private func restart() {
		
		runScreenEffect(color: .black, duration: 0.15) {
			self.isGameOver = false
			self.isGameStart = true
			self.gameOverNode.position.x = -400
			self.playButtonNode.position.x = -400
			self.pipeController.restart()
			self.playerController.restart()
			self.baseController.move()
			self.changeBackground()
		}
		
	}
	
	private func start() {
		isGameStart = true
		firstMessageNode.position.x = -400
		playButtonNode.position.x = -400
	}
	
	// effect for if the player died or the game restart 
	private func runScreenEffect(color: NSColor, duration: TimeInterval, complete: (() -> ())?) {
		let show = SKAction.fadeAlpha(to: 0.8, duration: duration)
		let hide = SKAction.fadeAlpha(to: 0, duration: duration)
		rectForEffect.color = color
		rectForEffect.run(show) {
			if complete != nil {
				complete!()
			}
			self.rectForEffect.run(hide)
		}
	}
	
	private func changeBackground() {
		let random = Int.random(in: -1...0)
		backgroundNight.zPosition = CGFloat(random)
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
				if !isGameOver {
					gameOver()
				}
				break
			case playerController.bitCategory | pipeController.bitCategory:
				if !isGameOver {
					gameOver()
				}
			default:
				break
		}
		
	}
	
}

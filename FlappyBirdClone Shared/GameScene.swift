//
//  GameScene.swift
//  FlappyBirdClone Shared
//
//  Created by Савелий Никулин on 08.09.2021.
//

import SpriteKit

#if os(macOS)

typealias UXColor = NSColor

#elseif os(iOS)

typealias UXColor = UIColor

#endif

class GameScene: SKScene {
    
	private var baseController: BaseController!
	private var pipeController: PipeController!
	private var playerController: PlayerController!
	
	private var gameOverNode: SKSpriteNode!
	private var playButtonNode: SKSpriteNode!
	private var firstMessageNode: SKSpriteNode!
	private var scoreLabelNode: SKLabelNode!
	
	private var scoreLabelGameYPosition: CGFloat!
	private var scoreLabelGameOverYPosition: CGFloat = 120
	
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
		scoreLabelNode = childNode(withName: "UI")?.childNode(withName: "scoreLabel") as? SKLabelNode
		scoreLabelNode.alpha = 0
		scoreLabelGameYPosition = scoreLabelNode.position.y
		
		backgroundDay = childNode(withName: "backgroundDay") as? SKSpriteNode
		backgroundNight = childNode(withName: "backgroundNight") as? SKSpriteNode
		
		gameOverNode.texture?.filteringMode = .nearest
		playButtonNode.texture?.filteringMode = .nearest
		firstMessageNode.texture?.filteringMode = .nearest
		backgroundDay.texture?.filteringMode = .nearest
		backgroundNight.texture?.filteringMode = .nearest
		
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
		
		runScreenEffect(color: .white, duration: 0.15) {
			self.gameOverNode.position.x = 0
			self.playButtonNode.position.x = 0
			
			let moveScoreLabel = SKAction.moveTo(y: self.scoreLabelGameOverYPosition, duration: 0.2)
			moveScoreLabel.timingMode = .easeInEaseOut
			self.scoreLabelNode.run(moveScoreLabel, withKey: "moveScoreLabel")
			
		}
		
		
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
			self.scoreLabelNode.alpha = 1
			self.scoreLabelNode.text = "\(0)"
			self.scoreLabelNode.removeAction(forKey: "moveScoreLabel")
			self.scoreLabelNode.position.y = self.scoreLabelGameYPosition
		}
		
	}
	
	private func start() {
		isGameStart = true
		firstMessageNode.position.x = -400
		playButtonNode.position.x = -400
		scoreLabelNode.alpha = 1
	}
	
	// effect for if the player died or the game restart 
	private func runScreenEffect(color: UXColor, duration: TimeInterval, complete: (() -> ())?) {
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
		let collision = contact.bodyA.categoryBitMask | contact.bodyB.categoryBitMask
		
		switch collision {
			case PlayerController.categoryBitMask | BaseController.categoryBitMask:
				if !isGameOver {
					gameOver()
				}
			case PlayerController.categoryBitMask | pipeController.categoryBitMask:
				if !isGameOver {
					gameOver()
				}
			case PlayerController.categoryBitMask | pipeController.scoreIncrementHitBoxCategoryBitMask:
				if !pipeController.isScoreIncrHitBoxHitted {
					pipeController.isScoreIncrHitBoxHitted = true
					scoreLabelNode.text = "\(playerController.incrementScore())"
				}
				
			default:
				break
		}
		
	}
	
}

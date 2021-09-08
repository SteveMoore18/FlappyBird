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
	}
	
}

// MARK: - Control
extension GameScene {
	
	#if os(macOS) 
	override func keyDown(with event: NSEvent) {
		playerController.keyDown(with: event)
	}
	#elseif os(iOS)
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		playerController.touchesBegan(touches, with: event)
	}
	#endif
}


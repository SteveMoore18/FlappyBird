//
//  GameViewController.swift
//  FlappyBirdClone macOS
//
//  Created by Савелий Никулин on 08.09.2021.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene.newGameScene()
        
        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)
		skView.setFrameSize(NSSize(width: 360, height: 640))
        
        skView.ignoresSiblingOrder = true
        
        skView.showsFPS = true
        skView.showsNodeCount = true
    }

}


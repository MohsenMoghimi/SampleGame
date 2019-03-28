//
//  ViewController.swift
//  GameTest
//
//  Created by Siavash on 3/17/19.
//  Copyright © 2019 Siavash. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = GameScene(size: view.bounds.size)
        let skView = view as! SKView
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.ignoresSiblingOrder = true
        scene.scaleMode = .resizeFill
        skView.presentScene(scene)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

}


//
//  ViewController.swift
//  ar-hls-demo
//
//  Created by Yuji Hato on 2017/07/11.
//  Copyright © 2017 Yuji Hato. All rights reserved.
//

import UIKit
import SpriteKit
import ARKit

class ViewController: UIViewController {

    // sample free hls
    // https://bitmovin.com/mpeg-dash-hls-examples-sample-streams/
    private let path: [String] = [
        "https://bitdash-a.akamaihd.net/content/MI201109210084_1/m3u8s/f08e80da-bf1d-4e3d-8899-f0f6155f6efa.m3u8",
        "https://bitdash-a.akamaihd.net/content/sintel/hls/playlist.m3u8",
        "https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8",
        "http://184.72.239.149/vod/smil:BigBuckBunny.smil/playlist.m3u8",
        "http://www.streambox.fr/playlists/test_001/stream.m3u8"
    ]

    @IBOutlet var sceneView: ARSKView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and node count
        sceneView.showsFPS = true
        sceneView.showsNodeCount = true

        let scene = SKScene(size: view.bounds.size)
        sceneView.presentScene(scene)

        let gesture = UITapGestureRecognizer(target: self,
                                             action: #selector(ViewController.handleTap(gestureRecognize:)))
        sceneView.addGestureRecognizer(gesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Run the view's session
        sceneView.session.run(createConfiguration())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    @objc
    func handleTap(gestureRecognize: UITapGestureRecognizer) {

        if let currentFrame = sceneView.session.currentFrame {
            var translation = matrix_identity_float4x4
            translation.columns.3.z = -3

            let transform = simd_mul(currentFrame.camera.transform, translation)

            // Add a new anchor to the session.
            let anchor = ARAnchor(transform: transform)
            sceneView.session.add(anchor: anchor)
        }
    }

    private func createConfiguration() -> ARSessionConfiguration {
        let configuration = ARWorldTrackingSessionConfiguration()
        configuration.planeDetection = .horizontal
        return configuration
    }
}

extension ViewController: ARSKViewDelegate {

    func view(_ view: ARSKView, nodeFor anchor: ARAnchor) -> SKNode? {
        let url = URL(string: path[Int(arc4random_uniform(5))])!
        let asset = AVAsset(url: url)
        let playerItem = AVPlayerItem(asset: asset)
        let player = AVPlayer(playerItem: playerItem)

        let videoNode = SKVideoNode(avPlayer: player)
        videoNode.position = CGPoint(x: sceneView.bounds.size.width/2, y: sceneView.bounds.size.height/2)
        videoNode.size = CGSize(width: 320, height: 180)
        videoNode.play()

        sceneView.node(for: anchor)?.addChild(videoNode)
        return videoNode
    }

    func view(_ view: ARSKView, didAdd node: SKNode, for anchor: ARAnchor) {
        print("didAdd")
    }

    func view(_ view: ARSKView, willUpdate node: SKNode, for anchor: ARAnchor) {
        print("willUpdate")
    }


    func view(_ view: ARSKView, didUpdate node: SKNode, for anchor: ARAnchor) {
        print("didUpdate")
    }

    func view(_ view: ARSKView, didRemove node: SKNode, for anchor: ARAnchor) {
        print("didRemove")
    }
}

extension ViewController: ARSessionObserver {

    func session(_ session: ARSession, didFailWithError error: Error) {
        print("didFailWithError")
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print("cameraDidChangeTrackingState")
    }

    func sessionWasInterrupted(_ session: ARSession) {
        print("wasInterrupted")
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        print("interruptionEnded")
        sceneView.session.run(createConfiguration(), options: .resetTracking)
    }
}

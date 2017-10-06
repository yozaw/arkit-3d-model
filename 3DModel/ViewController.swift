//
//  ViewController.swift
//  arApp
//
//  Created by esrij on H29/09/01.
//  Copyright © 平成29年 com.esrij. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var node: SCNNode!
    var scale: Double!
    var angle: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // SCNNodeを作成して、ARSCNViewのシーンに追加
        let url = Bundle.main.url(forResource: "plant1_0", withExtension: "dae")!
        //let url = Bundle.main.url(forResource: "Shiozaki_0", withExtension: "dae")!
        do {
            // .dae ファイルのノード（3Dオブジェクト）を取得し、新たにSCNNodeを作成する
            let scene = try SCNScene(url: url, options: nil)
            //node = scene.rootNode.childNode(withName: "shiozaki", recursively: true)
            node = scene.rootNode.childNode(withName: "plant", recursively: true)

            // スケール、表示位置、角度の設定
            // モデルの実寸の1/10倍
            //scale = 0.01
            scale = 0.1
            node?.scale = SCNVector3(scale, scale, scale)
            // カメラの表示中心位置に奥行き1mで表示
            node?.position = SCNVector3(0, 0, -1)
            // オイラー角でβに-5度回転する
            angle = -5
            node?.eulerAngles = SCNVector3(0, -5 * (Float.pi / 180), 0)
            
            //作成したノードをシーンビューのシーンに追加
            sceneView.scene.rootNode.addChildNode(node!)
            
        } catch {
            print(error.localizedDescription)
        }
        
        // 画面の中心にカーソルを表示
        drawCenterSign()
        
    }
    
    
    @IBAction func move(_ sender: UIButton) {
        
        // 画面の中心にある平面の座標を取得
        let hitResults = sceneView.hitTest(sceneView.center, types: .estimatedHorizontalPlane)
        if !hitResults.isEmpty {
            if let hitTResult = hitResults.first {
                node?.scale = SCNVector3(scale, scale, scale)
                // 現実世界の座標にノードを移動
                node?.position = SCNVector3(hitTResult.worldTransform.columns.3.x, hitTResult.worldTransform.columns.3.y, -1)
            }
        }
        
    }
    
    @IBAction func zoomin(_ sender: UIButton) {
        // スケールを拡大
        scale = scale + 0.001
        node?.scale = SCNVector3(scale, scale, scale)
    }
    
    @IBAction func zoomout(_ sender: UIButton) {
        // スケールを縮小
        scale = scale - 0.001
        node?.scale = SCNVector3(scale, scale, scale)
    }
    
    @IBAction func rotate_left(_ sender: UIButton) {
        // オイラー角でβに-5度回転する
        angle = angle - 5
        node?.eulerAngles = SCNVector3(0, angle * (Float.pi / 180), 0)
    }
    
    @IBAction func rotate_right(_ sender: UIButton) {
        // オイラー角でβに5度回転する
        angle = angle + 5
        node?.eulerAngles = SCNVector3(0, angle * (Float.pi / 180), 0)
    }
    
   
    func drawCenterSign() {
        
        UIGraphicsBeginImageContext(CGSize(width: 20, height: 20))
        let context = UIGraphicsGetCurrentContext()
        
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.setLineWidth(1.0)
        context?.move(to: CGPoint(x: 10, y: 0))
        context?.addLine(to: CGPoint(x: 10, y: 20))
        context?.move(to: CGPoint(x: 0, y: 10))
        context?.addLine(to: CGPoint(x: 20, y: 10))
        context?.strokePath()
        
        context?.setStrokeColor(UIColor.white.cgColor)
        
        context?.setLineWidth(1.0)
        context?.move(to: CGPoint(x: 10, y: 9))
        context?.addLine(to: CGPoint(x: 10, y: 11))
        context?.move(to: CGPoint(x: 9, y: 10))
        context?.addLine(to: CGPoint(x: 11, y: 9))
        context?.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let caLayer = CALayer()
        caLayer.frame = CGRect(x: sceneView.frame.size.width / 2 - 10, y: sceneView.frame.size.height / 2 - 10, width: 20, height: 20)
        caLayer.contents = image?.cgImage
        view.layer.addSublayer(caLayer)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        // Run the view's session
        sceneView.session.run(configuration)
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

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        print("didAdd")
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        print("didUpdate")
    }
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}

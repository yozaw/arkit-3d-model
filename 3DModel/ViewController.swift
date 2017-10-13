//
//  ViewController.swift
//  arApp
//
//  Created by esrij on H29/09/01.
//  Copyright © 平成29年 com.esrij. All rights reserved.
//

import UIKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    var plantNode: SCNNode!
    var buildingNode: SCNNode!
    var townNode: SCNNode!

    var scale: Double!
    var angle: Float!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // plantのSCNNodeを作成
        let plantUrl = Bundle.main.url(forResource: "plant", withExtension: "dae")!
        do {
            // .daeファイルのノード（3Dオブジェクト）を取得し、新たにSCNNodeを作成する
            let plantScene = try SCNScene(url: plantUrl, options: nil)
            plantNode = plantScene.rootNode.childNode(withName: "plant", recursively: true)
        } catch {
            print(error.localizedDescription)
        }
        
        // buildingのSCNNodeを作成
        let buildingUrl = Bundle.main.url(forResource: "building", withExtension: "dae")!
        do {
            let buildingScene = try SCNScene(url: buildingUrl, options: nil)
            buildingNode = buildingScene.rootNode.childNode(withName: "building", recursively: true)
        } catch {
            print(error.localizedDescription)
        }
        
        // townのSCNNodeを作成
        let nagatachoUrl = Bundle.main.url(forResource: "town", withExtension: "dae")!
        do {
            let nagatachoScene = try SCNScene(url: nagatachoUrl, options: nil)
            townNode = nagatachoScene.rootNode.childNode(withName: "town", recursively: true)
        } catch {
            print(error.localizedDescription)
        }
        
        // スケール、表示位置、角度の設定
        // モデルの実寸の1/10倍
        scale = 0.1
        plantNode?.scale = SCNVector3(scale, scale, scale)
        // カメラの表示中心位置に奥行き1mで表示
        plantNode?.position = SCNVector3(0, 0, -1)
        // オイラー角でβに-5度回転する
        angle = -5
        plantNode?.eulerAngles = SCNVector3(0, angle * (Float.pi / 180), 0)
        
        //作成したplantのノードをARSCNViewのシーンに追加
        sceneView.scene.rootNode.addChildNode(plantNode!)
        print(sceneView.scene.rootNode.childNodes.count)

        // 画面の中心にカーソルを表示
        drawCenterSign()
        
    }
    
    
    @IBAction func nodeChange(_ sender: UISegmentedControl) {
        
        buildingNode.removeFromParentNode()
        plantNode.removeFromParentNode()
        townNode.removeFromParentNode()
        
        if sender.selectedSegmentIndex == 0 {
            // ノードをplantに変更
            scale = 0.1
            //buildingNode?.scale = SCNVector3(scale, scale, scale)
            sceneView.scene.rootNode.addChildNode(plantNode!)
        } else if sender.selectedSegmentIndex == 1 {
            // ノードをbuildingに変更
            scale = 0.001
            //buildingNode?.scale = SCNVector3(scale, scale, scale)
            sceneView.scene.rootNode.addChildNode(buildingNode!)
        } else if sender.selectedSegmentIndex == 2 {
            // ノードをtownに変更
            scale = 0.0001
            //nagatachoNode?.scale = SCNVector3(scale, scale, scale)
            sceneView.scene.rootNode.addChildNode(townNode!)
        }
        
    }
    
    @IBAction func move(_ sender: UIButton) {
        
        // 画面の中心にある座標を取得
        let hitResults = sceneView.hitTest(sceneView.center, types: .featurePoint)
        if !hitResults.isEmpty {
            if let hitResult = hitResults.first {
                sceneView.scene.rootNode.childNodes.last?.scale = SCNVector3(scale, scale, scale)
                // 現実世界の座標にノードを移動
                sceneView.scene.rootNode.childNodes.last?.position = SCNVector3(hitResult.worldTransform.columns.3.x, hitResult.worldTransform.columns.3.y, hitResult.worldTransform.columns.3.z)
            }
        }
        
    }
    
    @IBAction func zoomin(_ sender: UIButton) {
        // スケールを拡大
        scale = scale * 1.5
        sceneView.scene.rootNode.childNodes.last?.scale = SCNVector3(scale, scale, scale)
    }
    
    @IBAction func zoomout(_ sender: UIButton) {
        // スケールを縮小
        scale = scale / 1.5
        sceneView.scene.rootNode.childNodes.last?.scale = SCNVector3(scale, scale, scale)
    }
    
    @IBAction func rotate_left(_ sender: UIButton) {
        // オイラー角でβに-5度回転する
        angle = angle - 5
        sceneView.scene.rootNode.childNodes.last?.eulerAngles = SCNVector3(0, angle * (Float.pi / 180), 0)
    }
    
    @IBAction func rotate_right(_ sender: UIButton) {
        // オイラー角でβに5度回転する
        angle = angle + 5
        sceneView.scene.rootNode.childNodes.last?.eulerAngles = SCNVector3(0, angle * (Float.pi / 180), 0)
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

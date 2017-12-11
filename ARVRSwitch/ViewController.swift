//
//  ViewController.swift
//  ARVRSwitch
//
//  Created by Toshihiro Goto on 2017/12/11.
//  Copyright © 2017年 Toshihiro Goto. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    
    // 端末の傾きを保持する変数
    var orientationNumber:UInt32 = 6
    
    // AR / VR スイッチ用のフラグ
    var BGFlag:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
        
        // Create a new scene
        let scene = SCNScene(named: "art.scnassets/ship.scn")!
        
        // Set the scene to the view
        sceneView.scene = scene
        
        //タップイベント
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        
        // Run the view's session
        sceneView.session.run(configuration)
        
        // 傾きを検知したら通知を送る
        NotificationCenter.default.addObserver(self, selector: #selector(onOrientationChange(notification:)), name: .UIDeviceOrientationDidChange, object: nil)
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        
        if BGFlag {
            // VR 用 キューブマップ背景
            sceneView.scene.background.contents = UIImage(named: "art.scnassets/Background_sky.png")
        }else{
            // ARKit 設定時にカメラからの画像が空で渡されるのでその場合は処理しない
            guard let cuptureImage = sceneView.session.currentFrame?.capturedImage else {
                return
            }
            
            // PixelBuffer を CIImage に変換しフィルターをかける
            let ciImage = CIImage.init(cvPixelBuffer: cuptureImage)
            let filter:CIFilter = CIFilter(name: "CIDotScreen")!
            filter.setValue(ciImage, forKey: kCIInputImageKey)
            
            //　CIImage を CGImage に変換して背景に適応
            let context = CIContext()
            let result = filter.outputImage!.oriented(CGImagePropertyOrientation(rawValue: orientationNumber)!)
            if let cgImage = context.createCGImage(result, from: result.extent) {
                sceneView.scene.background.contents = cgImage
            }
        }
    }
    
    // 傾きを全て許可
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.all
    }
    
    // 通知の呼び出しから傾きを保持
    @objc func onOrientationChange(notification: NSNotification){
        
        switch UIDevice.current.orientation {
        case .landscapeLeft:
            orientationNumber = 0
        case .landscapeRight:
            orientationNumber = 3
        case .portrait:
            orientationNumber = 6
        case .portraitUpsideDown:
            orientationNumber = 8
        default:
            orientationNumber = 6
        }
        
    }
    
    // タップジェスチャ動作時の関数
    @objc func handleTap(_ gestureRecognize: UIGestureRecognizer) {
        if BGFlag {
            BGFlag = false
        }else{
            BGFlag = true
        }
    }

}

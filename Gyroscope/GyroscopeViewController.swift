//
//  GyroscopeViewController.swift
//  Sensors
//
//  Created by Linda Cobb on 9/22/14.
//  Copyright (c) 2014 TimesToCome Mobile. All rights reserved.
//

import Foundation
import UIKit
import CoreMotion
import SceneKit
import Accelerate



// raw rotation rate along x, y, z in radians per second



class GyroscopeViewController: UIViewController 
{
    @IBOutlet var xLabel: UILabel!
    @IBOutlet var yLabel: UILabel!
    @IBOutlet var zLabel: UILabel!
    @IBOutlet var iLabel: UILabel!
    
    
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var startButton: UIButton!
    
    @IBOutlet var sceneView: SCNView!

    
    var motionManager: CMMotionManager!
    var stopUpdates = false
    
    var xCone:SCNNode!
    var yCone:SCNNode!
    var zCone:SCNNode!

    let radius:CGFloat = 20.0
    
    required init( coder aDecoder: NSCoder ){
        super.init(coder: aDecoder)
    }
    
    
    convenience override init(nibName nibNameOrNil: String!, bundle nibBundleOrNil: NSBundle!){
        self.init(nibName: nil, bundle: nil)
    }
    
   
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupScene()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        motionManager = appDelegate.sharedManager
        
        xLabel.text = "Pitch:"
        yLabel.text = "Roll:"
        zLabel.text = "Yaw:"
        iLabel.text = "Rate:"
        
    }
    
    
    func setupScene(){
        
        let scene = SCNScene()
        
        
        // create and add a camera to the scene
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.camera?.zFar = -100.0
        //cameraNode.camera?.zNear = 100.0
        scene.rootNode.addChildNode(cameraNode)
        
        // place the camera
        cameraNode.position = SCNVector3(x: 20, y: 20, z: 150)
        
        
        // create and add an ambient light to the scene
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = SCNLightTypeAmbient
        ambientLightNode.light?.color = UIColor.whiteColor()
        scene.rootNode.addChildNode(ambientLightNode)
        
        
        
        
        
        // first sphere
        let xcone = SCNCone(topRadius: radius, bottomRadius: radius, height: 1.0)
        let xmaterial = SCNMaterial()
        xmaterial.diffuse.contents = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
        
        xCone = SCNNode(geometry: xcone)
        xCone.position = SCNVector3( x: 0.0, y: 0.0, z: 0.0 )
        xCone.geometry?.firstMaterial = xmaterial
        scene.rootNode.addChildNode(xCone)
        
        
        
        // second sphere
        let ycone = SCNCone(topRadius: radius, bottomRadius: radius, height: 1.0)
        let ymaterial = SCNMaterial()
        ymaterial.diffuse.contents = UIColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
        
        yCone = SCNNode(geometry: ycone)
        yCone.position = SCNVector3( x: 0.0, y: 0.0, z: 0.0 )
        yCone.geometry?.firstMaterial = ymaterial
        scene.rootNode.addChildNode(yCone)
        
        
        
        // third sphere
        let zcone = SCNCone(topRadius: radius, bottomRadius: radius, height: 1.0)
        let zmaterial = SCNMaterial()
        zmaterial.diffuse.contents = UIColor(red: 0.0, green: 0.0, blue: 1.0, alpha: 0.5)
        
        zCone = SCNNode(geometry: zcone)
        zCone.position = SCNVector3( x: 0.0, y: 0.0, z: 0.0 )
        zCone.geometry?.firstMaterial = zmaterial
       scene.rootNode.addChildNode(zCone)
        
        
        
        // set the scene to the view
        sceneView.scene = scene
        sceneView.backgroundColor = UIColor.whiteColor()
        
        
    }
    

    
   
    
    @IBAction func stop(){
        stopUpdates = true
        motionManager.stopGyroUpdates()
    }
    
    
    
    @IBAction func start(){
        
        stopUpdates = false
        startUpdates()
    }
    
    
    
    func startUpdates() {
        
        
        let updateInterval = 1.0/10.0
        motionManager.gyroUpdateInterval = updateInterval
        
        let dataQueue = NSOperationQueue()
        
        motionManager.startGyroUpdatesToQueue(dataQueue, withHandler: {
            
            data, error in
            
            NSOperationQueue.mainQueue().addOperationWithBlock({
                
                if let dataIn = data {
            
                
                    let xField:Float = Float(dataIn.rotationRate.x)
                    let yField:Float = Float(dataIn.rotationRate.y)
                    let zField:Float = Float(dataIn.rotationRate.z)

                    
                    // move markers
                    SCNTransaction.setAnimationDuration(0.1)
                    self.xCone.rotation = SCNVector4Make(1.0, 0.0, 0.0, xField)
                    self.yCone.rotation = SCNVector4Make(0.0, 1.0, 0.0, yField)
                    self.zCone.rotation = SCNVector4Make(0.0, 0.0, 1.0, zField)
                    
                    
                    
                    // update labels
                    self.xLabel.text = NSString(format: "Pitch: %.6lf '", GLKMathRadiansToDegrees(xField)) as String
                    self.yLabel.text = NSString(format: "Roll: %.6lf '", GLKMathRadiansToDegrees(yField)) as String
                    self.zLabel.text = NSString(format: "Yaw: %.6lf '", GLKMathRadiansToDegrees(zField)) as String
                    
                    var vector = [dataIn.rotationRate.x, dataIn.rotationRate.y, dataIn.rotationRate.z]
                    var intensity = cblas_dnrm2(3, &vector, 1)
                    self.iLabel.text = NSString(format: "Rotation rate: %.6lf rad/s", intensity) as String
                    
                }
                
                
                if ( self.stopUpdates ){
                    self.motionManager.stopAccelerometerUpdates()
                    NSOperationQueue.mainQueue().cancelAllOperations()
                }
                
            })
        })
    }
    
    
    override func viewDidDisappear(animated: Bool){
        
        super.viewDidDisappear(animated)
        stop()
    }
 
}
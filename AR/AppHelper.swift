//
//  AppHelper.swift
//  AR
//
//  Created by Prithvi on 09/07/19.
//  Copyright © 2019 Ratti. All rights reserved.
//

import Foundation
import SceneKit
import SpriteKit

enum keySaved : String
{
    case planeGeometry = "planeGeometry"
    case width = "width"
    case height = "height"
    case nodePosition = "nodePosition"
    case nodeMain = "nodeMain"
    case nodeChild = "nodeChild"
}

class AppHelper: NSObject
{
    struct Constants
    {
        struct string
        {
            
        }
        struct message
        {
            static var areaRectange : String{ return "Area of Rectange : %.2f"}
        }
        
        struct userDefaultKeys
        {
            static let saveNodes : String = "SaveInfo"
        }
    }
}

class Facade: NSObject
{
    static let shared : Facade = Facade.init()

    var arrSavedNodes : Array<SCNNode>
    {
        get{

            let arrNodes : Array<SCNNode> = self.arrSavedInfo.map { (info) -> SCNNode in
                
                return self.convertDicToNode(info: info)
            }
            
            return arrNodes
        }
    }
    
    var arrSavedInfo : Array<Dictionary<String,Any>>{
        
        get{
            
            if let arrInfo = UserDefaults.standard.value(forKey: AppHelper.Constants.userDefaultKeys.saveNodes) as? Array<Dictionary<String,Any>>
            {
                return arrInfo
            }
            
            return []
        }
    }
}

extension Facade
{
    /// Saves each node locally
    ///
    /// - Parameters:
    ///   - node: Node to convert into json form
    ///   - childNode: Child node to convert into json form
    func save(node : SCNNode, childNode : SCNNode)
    {
        var dicInfo : Dictionary<String,Any> = Dictionary()
        
        dicInfo[keySaved.nodeMain.rawValue] = self.convertNodeToDic(node: node)
        dicInfo[keySaved.nodeChild.rawValue] = self.convertNodeToDic(node: childNode)
        
        var arrTempSavedInfo = self.arrSavedInfo
        
        arrTempSavedInfo.append(dicInfo)
    
        UserDefaults.standard.setValue(arrSavedInfo, forKey: AppHelper.Constants.userDefaultKeys.saveNodes)
    }
    

    /// Helps to convert Node instance to Json to save in UserDefaults
    ///
    /// - Parameters:
    ///   - node: Node to convert into json form
    /// - Returns: Json type
    func convertNodeToDic(node : SCNNode) -> Dictionary<String,Any>
    {
        var dicInfo : Dictionary<String,Any> = Dictionary()
        var geometry : Dictionary<String,Any> = Dictionary()
        var nodePosition : Dictionary<String,Any> = Dictionary()
        
        if let planeGeometry = node.geometry as? SCNPlane
        {
            geometry[keySaved.width.rawValue] = planeGeometry.width
            geometry[keySaved.height.rawValue] = planeGeometry.height
        }
        else
        {
            geometry[keySaved.width.rawValue] = 0.0
            geometry[keySaved.height.rawValue] = 0.0
        }
        
        nodePosition["x"] = node.position.x
        nodePosition["y"] = node.position.y
        nodePosition["z"] = node.position.z
        
        dicInfo[keySaved.planeGeometry.rawValue] = geometry
        dicInfo[keySaved.nodePosition.rawValue] = nodePosition
        
        return dicInfo
    }
    
    /// Helps to convert Json to Node to show in SceneView
    ///
    /// - Parameters:
    ///   - info: Json information of node
    /// - Returns: Node type
    func convertDicToNode(info : Dictionary<String,Any>) -> SCNNode
    {
        var nodeMain : SCNNode = SCNNode()
        var nodeChild : SCNNode = SCNNode()
        
        if let nodeInfo = info[keySaved.nodeMain.rawValue] as? Dictionary<String,Any>
        {
            nodeMain = self.getNode(info: nodeInfo, isMainNode: true)
        }
        if let nodeChildInfo = info[keySaved.nodeChild.rawValue] as? Dictionary<String,Any>
        {
            nodeChild = self.getNode(info: nodeChildInfo, isMainNode: false)
            
            nodeMain.addChildNode(nodeChild)
            
            return nodeMain
        }
        
        return nodeMain
        
    }
    /// Fetch node as a child or as a main node accordingly
    ///
    /// - Parameters:
    ///   - info: Json information of node
    ///   - isMainNode: To fetch Main or Child node
    /// - Returns: Node type
    func getNode(info : Dictionary<String,Any>, isMainNode : Bool) -> SCNNode
    {
        if let geometryInfo = info[keySaved.planeGeometry.rawValue] as? Dictionary<String,Any>
        {
            var node : SCNNode = SCNNode()
            
            if !isMainNode
            {
                let planeGeometry : SCNPlane = SCNPlane.init(width: geometryInfo[keySaved.width.rawValue] as? CGFloat ?? 0, height: geometryInfo[keySaved.height.rawValue] as? CGFloat ?? 0)
                
                let sceneDescription = SKScene.init(fileNamed: "PlaneDescription")
                
                if let lblNode = sceneDescription?.childNode(withName: "lblDescription") as? SKLabelNode
                {
                    lblNode.text = String.init(format: AppHelper.Constants.message.areaRectange, (planeGeometry.width * planeGeometry.height))
                }
                
                planeGeometry.materials.first?.diffuse.contents = sceneDescription
                
                node = SCNNode.init(geometry: planeGeometry)
            }
            
            if let positionInfo = info[keySaved.nodePosition.rawValue] as? Dictionary<String,Any>
            {
                node.position = SCNVector3.init(positionInfo["x"] as? Float ?? 0, positionInfo["y"] as? Float ?? 0, positionInfo["z"] as? Float ?? 0)
            }
            
            return node
        }
        
        return SCNNode()
    }
}

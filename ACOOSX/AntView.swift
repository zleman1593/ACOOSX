//
//  AntView.swift
//  AntColonyOptimization
//
//  Created by Zackery leman on 4/6/15.
//  Copyright (c) 2015 Zleman. All rights reserved.
//

import Cocoa

@IBDesignable
class AntView: NSView {
    var delegate: AntViewDelegate!
    private var antColonyInstance: ACO?
    @IBInspectable
    var lineWidth: CGFloat = 3 { didSet { } }
    var color: NSColor = NSColor.blueColor() { didSet { } }
    
    override func drawRect(rect: CGRect) {
         antColonyInstance = delegate?.getACOInstance()
        
        let antPath =  NSBezierPath(rect: CGRect(x: 100, y: 100, width: 12, height: 12))
        
        /*UIBezierPath(
            arcCenter: faceCenter,
            radius: faceRadius,
            startAngle: 0,
            endAngle: CGFloat(2*M_PI),
            clockwise: true
        )*/
        
        antPath.lineWidth = lineWidth
        color.set()
        antPath.stroke()

    }
    
    
    
  

}

protocol AntViewDelegate{
    func getACOInstance() -> ACO
}
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
    var lineWidth: CGFloat = 3 { didSet {display() } }
    var color: NSColor = NSColor.blueColor() { didSet {display() } }
    var cities:[Point2D]!
    let yScale = 13.0
    let xScale = 13.0
    var bestTour:Tour? {
        willSet {
            if bestTour?.length != newValue?.length {
            lastTour = bestTour
            }
        }
    }
    var lastTour:Tour?
    
    override func drawRect(rect: CGRect) {
        //antColonyInstance = delegate?.getACOInstance()
        
        
        if let listOfCities = cities {
            for city in cities {
                let x = (Double(city.x) * yScale)
                let y = (Double(city.y) * yScale)
                let cityPoint =  NSBezierPath(rect: CGRect(x: x , y: y , width: 12, height: 12))
                cityPoint.lineWidth = lineWidth
                color.set()
                cityPoint.stroke()
                
            }
        }
        
    
        
        
        if let currentTour = lastTour{
            for (_,edge) in currentTour.edgesInTour {
                let edgeToDraw  = NSBezierPath()
                edgeToDraw.moveToPoint(NSPoint(x: edge.cityALocation.x * xScale, y: (edge.cityALocation.y  * yScale)))
                edgeToDraw.lineToPoint(NSPoint(x: edge.cityBLocation.x * xScale, y: (edge.cityBLocation.y * yScale)))
                edgeToDraw.lineWidth = lineWidth
                NSColor.grayColor().set()
                edgeToDraw.stroke()
            }
        }
        
        if let currentTour = bestTour{
            for (_,edge) in currentTour.edgesInTour {
                let edgeToDraw  = NSBezierPath()
                edgeToDraw.moveToPoint(NSPoint(x: edge.cityALocation.x * xScale, y: (edge.cityALocation.y  * yScale)))
                edgeToDraw.lineToPoint(NSPoint(x: edge.cityBLocation.x * xScale, y: (edge.cityBLocation.y * yScale)))
                edgeToDraw.lineWidth = lineWidth
                NSColor.redColor().set()
                edgeToDraw.stroke()
            }
        }
        
    }
    
    
}

protocol AntViewDelegate{
    func getACOInstance() -> ACO
}
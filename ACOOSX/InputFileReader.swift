//
//  InputFileReader.swift
//  AntColonyOptimization
//
//  Created by Zackery leman on 4/5/15.
//  Copyright (c) 2015 Zleman. All rights reserved.
//

import Cocoa

struct Point2D
{
    
    var x: Double = 0.0
    var y: Double = 0.0
}

class InputFileReader {
    
    var cities: [Point2D] = []
    
    
    
    init(){}
    func readFrom(filePath: String) -> [Point2D]{
        var startReading = false
        let path = NSBundle.mainBundle().pathForResource("/\(filePath)", ofType: "tsp")
        
        if let content = String(contentsOfFile:path!, encoding: NSUTF8StringEncoding, error: nil) {
            let array = content.componentsSeparatedByString("\n")
            println("\(array)")
            
            for line in array {
                
                
                if line.rangeOfString("NODE_COORD_SECTION") != nil {
                    println("Start File Contents")
                    startReading = true
                } else if line.rangeOfString("EOF") != nil {
                    println("EOF")
                    break
                }
                
                
                if startReading && line.rangeOfString("NODE_COORD_SECTION") == nil {
                    let splitLine = line.getDoublesFromString()
                    
                    let x = splitLine[1]
                    let y = splitLine[2]
                    cities.append(Point2D(x: x,y: y))
                    
                }
                
            }

        }
        
        return  cities
    }
    
}

    
extension String {
    func getDoublesFromString() -> [Double]{
        let splitLine = self.componentsSeparatedByString(" ").filter {$0 != "" }
        let result = splitLine.map {($0 as NSString).doubleValue}
        return result
    }
}
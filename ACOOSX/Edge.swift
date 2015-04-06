//
//  Edge.swift
//  AntColonyOptimization
//
//  Created by Zackery leman on 4/5/15.
//  Copyright (c) 2015 Zleman. All rights reserved.
//

import Foundation

class Edge {
    
    var cityA: Int!
    var cityB: Int!
    var cityALocation: Point2D!
    var cityBLocation: Point2D!
    lazy var euclideanDistance: Double?  = {
        //calculating distance by euclidean formula
        let x = self.cityALocation.x - self.cityBLocation.x
        let y = self.cityALocation.y - self.cityBLocation.y
        var dist = pow(x,2)+pow(y,2)
        return sqrt(dist)
    }()
    var initialPheromoneConcentration: Double!
    var currentPheromoneConcentration: Double!
    var name: String {
        return "\(cityA):\(cityB)"
    }
    
    
    init(cityA: Int, cityB: Int,cityALocation: Point2D, cityBLocation: Point2D){
        
        self.cityA = cityA
        self.cityB = cityB
        self.cityALocation = cityALocation
        self.cityBLocation = cityBLocation
    }
    
    

    
}
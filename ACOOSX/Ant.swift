//
//  Ant.swift
//  AntColonyOptimization
//
//  Created by Zackery leman on 4/5/15.
//  Copyright (c) 2015 Zleman. All rights reserved.
//

import Foundation


class Ant{
    var currentTour: Tour = Tour()
    var currentCity:Int!
    var remainingCities: [Int]!
    
    init(){
    }
    
}

class Tour: Printable{
    var edgesInTour: [String:Edge] = [:]
    lazy var length: Double =  { [unowned self] in
        
        return  self.sumEdgeDistance() }()
    
    init(){}
    
    private func sumEdgeDistance() -> Double{
        var sum = 0.0
        for (name,edge) in edgesInTour{
            sum += edge.euclideanDistance!
        }
        return sum
    }
    
    var description: String {
        return "\(length)"
    }
    
}
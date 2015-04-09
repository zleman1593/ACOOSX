
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
    //Alpha and beta are stored so the lazy property can be run
    var alpha: Double!
    var beta: Double!
    lazy var euclideanDistance: Double!  = { [unowned self] in
        
        //calculating distance by euclidean formula
        let x = self.cityALocation.x - self.cityBLocation.x
        let y = self.cityALocation.y - self.cityBLocation.y
        var dist = pow(x,2)+pow(y,2)
        return sqrt(dist)
        }()
    
    var initialPheromoneConcentration: Double! {
        didSet {
            currentPheromoneConcentration = initialPheromoneConcentration
        }
    }
    var currentPheromoneConcentration: Double!
    var name: String {
        return "\(cityA):\(cityB)"
    }
    
    
    init(cityA: Int, cityB: Int,cityALocation: Point2D, cityBLocation: Point2D,alpha:Double, beta:Double){
        
        self.cityA = cityA
        self.cityB = cityB
        self.cityALocation = cityALocation
        self.cityBLocation = cityBLocation
        self.alpha = alpha
        self.beta = beta
    }
    
    
    func probability(denominator: Double) -> Double  {
        return self.probNumerator / denominator
    }
    
    var probNumerator: Double {
        return pow(self.currentPheromoneConcentration,self.alpha)*pow(1/self.euclideanDistance,self.beta)
        
    }
    
    /*Returns the city that is on the other side of the edge from the city the ant is currently at*/
    func cityToMoveTo(currentCity:Int) -> Int! {
        
        if currentCity != cityB{
            return cityB
        } else {
            return cityA
        }
    }
    
    
    
    
    
}
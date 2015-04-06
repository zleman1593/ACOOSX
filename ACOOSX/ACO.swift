//
//  ACO.swift
//  AntColonyOptimization
//
//  Created by Zackery leman on 4/5/15.
//  Copyright (c) 2015 Zleman. All rights reserved.
//

import Foundation

class ACO  {
    
    var ants: [Ant]!
    var edges: [String:Edge]!
    var algorithm: String!
    var cities: [Point2D] = []
    var alpha: Double!
    var beta: Double!
    
    init(fileContents:[Point2D], algorithm:String,numberOfAnts:Int){
        self.cities = fileContents
        self.edges =  makeEdges()
        self.algorithm = algorithm
        self.ants = getAnts(numberOfAnts)
        initIteration()
    }
    
    func runWithSettings(){
        
        start()
    }
    
    private func start(){
        
        //Main loop
        for index in 0...10 {
            //Construct Solution
            for ant in ants {
                //Find all the cities the ant can move to given its initial starting city
                var remainingCities = ant.remainingCities.map {CityWithProb(edge: self.edges["\(ant.currentCity):\($0)"]!, alpha:self.alpha,beta:self.beta)}
                // Calculate the denominator
                var denominator = remainingCities.reduce(0, {$0.probNumerator + $1.probNumerator})
                //Now loop and modify these incremtally
                while ant.remainingCities.count != 0 {
                let (selectedEdge, indexForRemoval) = remainingCities.pickElementWithProbability() as? (CityWithProb,Int)
               
                denominator -= remainingCities[indexForRemoval].probNumerator
                ant.edgesUsed["\(ant.currentCity):\($0)"] =
                remainingCities.removeAtIndex(indexForRemoval)
                ant.remainingCities.removeAtIndex(indexForRemoval)//This is prob uncessary
                //Update the ants current city
                    ant.currentCity =
                }
                
            }
            //update phermones
            
            
            
        }
    }
    
    private struct CityWithProb: SortableByProbability {
        
        lazy var probability: Double = {
            return self.probNumerator/1.0
        }()
        
        init(edge:Edge, alpha: Double,beta:Double){
            self.edge = edge
            self.alpha = alpha
            self.beta = beta
        }
        var edge: Edge!
        lazy var probNumerator: Double! = {
            if let city  = self.edge {
                return pow(self.edge.currentPheromoneConcentration,self.alpha)*pow(1/self.edge.euclideanDistance!,self.beta)
            }
            }()
        var city: Int! {
            if let cityB  = edge.cityB {
                return cityB
            }
        }
        var alpha: Double!
        var beta: Double!
        
    }
    
    

    
    
    
    func makeEdges() -> [String:Edge]{
        var edgeDict:[String:Edge] = [:]
        
        for var a = 0; a < cities.count; a++ {
            
            for var b = a + 1; b < cities.count; b++ {
                
                edgeDict["\(a):\(b)"] = Edge(cityA: a,cityB: b,cityALocation: cities[a],cityBLocation: cities[b])
            }
        }
        return edgeDict
    }
    
    
    
    func getAnts(numberOfAnts: Int) ->[Ant]{
        var ants: [Ant] = []
        for index in 1...numberOfAnts{
            ants.append(Ant())
        }
        return ants
    }
    
    func initIteration(){
        //randomizeAntStartLocation
        for index in 0...ants.count - 1 {
            let randomStart = arc4random_uniform(UInt32(cities.count))
            ants[index].currentCity = Int(randomStart)
            ants[index].remainingCities = intArraywithRange(0, max: cities.count, except: ants[index].currentCity)
            
        }
        
    }
    
    
    func intArraywithRange(min: Int, max: Int, except:Int) -> [Int]{
        
        var array:[Int] = []
        
        
        for var i = min; i < max; i++ {
            if  i != except {
                array.append(i)
            }
        }
        return array
    }
    
    
}

extension Array {

    
    func pickElementWithProbability()-> (SortableByProbability,Int){
        
        return
    }
}

protocol SortableByProbability{
    
     var probability: Double { get }
}


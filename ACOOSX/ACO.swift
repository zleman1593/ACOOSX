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
    var rho: Double!
    var elitismFactor: Double!
    
    init(fileContents:[Point2D], algorithm:String,numberOfAnts:Int){
        self.cities = fileContents
        self.edges =  makeEdges()
        self.algorithm = algorithm
        self.ants = getAnts(numberOfAnts)
    }
    
    func runWithSettings(alpha:Double,beta:Double,rho:Double,elitismFactor:Double){
        self.alpha = alpha
        self.beta = beta
        self.rho = rho
        self.elitismFactor = elitismFactor
        // init tau naught
        //Get epsilon
        
        initPheromone()
        start()
    }
    
    //This needs to be rewrriten to use greedy-----------------------------
    private func initPheromone(){
        for (_,edge) in edges {
            edge.currentPheromoneConcentration = 1
        }
    }
    
    private func start(){
        var bestTour: Tour?
        
        //Main loop
        for index in 0...40 {
            initIteration()
            //Construct Solution
            //Create a dictionary of EdgeWithProbability objects so that ants can reuse the calculations from previosu ants.  (Dynamic Programming)
            var edgeDictForIteration: [String:EdgeWithProbability] = [:]
      
            for ant in ants {

                while ant.remainingCities.count != 0 {
                    
                    //Find all the edges the ant can move along given its initial starting city and possible available cities
                    var remainingCities = ant.remainingCities.map {[unowned self] (var nextCity: Int) -> EdgeWithProbability in
                        var cityA = ant.currentCity
                        var cityB = nextCity
                        if cityA > cityB {
                            let temp = cityB
                            cityB = cityA
                            cityA = temp
                            
                        }
                        
                        if let edgeAlreadyUsed = edgeDictForIteration["\(cityA):\(cityB)"]{
                            return edgeAlreadyUsed
                        } else {
                            let city =  EdgeWithProbability(edge: self.edges["\(cityA):\(cityB)"]!, alpha:self.alpha,beta:self.beta)
                            
                            //Add the edge to the dictionary (Dynamic Programming)
                            edgeDictForIteration["\(city.edge.name)"] = city
                            return city
                        }
                    }
                    
                    let (selectedEdge, indexForRemoval) = pickElementWithProbability(remainingCities,denominator: denominator(remainingCities))!
                    
                    var cityA = ant.currentCity
                    var cityB = selectedEdge.cityToMoveTo(cityA)
                    
                    if cityA > cityB {
                        let temp = cityB
                        cityB = cityA
                        cityA = temp
                        
                    }
                    
                    ant.currentTour.edgesInTour["\(cityA):\(cityB)"] = selectedEdge.edge
                    ant.remainingCities.removeAtIndex(indexForRemoval)
                    //Update the ants current city
                    ant.currentCity = selectedEdge.cityToMoveTo(ant.currentCity)
                }
                
                
                //Update best Tour
                if let best = bestTour{
                    if best.length > ant.currentTour.length {
                        bestTour =  ant.currentTour
                    }
                } else{
                    bestTour =  ant.currentTour
                }
                
            }
            
        }
        //update phermones for EAS
        for (name, edge) in edges {
            var concentration =  edge.currentPheromoneConcentration * (1-rho)
            for ant in ants {
                if ant.currentTour.edgesInTour[name] != nil{
                    concentration += 1 /  ant.currentTour.length
                }
            }
            if bestTour!.edgesInTour[name] != nil{
                concentration += 1 /  bestTour!.length * elitismFactor
            }
            edge.currentPheromoneConcentration = concentration
        }
        
        println(bestTour!.description)
    }
    
    /*Sums the nummerators to create the denominator*/
    private func denominator(edges: [EdgeWithProbability]) -> Double{
        var sum = 0.0
        for edge in edges{
            if edge.probNumerator.isInfinite {
                print("Infinity error")
            }
            sum += edge.probNumerator
        }
        if sum.isInfinite {
            print("Infinity error")
        }
        return sum
    }
    
    
    /*This struture is created for use during all ants for a single iteration*/
    private class EdgeWithProbability {
        //Alpha and beta are stored so the lazy property can be run
        var alpha: Double!
        var beta: Double!
        
        //The edge
        var edge: Edge!
        
        init(edge:Edge, alpha: Double,beta:Double){
            self.edge = edge
            self.alpha = alpha
            self.beta = beta
        }
        
        func probability(denominator: Double) -> Double  {
            return self.probNumerator / denominator
        }
        
        lazy var probNumerator: Double! = {
            if let city  = self.edge {
                return pow(self.edge.currentPheromoneConcentration,self.alpha)*pow(1/self.edge.euclideanDistance,self.beta)
            }
            return nil
            }()
        
        /*Returns the city that is on the other side of the edge from the city the ant is currently at*/
        func cityToMoveTo(currentCity:Int) -> Int! {
            
            if currentCity != edge.cityB{
                return edge.cityB
            } else {
                return edge.cityA
            }
        }
        
        
        
    }
    
 
    
    private func makeEdges() -> [String:Edge]{
        var edgeDict:[String:Edge] = [:]
        
        for var a = 0;  a < cities.count;  a++ {
            
            for var b = a + 1;  b < cities.count;  b++ {
                
                edgeDict["\(a):\(b)"] = Edge(cityA: a,cityB: b,cityALocation: cities[a],cityBLocation: cities[b])
            }
        }
        return edgeDict
    }
    
    
    
    private func getAnts(numberOfAnts: Int) ->[Ant]{
        var ants: [Ant] = []
        for index in 1...numberOfAnts{
            ants.append(Ant())
        }
        return ants
    }
    
    
    private func initIteration(){
        //randomizeAntStartLocation
        for index in 0..<ants.count  {
            ants[index].currentCity =  Int(arc4random_uniform(UInt32(cities.count)))
            ants[index].remainingCities = initArraywithRange(0, max: cities.count, except: ants[index].currentCity)
            ants[index].currentTour = Tour()
        }
    }
    
    /*Creates an array of integers within a given range exclsuign a single value*/
    private func initArraywithRange(min: Int, max: Int, except:Int) -> [Int]{
        
        var array:[Int] = []
        
        for var i = min;  i < max;  i++ {
            if  i != except {
                array.append(i)
            }
        }
        return array
    }
    
    
    private func pickElementWithProbability(arrayToBeSelectedFrom:[EdgeWithProbability],denominator: Double)-> (EdgeWithProbability,Int)?{
        
        //generate one random number  betwen 0 and 1
        let arc4randoMax:Double = 0x100000000
        let upper = 1.0
        let lower = 0.0
        let randomNumber = (Double(arc4random()) / arc4randoMax) * (upper - lower) + lower
        
        // Initialize two range indices that bracket probability ranges
        var cumulativeProbabilityLag = 0.0
        var cumulativeProbabilityLead = arrayToBeSelectedFrom.first!.probability(denominator) //proability of first edge in array
        
        for (var i = 0;  i < arrayToBeSelectedFrom.count;  i++) {
            
            // If random value is within the range indicated by the two indices then return
            if (randomNumber >= cumulativeProbabilityLag) && (randomNumber < cumulativeProbabilityLead) {
                return (arrayToBeSelectedFrom[i],i)
            }
            // lead position becomes the lag position
            cumulativeProbabilityLag = cumulativeProbabilityLead
            
            // New lead is old lead position plus additional probability of the next individual
            if i < arrayToBeSelectedFrom.count - 1 {
                cumulativeProbabilityLead += arrayToBeSelectedFrom[i+1].probability(denominator)
            } else {
                return (arrayToBeSelectedFrom[i],i)
            }
            
        }
        return nil
    }
    
    
}





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
    var epsilon:Double!
    var iterations: Int!
    var delegate:ACODelegate!
    var bestTour: Tour?
    var queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
    let group = dispatch_group_create()
    
    init(fileContents:[Point2D], algorithm:String,numberOfAnts:Int){
        self.cities = fileContents
        self.edges =  makeEdges()
        self.algorithm = algorithm
        self.ants = getAnts(numberOfAnts)
        
    }
    
    func runWithSettings(alpha:Double,beta:Double,rho:Double,elitismFactor:Double,epsilon:Double,iterations:Int){
        self.alpha = alpha
        self.beta = beta
        self.rho = rho
        self.elitismFactor = elitismFactor
        self.epsilon = epsilon
        self.iterations = iterations
        
        if algorithm == "ACS" {
            initPheromoneForACS()
        }else{
            initPheromoneForEAS()
        }
        
        start()
    }
    
    
    private func start(){
        
        
        //Main loop
        for index in 0...iterations {
            initIteration()
            //Construct Solution
            
            
            /*Multithread the Elitist Ant System but not the Ant Colony System,
            * since the tour of one ant has to update the edges,
            * which will affect the  behaviour of the subsequent ants*/
            if algorithm == "EAS" {
                
                dispatch_group_async(group, queue) { [unowned self] in
                    // Some asynchronous work
                    for index in  0..<self.ants.count/4{
                        self.runAnts(self.ants[index])
                    }
                }
                dispatch_group_async(group, queue) { [unowned self] in
                    // Some asynchronous work
                    for index in  self.ants.count/4..<self.ants.count/2{
                        self.runAnts(self.ants[index])
                    }
                }
                dispatch_group_async(group, queue) { [unowned self] in
                    // Some asynchronous work
                    for index in  self.ants.count/2..<(self.ants.count * 3) / 4{
                        self.runAnts(self.ants[index])
                    }
                }
                dispatch_group_async(group, queue) { [unowned self] in
                    // Some asynchronous work
                    for index in ((self.ants.count * 3) / 4)..<self.ants.count {
                        self.runAnts(self.ants[index])
                    }
                }
                
                // When you cannot make any more forward progress,
                // wait on the group to block the current thread.
                dispatch_group_wait(group, DISPATCH_TIME_FOREVER)
                
                // Release the group when it is no longer needed.
                // dispatch_release(group)
                
                
            } else {
                for index in 0..<self.ants.count {
                    self.runAnts(self.ants[index])
                }
            }
            
            
            
            
            //update phermones
            for (name, edge) in edges {
                //For Both
                var concentration =  edge.currentPheromoneConcentration * (1-rho)
                //For EAS
                for ant in ants {
                    if ant.currentTour.edgesInTour[name] != nil{
                        concentration += 1 /  ant.currentTour.length
                    }
                }
                
                if bestTour!.edgesInTour[name] != nil{
                    //For EAS
                    if algorithm == "EAS"{
                        concentration += ( 1 /  bestTour!.length ) * elitismFactor
                        //For ACS
                    }else{
                        concentration += ( 1 /  bestTour!.length ) * rho
                    }
                }
                
                edge.currentPheromoneConcentration = concentration
            }
            
            println(bestTour!.description)
            //Update View
            delegate.updateScreenState(bestTour!)
        }
        
    }
    
    /*Sums the nummerators to create the denominator*/
    private func denominator(edges: [Edge]) -> Double{
        var sum = 0.0
        for edge in edges{
            if edge.probNumerator.isInfinite {
                print("Infinity error")
            }
            sum += edge.probNumerator
        }
        return sum
    }
    
    
       
    
    private func makeEdges() -> [String:Edge]{
        var edgeDict:[String:Edge] = [:]
        
        for var a = 0;  a < cities.count;  a++ {
            
            for var b = a + 1;  b < cities.count;  b++ {
                
                edgeDict["\(a):\(b)"] = Edge(cityA: a,cityB: b,cityALocation: cities[a],cityBLocation: cities[b],alpha:alpha,beta:beta)
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
    
    
    private func pickElementWithProbability(arrayToBeSelectedFrom:[Edge],denominator: Double)-> (Edge,Int)?{
        
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
    
    
    //For ACS this inits the phermone level
    private func initPheromoneForEAS(){
        for (_,edge) in edges {
            edge.currentPheromoneConcentration = 1
        }
    }
    
    private func initPheromoneForACS(){
        //Init a Greedy Ant
        let greedyAnt = Ant()
        greedyAnt.currentCity =  Int(arc4random_uniform(UInt32(cities.count)))
        greedyAnt.remainingCities = initArraywithRange(0, max: cities.count, except: greedyAnt.currentCity)
        greedyAnt.currentTour = Tour()
        
        while greedyAnt.remainingCities.count != 0 {
            
            //Find all the edges the ant can move along given its initial starting city and possible available cities
            let remainingCities = greedyAnt.remainingCities.map {[unowned self] (var nextCity: Int) -> Edge in
                
                let (cityA,cityB) = self.swapIfNeeded(greedyAnt.currentCity,cityB: nextCity)
            
                return  self.edges["\(cityA):\(cityB)"]!
                
            }
            
            let (selectedEdge, indexForRemoval) = pickEdgeWithShortestDistance(remainingCities)
            var cityA = greedyAnt.currentCity
            var cityB = selectedEdge.cityToMoveTo(cityA)
            
            //Swap city names if needed to get correct dict entry where name follows format of "less cty value: greater city value"
            if cityA > cityB {
                let temp = cityB
                cityB = cityA
                cityA = temp
            }
            
            
            
            //Update Greedy ANT
            greedyAnt.currentTour.edgesInTour["\(cityA):\(cityB)"] = selectedEdge
            greedyAnt.remainingCities.removeAtIndex(indexForRemoval)
            greedyAnt.currentCity = selectedEdge.cityToMoveTo(greedyAnt.currentCity)
        }
        
        
        let temp = Double(ants.count) * greedyAnt.currentTour.length
        let tau_o = 1 /  Double(temp)
        for (_,edge) in edges {
            edge.initialPheromoneConcentration = tau_o
        }
    }
    
    private func pickEdgeWithShortestDistance(arrayToBeSelectedFrom:[Edge])->(Edge,Int){
        var currentMin = Double(UInt8.max)
        var selectedEdge: Edge!
        var index = 0
        
        for i in 0..<arrayToBeSelectedFrom.count {
            
            // If random value is within the range indicated by the two indices then return
            if arrayToBeSelectedFrom[i].euclideanDistance < currentMin {
                currentMin = arrayToBeSelectedFrom[i].euclideanDistance
                selectedEdge = arrayToBeSelectedFrom[i]
                index = i
            }
            
        }
        
        return (selectedEdge,index)
    }
    
    //Swap city names if needed to get correct dict entry where name follows format of "less cty value: greater city value"
    private func  swapIfNeeded(var cityA:Int,var cityB:Int)->(Int,Int){
        if cityA > cityB {
            let temp = cityB
            cityB = cityA
            cityA = temp
            return (cityA,cityB)
        }
        return (cityA,cityB)
    }
    
    private func runAnts(ant:Ant){
        
        
        while ant.remainingCities.count != 0 {
            
            //Find all the edges the ant can move along given its initial starting city and possible available cities
            var remainingCities = ant.remainingCities.map {[unowned self] (var nextCity: Int) -> Edge in
                
                
                let (cityA,cityB) = self.swapIfNeeded(ant.currentCity,cityB: nextCity)
               
                return self.edges["\(cityA):\(cityB)"]!
                    
            }
            
            let (selectedEdge, indexForRemoval) = pickElementWithProbability(remainingCities,denominator: denominator(remainingCities))!
            
            var cityA = ant.currentCity
            var cityB = selectedEdge.cityToMoveTo(cityA)
            
            //Swap city names if needed to get correct dict entry where name follows format of "less cty value: greater city value"
            if cityA > cityB {
                let temp = cityB
                cityB = cityA
                cityA = temp
            }
            
            //Update ANT
            ant.currentTour.edgesInTour["\(cityA):\(cityB)"] = selectedEdge
            ant.remainingCities.removeAtIndex(indexForRemoval)
            ant.currentCity = selectedEdge.cityToMoveTo(ant.currentCity)
            
            if algorithm == "ACS"{
                selectedEdge.currentPheromoneConcentration = ((1 - epsilon) * selectedEdge.currentPheromoneConcentration) + (epsilon * selectedEdge.initialPheromoneConcentration)
            }
            
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


protocol ACODelegate {
    
    func updateScreenState(tour:Tour?)
}




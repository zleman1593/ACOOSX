//
//  ViewController.swift
//  AntColonyOptimization
//
//  Created by Zackery leman on 4/5/15.
//  Copyright (c) 2015 Zleman. All rights reserved.
//

import Cocoa

class AntColonyViewController: NSViewController, AntViewDelegate, ACODelegate {
    
    private let filereader = InputFileReader()
    private var fileContents:[Point2D]!
    private var solver: ACO!
    private let maxIteration = Int(INT32_MAX)
    
    //Change these two to switch problems
    private var optimalPathLength = 80450
    private var problemToTest = "d2103"//"eil76"
    
    
    //For tests
    var queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
    let group = dispatch_group_create()
    
    @IBOutlet var theView: AntView!{
        didSet {
            theView.delegate = self
        }
    }
    
    
    private struct Parameters {
        static let rho = 0.7
        static let qo = 0.9
        static let alpha = 1.0
        static let beta = 2.0
        static let fileLocation = "u2152"//problemToTest //"d2103"
        static let algorithm = "EAS"//"EAS"
        static let epsilon = 0.5
        static let iterations = 2000
        static let percentOfOptimalThreshold = 120.0
        static let updateScreenState = true
        
    }
    
    
    private struct ExperimentParameters {
        var rho: Double
        var qo: Double?
        var alpha:Double
        var beta:Double
        var fileLocation: String
        var algorithm: String
        var epsilon: Double?
        var iterations: Int
        var percentOfOptimalThreshold: Double
        var updateScreenState: Bool
        var numberOfAnts: Int
        var elitismFactor:Double?
    }
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
            
            //Load the cities from the file
            self.fileContents = self.filereader.readFrom(self.problemToTest)
            
            //ACS Will run a test on each core------------------------------------------------------
            dispatch_group_async(self.group, self.queue) { [unowned self] in
                // Some asynchronous work
                
                
                //Experiments with Rho------------ 0.01, 0.3, 0.7, 1
                
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.9, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                self.runTest(3,params: ExperimentParameters(rho: 0.01, qo: 0.9, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                self.runTest(3,params: ExperimentParameters(rho: 0.3, qo: 0.9, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                self.runTest(3,params: ExperimentParameters(rho: 1, qo: 0.9, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                
            }
            dispatch_group_async(self.group, self.queue) { [unowned self] in
                // Some asynchronous work
                
                
                
                //Experiments with qo------------ 0.1, 0.3, 0.5, 1 -> 0.9 is done
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.1, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.3, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.5, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 1, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                
                
            }
            dispatch_group_async(self.group, self.queue) { [unowned self] in
                // Some asynchronous work
                
                
                //Experiments with number of ants------------ 5,10 (already done), 25, 50,100
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.9, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 5, elitismFactor: nil))
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.9, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 25, elitismFactor: nil))
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.9, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 50, elitismFactor: nil))
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.9, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 100, elitismFactor: nil))
                
                
                
            }
            dispatch_group_async(self.group, self.queue) { [unowned self] in
                // Some asynchronous work
                
                
                //Experiments with alpha and beta ratio 2:2, 2:1, 1:4------------ (1:2 is done)
                
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.9, alpha: 2.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.9, alpha: 2.0, beta: 1.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: 0.9, alpha: 1.0, beta: 4.0, fileLocation: self.problemToTest, algorithm: "ACS", epsilon: 0.5, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: nil))
                
            }
            
            // When you cannot make any more forward progress,
            // wait on the group to block the current thread.
            dispatch_group_wait(self.group, DISPATCH_TIME_FOREVER)
            
            
            
            //EAS one test at a time because it is already multithreaded-----------------------------------------------------------
            
            
            //Experiments with Rho------------ 0.01, 0.3, 0.7, 1
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: 10))
            self.runTest(3,params: ExperimentParameters(rho: 0.01, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: 10))
            self.runTest(3,params: ExperimentParameters(rho: 0.3, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: 10))
            self.runTest(3,params: ExperimentParameters(rho: 1, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: 10))
            
            //Experiments with e (Elitism factor)------------ 1,10 (already done),50,100
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: 1))
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: 50))
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: 100))
            
            
            //Experiments with number of ants------------ 5,10 (already done), 25, 50,100
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 5, elitismFactor: 10))
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 25, elitismFactor: 10))
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 50, elitismFactor: 10))
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 1.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 100, elitismFactor: 10))
            
            //Experiments with alpha and beta ratio 2:2, 2:1, 1:4------------ (1:2 is done)
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 2.0, beta: 2.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: 10))
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 2.0, beta: 1.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: 10))
            self.runTest(3,params: ExperimentParameters(rho: 0.7, qo: nil, alpha: 1.0, beta: 4.0, fileLocation: self.problemToTest, algorithm: "EAS", epsilon: nil, iterations: self.maxIteration, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10, elitismFactor: 10))
            
            
            //////////-----
            self.problemToTest = "eil76"
            self.optimalPathLength = 538
            //Load the cities from the file
            self.fileContents = self.filereader.readFrom(self.problemToTest)
            
        }
        
    }
    
    private func start(){
        
        //Load the cities from the file
        let fileContents = filereader.readFrom(Parameters.fileLocation)
        //Add Cities to View
        theView.cities = fileContents
        updateScreenState(nil)
        
        //Create an instance of the ACO
        solver = ACO(fileContents: fileContents, algorithm: Parameters.algorithm,numberOfAnts:10,optimalPathLength: optimalPathLength,percentOfOptimalThreshold:Parameters.percentOfOptimalThreshold,updateScreenState: Parameters.updateScreenState)
        
        solver.delegate = self
        
        //Run the ACO with the settings
        solver.runWithSettings(Parameters.alpha, beta: Parameters.beta, rho: Parameters.rho, elitismFactor:  Double(fileContents.count), qo:Parameters.qo,epsilon:Parameters.epsilon, iterations:Parameters.iterations)
    }
    
    
    
    
    private func runTest(trials:Int,params:ExperimentParameters){
        var results: [(time:NSTimeInterval,iterations:Int,percent:Double)] = []
        
        //Add Cities to View
        theView.cities = fileContents
        updateScreenState(nil)
        
        
        for trial in  0..<trials {
            
            //Create an instance of the ACO
            solver = ACO(fileContents: fileContents, algorithm: params.algorithm,numberOfAnts: params.numberOfAnts,optimalPathLength: optimalPathLength,percentOfOptimalThreshold:params.percentOfOptimalThreshold,updateScreenState: true)//DEBUG
            
            solver.delegate = self
            
            //Run the ACO with the settings
            
            
            let result = solver.runWithSettings(params.alpha, beta: Parameters.beta, rho: params.rho, elitismFactor: params.elitismFactor, qo:params.qo,epsilon:params.epsilon, iterations:params.iterations)
            
            results.append(result)
            
            
            
        }
        //Calculate stats and write to file
        write(stats(results,params: params))
        
    }
    
 
    
    
    private func stats(results:[(time:NSTimeInterval,iterations:Int,percent:Double)],params: ExperimentParameters)->[String]{
        
        //let empty = ""
        //var bestIteration:Int
        //let averageIteration = Double(results.reduce(0.0) {$0 + $1.iterations}) / results.count
        let averagePercent = Double(results.reduce(0.0) {$0 + $1.percent}) / Double(results.count)
        let averageTime = results.reduce(0) {$0 + $1.time} / Double(results.count)
        
        
        let elitismFactor = params.elitismFactor ?? -1
        let qo = params.qo ?? -1
        let epsilon = params.epsilon ?? -1
        
        
        var outPut = ["\(params.fileLocation)", "\(params.algorithm)", "\(params.rho)", "\(qo)", "\(params.alpha)","\(params.beta)", "\(epsilon)", "\(params.iterations)", "\(params.percentOfOptimalThreshold)", "\(params.numberOfAnts)","\(elitismFactor)"]
        // outPut.append("\(averageIteration)")
        outPut.append("Results")
        outPut.append("\(averagePercent)")
        outPut.append("\(averageTime)")
        return outPut
    }
    
    
    func getACOInstance() -> ACO{
        return solver
    }
    
    func updateScreenState(tour:Tour?) {
        dispatch_async(dispatch_get_main_queue()) {
            if let bestTour = tour {
                self.theView.bestTour = bestTour
            }
            self.theView.display()
        }
    }
    
    private func write(stats:[String]){
        //Write settings to file
        
        
        var output = reduce(stats, "") { $0.isEmpty ? $1 : "\($0)\n\($1)" }
        
        // get URL to the the documents directory in the sandbox
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        
        // add a filename
        let fileUrl = documentsUrl.URLByAppendingPathComponent("Results\(arc4random()).txt")
        
        // write to it
        output.writeToURL(fileUrl, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    
}


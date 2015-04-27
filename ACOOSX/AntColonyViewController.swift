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
    private let optimalPathLength = 64000
    
    
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
        static let fileLocation = "u2152"//"eil76" //"d2103"
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
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
           self.runTest(1,params: ExperimentParameters(rho: 0.7, qo: 0.9, alpha: 1.0, beta: 2.0, fileLocation: "eil76", algorithm: "EAS", epsilon: 0.5, iterations: 2, percentOfOptimalThreshold: 100, updateScreenState: false, numberOfAnts: 10))
            //self.start()
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
        solver.runWithSettings(Parameters.alpha, beta: Parameters.beta, rho: Parameters.rho, elitismFactor: Double(fileContents.count), qo:Parameters.qo,epsilon:Parameters.epsilon, iterations:Parameters.iterations)
    }
    
    
    
    
    private func runTest(trials:Int,params:ExperimentParameters){
        var results: [(time:NSTimeInterval,iterations:Int,percent:Double)] = []
        //Load the cities from the file
        let fileContents = filereader.readFrom(params.fileLocation)
        //Add Cities to View
        theView.cities = fileContents
        updateScreenState(nil)
        
        
        for trial in  0...trials {
        
            //Create an instance of the ACO
            solver = ACO(fileContents: fileContents, algorithm: params.algorithm,numberOfAnts: params.numberOfAnts,optimalPathLength: optimalPathLength,percentOfOptimalThreshold:params.percentOfOptimalThreshold,updateScreenState: params.updateScreenState)
            
            solver.delegate = self
            
            //Run the ACO with the settings
            
            //_________________MAKE them able to pass nil
            let result = solver.runWithSettings(params.alpha, beta: Parameters.beta, rho: params.rho, elitismFactor: Double(fileContents.count), qo:params.qo!,epsilon:params.epsilon!, iterations:params.iterations)
            
            results.append(result)
            
            
            
        }
        //Calculate stats and write to file
        write(stats(results,params: params))
        
    }
    
    private func write(stats:[String]){
        //Write settings to file
        
        
        var output = reduce(stats, "") { $0.isEmpty ? $1 : "\($0)\n\($1)" }
        
        // get URL to the the documents directory in the sandbox
        let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL
        
        
        // add a filename
        let fileUrl = documentsUrl.URLByAppendingPathComponent("Results:\(arc4random()).txt")
        
        // write to it
        output.writeToURL(fileUrl, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    
    private func stats(results:[(time:NSTimeInterval,iterations:Int,percent:Double)],params: ExperimentParameters)->[String]{
        var outPut = ["\(params.fileLocation)", "\(params.algorithm)", "\(params.rho)", "\(params.qo)", "\(params.alpha)","\(params.beta)", "\(params.epsilon)", "\(params.iterations)", "\(params.percentOfOptimalThreshold)", "\(params.numberOfAnts)"]
        //outPut.apend()
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
    
}


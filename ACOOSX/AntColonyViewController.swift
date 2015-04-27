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
        static let q_o = 0.9
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
        var q_o: Double?
        var alpha:Double
        var beta:Double
        var fileLocation: String
        var algorithm: String
        var epsilon: Double?
        var iterations: Int
        var updateScreenState: Bool
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        write()
        dispatch_async(dispatch_get_global_queue(Int(QOS_CLASS_USER_INITIATED.value), 0)) {
            self.start()
        }
        
    }
    
    func start(){
        
        
        //Load the cities from the file
        let fileContents = filereader.readFrom(Parameters.fileLocation)
        //Add Cities to View
        theView.cities = fileContents
        updateScreenState(nil)
        
        //Create an instance of the ACO
        solver = ACO(fileContents: fileContents, algorithm: Parameters.algorithm,numberOfAnts:10,optimalPathLength: optimalPathLength,percentOfOptimalThreshold:Parameters.percentOfOptimalThreshold,updateScreenState: Parameters.updateScreenState)
        
        solver.delegate = self
        
        //Run the ACO with the settings
        solver.runWithSettings(Parameters.alpha, beta: Parameters.beta, rho: Parameters.rho, elitismFactor: Double(fileContents.count), q_o:Parameters.q_o,epsilon:Parameters.epsilon, iterations:Parameters.iterations)
    }
    
    
    func runTests(trials:Int){
        var results: [(time:NSTimeInterval,iterations:Int,percent:Double)] = []
        //Load the cities from the file
        let fileContents = filereader.readFrom(Parameters.fileLocation)
        //Add Cities to View
        theView.cities = fileContents
        updateScreenState(nil)
        
        
        for trial in  0...trials {
            
            //Create an instance of the ACO
            solver = ACO(fileContents: fileContents, algorithm: Parameters.algorithm,numberOfAnts: 10,optimalPathLength: optimalPathLength,percentOfOptimalThreshold:Parameters.percentOfOptimalThreshold,updateScreenState: Parameters.updateScreenState)
            
            solver.delegate = self
            
            //Run the ACO with the settings
            let result = solver.runWithSettings(Parameters.alpha, beta: Parameters.beta, rho: Parameters.rho, elitismFactor: Double(fileContents.count), q_o:Parameters.q_o,epsilon:Parameters.epsilon, iterations:Parameters.iterations)
            
            results.append(result)
            
            
            
        }
        //Calculate stats and write to file
         write(stats(results))
        
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
    
    func write(statString:String){
    var str = "Statistics"
    
    // get URL to the the documents directory in the sandbox
    let documentsUrl = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0] as! NSURL

    // add a filename
    let fileUrl = documentsUrl.URLByAppendingPathComponent("testing.txt")
    
    // write to it
    str.writeToURL(fileUrl, atomically: true, encoding: NSUTF8StringEncoding, error: nil)
    }
    
    
    func stats(results:[(time:NSTimeInterval,iterations:Int,percent:Double)])->String{
        
        
    }
}


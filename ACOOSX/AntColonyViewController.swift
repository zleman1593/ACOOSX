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
    
    
    @IBOutlet var theView: AntView!{
        didSet {
            theView.delegate = self
        }
    }
    
    
    private struct Parameters {
        static let rho = 0.1
        static let alpha = 1.0
        static let beta = 2.0
        static let fileLocation = "eil76"//"d2103"
        static let algorithm = "EAS"//"EAS"
        static let epsilon = 0.5
        static let iterations = 200
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        solver = ACO(fileContents: fileContents, algorithm: Parameters.algorithm,numberOfAnts: fileContents.count)
        
        solver.delegate = self
        
        //Run the ACO with the settings
        solver.runWithSettings(Parameters.alpha, beta: Parameters.beta, rho: Parameters.rho, elitismFactor: Double(fileContents.count),epsilon:Parameters.epsilon, iterations:Parameters.iterations)
        
    }
    
    
    
    
    func getACOInstance() -> ACO{
        return solver
    }
    
    func updateScreenState(tour:Tour?) {
        if let bestTour = tour {
        theView.bestTour = bestTour
        }
        theView.display()
    }
    
}


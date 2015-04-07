//
//  ViewController.swift
//  AntColonyOptimization
//
//  Created by Zackery leman on 4/5/15.
//  Copyright (c) 2015 Zleman. All rights reserved.
//

import Cocoa

class AntColonyViewController: NSViewController, AntViewDelegate {
    
    private let filereader = InputFileReader()

    private var solver: ACO!
    @IBOutlet var antView: AntView! {
        didSet {
            antView.delegate = self
        }
    }
    

    private struct Parameters {
        static let tau_o = 1.0
        static let rho = 0.1
        static let alpha = 1.0
        static let beta = 2.0
        static let fileLocation = "eil76"//"d2103"
        static let algorithm = "EAS"
        //static let numberOfAnts = 10
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Load the cities from the file
        let fileContents = filereader.readFrom(Parameters.fileLocation)
        
        //Create an instance of the ACO
        solver = ACO(fileContents: fileContents, algorithm: Parameters.algorithm,numberOfAnts: fileContents.count)
        
        //Run the ACO with the settings
        solver.runWithSettings(Parameters.alpha, beta: Parameters.beta, rho: Parameters.rho, elitismFactor: Double(fileContents.count))
        
    }
    
    
    func getACOInstance() -> ACO{
        return solver
    }
    
}


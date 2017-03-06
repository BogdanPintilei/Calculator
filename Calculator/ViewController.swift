
//
//  ViewController.swift
//  Calculator
//
//  Created by Bogdan Pintilei on 2/27/17.
//  Copyright © 2017 Bogdan Pintilei. All rights reserved.
//


/*
 A doua versiune a calculatorului nu merge la fel de bine dar e diferit ca metoda impelmentare,(Pastrat ca exemplu daca am nevoie de ceva)
 */

import UIKit

class ViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInTheMiddleOfTyping{
            if (digit == "."){
                if(display.text!.range(of: ".") == nil){
                    //if the "." already exists in the number it can not add another one
                    display.text = display.text! + "."
                }
                
            }else{
                
                display.text = display.text! + digit
                
            }
            
        } else {
            if (digit != ".")
            {
                display.text = digit
            }
        }
        
        userIsInTheMiddleOfTyping = true
    }
    
    private var displayValue: Double{
        get{
            return Double(display.text!)!
        }
        set{
            display.text = String(newValue)
        }
    }
    
    var savedProgram: CalculatorBrain.PropertyList?
    
    //this part is not needed is just for testing
    @IBAction func save() {
        savedProgram = brain.program
    }
    
    @IBAction func restore() {
        if savedProgram != nil {
            brain.program = savedProgram!
            displayValue = brain.result
        }
    }
    //here the part not needed ends
    
    private var brain = CalculatorBrain()
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping{
            brain.setOperand(operand: displayValue)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle{
            brain.performOperation(symbol: mathematicalSymbol)
        }
        
        displayValue = brain.result

        descriptionLabel.text = brain.description
        
        
    }
}

//
//  ViewController.swift
//  Calculator
//
//  Created by Bogdan Pintilei on 2/27/17.
//  Copyright © 2017 Bogdan Pintilei. All rights reserved.
//

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
    
    private func updateUI() {
        descriptionLabel.text = (brain.description.isEmpty ? " " : brain.getDescription())
        displayValue = brain.result
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            if (digit == ".") {
                if(display.text!.range(of: ".") == nil) {
                    //if the "." symbol already exists in the number it can not add another symbol like it
                    display.text = display.text! + "."
                }
            } else {
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
    
    private var displayValue: Double? {
        get {
            if let text = display.text, let value = NumberFormatter().number(from: text)?.doubleValue {
                return value
            }
            return nil
        }
        set {
            if let value = newValue {
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                formatter.maximumFractionDigits = Constants.Math.numberOfDigitsAfterDecimalPoint
                let valueConverted = NSNumber(value: value)
                display.text = NumberFormatter().string(from: valueConverted)
                descriptionLabel.text = brain.getDescription()
            } else {
                display.text = "0"
                descriptionLabel.text = " "
                userIsInTheMiddleOfTyping = false
            }
        }
    }
    
    @IBAction func getVariable(_ sender: Any) {
        brain.setOperand(Constants.Math.variableName)
        userIsInTheMiddleOfTyping = false
        updateUI()
    }
    
    @IBAction func setVariable(_ sender: Any) {
        brain.variableValues[Constants.Math.variableName] = displayValue
        if userIsInTheMiddleOfTyping {
            userIsInTheMiddleOfTyping = false
        } else {
            brain.Undo()
        }
        
        //Trick with a computed property
        brain.program = brain.program
        updateUI()
    }
    
    private var brain = CalculatorBrain()
    
    //UNDO also works as a backspace
    @IBAction func undo(_ sender: UIButton) {
        guard userIsInTheMiddleOfTyping == true else {
            brain.Undo()
            updateUI()
            return
        }
        guard var number = display.text else {
            return
        }
        number.remove(at: number.index(before: number.endIndex))
        if number.isEmpty {
            number = "0"
            userIsInTheMiddleOfTyping = false
        }
        
        display.text = number
    }
    
    @IBAction private func performOperation(_ sender: UIButton) {
        if userIsInTheMiddleOfTyping {
            brain.setOperand(operand: displayValue!)
            userIsInTheMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        
        updateUI()
    }
}

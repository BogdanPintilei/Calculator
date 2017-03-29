//
//  ViewController.swift
//  Calculator
//
//  Created by Bogdan Pintilei on 2/27/17.
//  Copyright © 2017 Bogdan Pintilei. All rights reserved.
//

import UIKit

class CalculatorViewController: UIViewController
{
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBOutlet weak var graphButton: UIButton!
    
    @IBOutlet private weak var display: UILabel!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    private var userIsInTheMiddleOfTyping = false
    
    private func updateUI() {
        descriptionLabel.text = (brain.description.isEmpty ? " " : brain.getDescription())
        displayValue = brain.result
        //Reflect weather or not is posible to graph
        //what has been entered so far (whether is a partial result or not).
        graphButton.isEnabled = !brain.isPartialResult
        
    }
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        if userIsInTheMiddleOfTyping {
            let textCurrentlyInDisplay = display.text!
            if digit != "." || textCurrentlyInDisplay.range(of: ".") == nil {
                display.text = textCurrentlyInDisplay + digit
            }
        } else {
            if digit == "." {
                display.text = "0."
            } else {
                display.text = digit
            }
            userIsInTheMiddleOfTyping = true
        }
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
                display.text = formatter.string(from: valueConverted)
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
                case "show_Graph":
                    guard !brain.isPartialResult else {
                        NSLog(Constants.Error.partialResult)
                        return
                }
                
                var destinationVC = segue.destination
                    if let nvc = destinationVC as? UINavigationController {
                        destinationVC = nvc.visibleViewController ?? destinationVC
                }
                
                    if let vc = destinationVC as? GraphViewController {
                        vc.navigationItem.title = brain.description
                        vc.function = {
                            (x: CGFloat) -> Double in
                            self.brain.variableValues[Constants.Math.variableName] = Double(x)
                            // Trick with a computed property
                            self.brain.program = self.brain.program
                            return self.brain.result
                        }
                }
            default: break
            }
        }
    }
}

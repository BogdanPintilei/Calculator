//
//  CalculatorBRAIN.swift
//  Calculator
//
//  Created by Bogdan Pintilei on 2/28/17.
//  Copyright © 2017 Bogdan Pintilei. All rights reserved.
//

import Foundation

class CalculatorBrain
{
    private var acumulator: Double = 0.0
    
    private var internalProgram = [AnyObject]()
    
    var variableValues = [String : Double] ()
    
    typealias PropertyList = AnyObject
    
    var program:PropertyList {
        get {
            return internalProgram as CalculatorBrain.PropertyList
        }
        set {
            clear()
            if let arrayofOps = newValue as? [AnyObject] {
                for op in arrayofOps {
                    if let operand = op as? Double {
                        setOperand(operand: operand)
                    } else if let operation = op as? String {
                        performOperation(symbol: operation)
                    } else if let variableName = op as? String {
                        if variableValues[variableName] != nil {
                            setOperand(variableName)
                        }
                    }
                }
            }
        }
    }
    
    private var descriptionAcumulator = "0" {
        didSet {
            if pending == nil {
                currentPrecedence = Precedence.max
            }
        }
    }
    
    private enum Precedence: Int {
        case min = 0, max
    }
    
    private var currentPrecedence = Precedence.max
    
    func setOperand(operand: Double) {
        acumulator = operand
        descriptionAcumulator = String(format: "%g", operand)
        internalProgram.append(operand as AnyObject)
    }
    
    func setOperand(_ variableName: String) {
        variableValues[variableName] = variableValues[variableName] ?? 0.0
        acumulator = variableValues[variableName]!
        descriptionAcumulator = variableName
        internalProgram.append(variableName as AnyObject)
    }
    
    private var operation: Dictionary<String,Operation> = [
        "π" : Operation.Constant(M_PI),//M_PI,
        "e" : Operation.Constant(M_E), //M_E,
        "√" : Operation.UnaryOperation(sqrt,{"√(" + $0 + ")"}), //sqrt,
        "cos" : Operation.UnaryOperation(cos,{"cos(" + $0 + ")"}), //cos
        "sin" : Operation.UnaryOperation(sin,{"sin(" + $0 + ")"}), //sin
        "ln" : Operation.UnaryOperation(log,{"ln(" + $0 + ")"}), //ln
        "x²":Operation.UnaryOperation({pow($0,2)},{"(" + $0 + ")²"}), //pow 2
        "xʸ" : Operation.BinaryOperation(pow, { $0 + " ^ " + $1 }, Precedence.max), // x^y
        "×" : Operation.BinaryOperation(*,{ $0 + "×" + $1},Precedence.max), //multiplication
        "÷" : Operation.BinaryOperation(/,{ $0 + "÷" + $1},Precedence.max), //division
        "+" : Operation.BinaryOperation(+,{ $0 + "+" + $1},Precedence.max), //adition
        "-" : Operation.BinaryOperation(-,{ $0 + "-" + $1},Precedence.max), //subtraction
        "=" : Operation.Equals, // =
        "C" : Operation.Clear,  // clear
        "s" : Operation.Save,   // save
        "r" : Operation.Restore // resotre
    ]
    
    var description: String {
        get {
            if pending == nil {
                return descriptionAcumulator //+ " = "// IF I WANT EQUAL "=" TO SHOW HERE IT IS WHERE I APPEND
            } else {
                return pending!.descriptionFunction(pending!.descriptionOperand,pending!.descriptionOperand != descriptionAcumulator ? descriptionAcumulator : "")
            }
        }
    }
    
    var isPartialResult: Bool {
        get {
            return pending != nil
        }
    }
    
    private enum Operation {
        case Constant(Double)
        case UnaryOperation((Double) ->Double,(String)->String)
        case BinaryOperation((Double,Double)-> Double,(String,String)->String,Precedence)
        case Equals
        case Clear
        case Save
        case Restore
    }
    
    func performOperation(symbol: String) {
        
        internalProgram.append(symbol as AnyObject)
        
        if let operation = operation[symbol] {
            
            switch operation {
                
            case .Constant(let value):
                acumulator = value
                descriptionAcumulator = symbol
                
            case .UnaryOperation(let function,let descriptionFunction):
                acumulator = function(acumulator)
                descriptionAcumulator = descriptionFunction(descriptionAcumulator)
                
            case .BinaryOperation (let function,let descriptionFunction,let precedence):
                executePendingOperation()
                if currentPrecedence.rawValue < precedence.rawValue {
                    descriptionAcumulator = "(" + descriptionAcumulator + ")"
                }
                currentPrecedence = precedence
                pending = PendingBinaryOperationInfo(binaryFunction: function,firstOperand: acumulator,descriptionFunction: descriptionFunction, descriptionOperand: descriptionAcumulator)
                
            case .Equals:
                executePendingOperation()
                
            case .Clear:
                clear()
                
            case .Save:
                Save()
                
            case .Restore:
                Restore()
            }
        }
    }
    
    func clear() {
        acumulator = 0
        descriptionAcumulator = ""
        pending = nil
        internalProgram.removeAll()
        
    }
    
    private var savedProgram: Bool = false
    private var savedAcumulator: Double = 0.0
    private var savedDescriptionAcumulator: String = ""
    
    private func Save () {
        savedProgram = true
        savedAcumulator = acumulator
        savedDescriptionAcumulator = descriptionAcumulator
    }
    
    private func Restore () {
        if savedProgram == true {
            acumulator = savedAcumulator
            descriptionAcumulator = savedDescriptionAcumulator
        }
    }
    
    private func executePendingOperation() {
        if pending != nil{
            acumulator = pending!.binaryFunction(pending!.firstOperand,acumulator)
            descriptionAcumulator = pending!.descriptionFunction(pending!.descriptionOperand,descriptionAcumulator)
            pending = nil
        }
    }
    
    private var pending:PendingBinaryOperationInfo?
    
    private struct PendingBinaryOperationInfo {
        var binaryFunction: (Double,Double)->Double
        var firstOperand: Double
        var descriptionFunction: (String,String)->String
        var descriptionOperand: String
    }
    
    var result: Double {
        get{
            return acumulator
        }
    }
    
    func Undo() {
        if !internalProgram.isEmpty {
            internalProgram.removeLast()
            program = internalProgram as CalculatorBrain.PropertyList
        } else {
            clear()
            descriptionAcumulator = ""
        }
    }
    
    func getDescription() ->String {
        let whiteSpace = (description.hasSuffix(" ") ? "" : " ")
        return isPartialResult ? (description + whiteSpace + "...") : (description + whiteSpace + "=")
    }
}

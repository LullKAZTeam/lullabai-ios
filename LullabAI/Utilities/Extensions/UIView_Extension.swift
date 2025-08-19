//
//  UIView_Extension.swift
//  LivonAI
//
//  Created by Keyur Hirani on 21/08/23.
//

import Foundation
import UIKit

extension UIView {
    
    @IBInspectable
    var cornerRadius: CGFloat {
        get {
            return layer.cornerRadius
        }
        set {
            layer.cornerRadius = newValue
        }
    }
    
    @IBInspectable
    var borderWidth1: CGFloat {
        get {
            return layer.borderWidth
        }
        set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable
    var borderColor: UIColor? {
        get {
            if let color = layer.borderColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.borderColor = color.cgColor
            } else {
                layer.borderColor = nil
            }
        }
    }
    
    @IBInspectable
    var shadowRadius: CGFloat {
        get {
            return layer.shadowRadius
        }
        set {
            layer.shadowRadius = newValue
        }
    }
    
    @IBInspectable
    var shadowOpacity: Float {
        get {
            return layer.shadowOpacity
        }
        set {
            layer.shadowOpacity = newValue
        }
    }
    
    @IBInspectable
    var shadowOffset1: CGSize {
        get {
            return layer.shadowOffset
        }
        set {
            layer.shadowOffset = newValue
        }
    }
    
    @IBInspectable
    var shadowColor1: UIColor? {
        get {
            if let color = layer.shadowColor {
                return UIColor(cgColor: color)
            }
            return nil
        }
        set {
            if let color = newValue {
                layer.shadowColor = color.cgColor
            } else {
                layer.shadowColor = nil
            }
        }
    }
}
extension UIView {
    func addSwipeRecognizer(direction: UISwipeGestureRecognizer.Direction, target: Any, action: Selector) {
        let recognizer = UISwipeGestureRecognizer(target: target, action: action)
        recognizer.direction = direction
        addGestureRecognizer(recognizer)
    }
    
    func addSwipeRecognizer(target: Any, left: Selector? = nil, right: Selector? = nil, up: Selector? = nil, down: Selector? = nil) {
        if let left  { addSwipeRecognizer(direction: .left,  target: target, action: left)  }
        if let right { addSwipeRecognizer(direction: .right, target: target, action: right) }
        if let up    { addSwipeRecognizer(direction: .up,    target: target, action: up)    }
        if let down  { addSwipeRecognizer(direction: .down,  target: target, action: down)  }
    }
    
    func addTapRecognizer(tapNumber: Int, target: Any, action: Selector) {
        let tap = UITapGestureRecognizer(target: target, action: action)
        tap.numberOfTapsRequired = tapNumber
        addGestureRecognizer(tap)
        isUserInteractionEnabled = true
    }
}

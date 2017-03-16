//
//  CircleButton.swift
//  TalkToMe
//
//  Created by Mike Barone on 2017-03-15.
//  Copyright © 2017 Mike Barone. All rights reserved.
//

import UIKit

@IBDesignable
class CircleButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 30.0 {
        didSet {
            setUpView()
        }
    }
    
    override func prepareForInterfaceBuilder() {
        setUpView()
    }
    
    func setUpView() {
        layer.cornerRadius = cornerRadius
    }
}

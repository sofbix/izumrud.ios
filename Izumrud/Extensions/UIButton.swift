//
//  UIButton.swift
//  SamaraCounter
//
//  Created by Sergey Balalaev on 25.10.2021.
//

import UIKit


extension UIButton {
    
    static func createOnView(title: String, target: Any?, action: Selector) -> UIView
    {
        let foother = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        foother.backgroundColor = .clear
        
        let btSend = UIButton(frame: CGRect(x: 20, y: 10, width: 60, height: 40))
        btSend.layer.cornerRadius = 8
        btSend.backgroundColor = Settings.Color.brand
        btSend.setTitleColor(.white, for: .normal)
        btSend.setTitleColor(.yellow, for: .highlighted)
        btSend.setTitle(title, for: .normal)
        btSend.addTarget(target, action: action, for: .touchUpInside)
        
        foother.addSubview(btSend)
        btSend.translatesAutoresizingMaskIntoConstraints = false
        btSend.leadingAnchor.constraint(equalTo: foother.leadingAnchor, constant: 20).isActive = true
        btSend.trailingAnchor.constraint(equalTo: foother.trailingAnchor, constant: -20).isActive = true
        btSend.topAnchor.constraint(equalTo: foother.topAnchor, constant: 10).isActive = true
        btSend.bottomAnchor.constraint(equalTo: foother.bottomAnchor, constant: -30).isActive = true
        btSend.widthAnchor.constraint(equalToConstant: 60).isActive = true
        btSend.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        return foother
    }
    
}

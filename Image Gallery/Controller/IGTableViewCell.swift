//
//  IGTableViewCell.swift
//  Image Gallery
//
//  Created by Кирилл Афонин on 23/04/2019.
//  Copyright © 2019 krrl. All rights reserved.
//

import UIKit

class IGTableViewCell: UITableViewCell, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField! {
        didSet{
            textField.delegate = self
            let tap = UITapGestureRecognizer(target: self, action: #selector(activate))
            tap.numberOfTapsRequired = 2
            addGestureRecognizer(tap)
        }
    }
    
    @objc private func activate() {
        textField.isEnabled = true
        textField.becomeFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.isEnabled = false
        textField.resignFirstResponder()
        return true
    }
    
    var resignationHandler: (() -> Void)?
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        resignationHandler?()
    }

}

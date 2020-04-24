//
//  FAQViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 21.02.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

class FAQViewController: UIViewController {
    
    //MARK: - Override
    
    //MARK: viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    //MARK: - Transition menu tapped
    @IBAction private func workerMenuTapped(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissedBy: transitionDismissButton)
    }
    
    //MARK: - Transition confirm
    @IBAction func transitionConfirm(_ sender: UIButton) {
        guard let title = sender.currentTitle,
               let view = transitionView,
               let constraint = transitionViewLeftConstraint,
               let button = transitionDismissButton else {return}
               
        transitionPerform(by: title, for: view, with: constraint, dismiss: button)
    }
    
    
    //MARK: Transition dismiss
    @IBAction private func transitionDismissTapped(_ sender: UIButton) {
        slideInTransitionMenu(for: transitionView, constraint: transitionViewLeftConstraint, dismissedBy: transitionDismissButton)
    }
    
    
    
    //MARK: - Private Implementation
    
    //MARK: View
    @IBOutlet private weak var transitionView: UIView!
    
    //MARK: Button
    @IBOutlet private weak var transitionDismissButton: UIButton!
    
    //MARK:Constraint
    @IBOutlet private weak var transitionViewLeftConstraint: NSLayoutConstraint!
    
}









//MARK: - Extension

//MARK: - For Overrides
private extension FAQViewController {
    
    //MARK: Для ViewDidLoad
    func forViewDidLoad() {
    }
    
}


//MARK: -



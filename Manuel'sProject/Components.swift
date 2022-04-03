//
//  Components.swift
//  Manuel'sProject
//
//  Created by Manuel González Bernáldez on 1/4/22.
//

import UIKit

func blur(controller:UIViewController?,
          blurEffectView:UIVisualEffectView,
          activityIndicator:UIActivityIndicatorView) {
    
    guard let controller = controller else { return }
    blurEffectView.effect = UIBlurEffect(style: .systemUltraThinMaterial)
    blurEffectView.frame = controller.view.bounds
    blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    controller.view.addSubview(blurEffectView)
    
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
    activityIndicator.hidesWhenStopped = true
    controller.view.addSubview(activityIndicator)
    activityIndicator.startAnimating()
    
    NSLayoutConstraint.activate([
        activityIndicator.centerXAnchor.constraint(equalTo: controller.view.centerXAnchor),
        activityIndicator.centerYAnchor.constraint(equalTo: controller.view.centerYAnchor)
    ])
}

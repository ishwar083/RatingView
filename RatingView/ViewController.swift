//
//  ViewController.swift
//  RatingView
//
//  Created by mac-00014 on 30/03/19.
//  Copyright © 2019 Mind. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var vwRating : RatingView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        vwRating.delegate = self
        //vwRating.rating = 0
    }
}

extension ViewController : RatingViewDelegate {
    
    func ratingView(_ ratingView: RatingView, didUpdate rating: Float) {
    
        print("Current Rating = \(rating)")
    }
    func ratingView(_ ratingView: RatingView, isUpdating rating: Float) {
        print("Updating Rating = \(rating)")
    }
}

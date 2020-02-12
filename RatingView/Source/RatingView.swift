//
//  RatingView.swift
//  RatingView
//
//  Created by mac-00014 on 30/03/19.
//  Copyright © 2019 Mind. All rights reserved.
//

import UIKit

@objc public protocol RatingViewDelegate {
    /**
     Returns the rating value when touch events end
     */
    func ratingView(_ ratingView: RatingView, didUpdate rating: Float)
    
    /**
     Returns the rating value as the user pans
     */
    @objc optional func ratingView(_ ratingView: RatingView, isUpdating rating: Float)
}


open class RatingView: UIView {
    
    // MARK: Properties
    
    open weak var delegate: RatingViewDelegate?
    
    /**
     empty image views
     */
    fileprivate var imageView: UIImageView?
    
    /**
     image view content mode.
     */
    var imageContentMode: UIView.ContentMode = .scaleAspectFit
    
    
    /**
     Set the empty image
     */
    var currentImage: UIImage? {
        didSet {
            // Update empty image view
            imageView?.image = currentImage
        }
    }
    
    var imageArray: [UIImage]? {
        
        didSet {
            // Update empty image view
            currentImage = imageArray?.first
        }
    }
    
    /**
     Sets the full image that is overlayed on top of the empty image.
     Should be same size and shape as the empty image.
     */
    @IBInspectable open var imageName: String? {
        
        didSet {
            
            if let imgArray = fromGif(resourceName: imageName) as? [UIImage] {
                imageArray = imgArray
            }
            // Update image view
            
            
        }
    }
        
    /**
     Minimum rating.
     */
    var minRating: Int  = 1 {
        didSet {
            // Update current rating if needed
            if rating < Float(minRating) {
                rating = Float(minRating)
                
            }
        }
    }
    
    /**
     Max rating value.
     */
    
    @IBInspectable open var maxRating: Int = 5 {
        didSet {
            if maxRating != oldValue {
            }
        }
    }
    
    /**
     Set the current rating.
     */
    @IBInspectable open var rating: Float = 0 {
        didSet {
            
            guard  let count = imageArray?.count else {
                return
            }
            
            if Int(rating) < minRating {
                rating = Float(minRating)
            }
            
            // per rating index like 131/5 = 26.2 indexes for each rating
            let perRatingIndex = Float(count) / Float(maxRating)
            
            let index = Int(round((rating * perRatingIndex)))
            guard index <= count - 1  else{
                currentImage = imageArray?[count - 1]
                return
            }
            currentImage = imageArray?[index]
        }
    }
    
    /**
     Sets whether or not the rating view can be changed by panning.
     */
    @IBInspectable open var editable: Bool = true
    
    // MARK: Initializations
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        
        initImageView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initImageView()
    }
    
    fileprivate func initImageView() {
        
        guard imageView == nil else {
            return
        }
        
        // Add new image view
        let emptyImageView = UIImageView()
        emptyImageView.contentMode = imageContentMode
        emptyImageView.image = currentImage
        addSubview(emptyImageView)
        self.imageView = emptyImageView
    }
    
    // MARK: UIView
    
    // Override to calculate ImageView frames
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        guard let imageView = self.imageView else {
            return
        }
        imageView.frame = self.bounds
    }
    
      // MARK: Helper methods
    
    func fromGif(resourceName: String?) -> [Any]? {
        
        guard let resourceName = resourceName else {
            return nil
        }
        
        guard let path = Bundle.main.path(forResource: resourceName, ofType: "gif") else {
            return nil
        }
        let url = URL(fileURLWithPath: path)
        guard let gifData = try? Data(contentsOf: url),
            let source =  CGImageSourceCreateWithData(gifData as CFData, nil) else { return nil }
        var images = [UIImage]()
        let imageCount = CGImageSourceGetCount(source)
        for i in 0 ..< imageCount {
            if let image = CGImageSourceCreateImageAtIndex(source, i, nil) {
                images.append(UIImage(cgImage: image))
            }
        }
        return images
    }
    
    // Calculates new rating based on touch location in view
    fileprivate func updateLocation(_ touch: UITouch) {
        
        guard editable else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        guard let imageView = imageView else {
            return
        }
        
        guard touchLocation.x > imageView.frame.origin.x else {
            return
        }
        
        guard let count = imageArray?.count  else{
            return
        }
        
        let width = self.bounds.width
        let x = touchLocation.x + CGFloat((width / CGFloat(maxRating)) / 2)
        
        let index = Int(x / width * CGFloat(count))
        
        // per rating index like 131/5 = 26.2 indexes for each rating
        let perRatingIndex = Float(count) / Float(maxRating)
        let newRating: Float = Float(index) / perRatingIndex
        
        // Check min rating
        rating = newRating < Float(minRating) ? Float(minRating) : newRating
        
        // Update delegate
        delegate?.ratingView?(self, isUpdating: rating)
        
        guard  index <= count - 1  else{
            return
        }

        currentImage = imageArray?[index]
        
    }
    
    
    // Calculates new rating based on touch location in view
    fileprivate func endUpdateLocation(_ touch: UITouch) {
        
        guard editable else {
            return
        }
        
        let touchLocation = touch.location(in: self)
        
        guard let imageView = imageView else {
            return
        }
        
        guard touchLocation.x > imageView.frame.origin.x else {
            
            // touch go beyond from imageview bounds
            
            rating = Float(minRating)
            return
        }
        
        
        guard  let count = imageArray?.count else {
            return
        }
        
        let width = self.bounds.width
        let x = touchLocation.x + CGFloat((width / CGFloat(maxRating)) / 2)
        
        let index = Int(x / width * CGFloat(count))
        
        // per rating index like 131/5 = 26.2 indexes for each rating
        let perRatingIndex = Float(count) / Float(maxRating)
        
        let newRating: Float = round(Float(index) / perRatingIndex)
        
        // Check min rating
        rating = newRating < Float(minRating) ? Float(minRating) : newRating
        
        delegate?.ratingView(self, didUpdate: rating)
        
    }
    
    // MARK: Touch events
    
    override open func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard let touch = touches.first else {
//            return
//        }
       // updateLocation(touch)
    }
    
    override open func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        updateLocation(touch)
    }
    
    override open func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Update delegate
        guard let touch = touches.first else {
            return
        }
        endUpdateLocation(touch)
        
    }
    
    override open func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Update delegate
        delegate?.ratingView(self, didUpdate: rating)
    }
}

//
//  GSHipHopPageControl.swift
//  JumpingPageControl
//
//  Created by Gurdeep Singh on 12/01/16.
//  Copyright © 2016 Gurdeep Singh. All rights reserved.
//

import UIKit

@IBDesignable
class GSHipHopPageControl: UIControl {
    
    @IBInspectable var animationEnabled : Bool = true
    
    @IBInspectable var numberOfPages : Int = 3 {
        
        didSet {
            
            if numberOfPages < 0 {
                numberOfPages = 0
            }
            
            for pageIndicator in pageIndicators {
                pageIndicator.removeFromSuperlayer()
            }
            
            pageIndicators.removeAll(keepCapacity: false)
            
            if numberOfPages < 1 {
                numberOfPages = 1
            }
            
            for i in 0..<numberOfPages {
                
                var pageIndicator : IndicatorLayer!
                
                if  i == currentPage {

                    pageIndicator = CurrentPageIndicatorLayer()
                    pageIndicators.append(pageIndicator)
                    pageIndicator.frame = CGRectZero
                
                } else {
                
                    pageIndicator = PageIndicatorLayer()
                    pageIndicators.append(pageIndicator)
                    pageIndicator.frame = CGRectZero
                }
                
                self.layer.addSublayer(pageIndicator)
            }
            
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var currentPage : Int = 0 {
        
        didSet {
            
            if oldValue == currentPage {
                return
            }
            
            if currentPage > numberOfPages-1 {
                currentPage = numberOfPages-1
                
            } else if currentPage < 0 {
                currentPage = 0
            }
            
            let t = pageIndicators[oldValue]
            pageIndicators[oldValue] = pageIndicators[currentPage]
            pageIndicators[currentPage] = t
            

            let yPosition : CGFloat = self.layer.bounds.height/2
            
            let oldPosition = pageIndicators[currentPage].position
            let newPosition = pageIndicators[oldValue].position
            
            pageIndicators[currentPage].position = newPosition
            pageIndicators[oldValue].position = oldPosition

            if !animationEnabled {
                
                pageIndicators[currentPage].removeAllAnimations()
                pageIndicators[oldValue].removeAllAnimations()
                
            } else if oldPosition.x > 0 {
                
                let path1 = UIBezierPath()
                path1.moveToPoint(newPosition)
                let cp1 = CGPointMake((oldPosition.x+newPosition.x)/2, yPosition+20)
                path1.addQuadCurveToPoint(oldPosition, controlPoint: cp1)
                
                let animation1 = CAKeyframeAnimation(keyPath: "position")
                animation1.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                animation1.duration = 0.3
                animation1.path = path1.CGPath
                
                pageIndicators[oldValue].addAnimation(animation1, forKey: nil)

                let path2 = UIBezierPath()
                path2.moveToPoint(oldPosition)
                let cp2 = CGPointMake((oldPosition.x+newPosition.x)/2, yPosition-10)
                path2.addQuadCurveToPoint(newPosition, controlPoint: cp2)
                
                let animation2 = CAKeyframeAnimation(keyPath: "position")
                animation2.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
                animation2.duration = 0.25
                animation2.path = path2.CGPath
                
                pageIndicators[currentPage].addAnimation(animation2, forKey: nil)
                
            }
            
            self.sendActionsForControlEvents(UIControlEvents.ValueChanged)
            
        }
        
    }
    
    @IBInspectable var color : UIColor = UIColor(red: 248.0/255.0, green: 162.0/255.0, blue: 30.0/255.0, alpha: 1.0) {
        
        didSet {
            
            for pageIndicator in pageIndicators {
                pageIndicator.indicatorTintColor = color.CGColor
            }
            
            self.setNeedsLayout()
        }
    }
    
    @IBInspectable var indicatorRadius : CGFloat = 8.0 {
        
        didSet {
            
            if indicatorRadius.isSignMinus {
                indicatorRadius = 0
            }
            
            for pageIndicator in pageIndicators {
                pageIndicator.indicatorRadius = indicatorRadius
            }
            
            self.setNeedsLayout()
        }
        
    }
    
    @IBInspectable var gap : CGFloat = 6 {
        
        didSet {
            
            if gap.isSignMinus {
                gap = 0
            }
            
            self.setNeedsLayout()
        }
    }
    
    private var pageIndicators = [IndicatorLayer]()
//    private var currentPageIndicator = CurrentPageIndicatorLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setupSubviews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setupSubviews()
    }
    
    private func setupSubviews() {
        
        self.clipsToBounds = false
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.clipsToBounds = false
        
        self.backgroundColor = UIColor.clearColor()
        
        let positionY : CGFloat = self.layer.bounds.height/2
        
        let indicatorDiameter = indicatorRadius*2
        
        let totalWidth = (indicatorDiameter * pageIndicators.count.toCGFloat) + (gap * (pageIndicators.count-1).toCGFloat)
        let startX = (self.bounds.width - totalWidth)/2 + indicatorRadius
                
        for i in 0..<pageIndicators.count {
            
            let pageIndicator = pageIndicators[i]
            
            let positionX = startX + i.toCGFloat*(indicatorDiameter+gap)
            
            pageIndicator.position = CGPointMake(positionX, positionY)
            
            pageIndicator.setNeedsLayout()
        }
        
    }
    
    override func endTrackingWithTouch(touch: UITouch?, withEvent event: UIEvent?) {
        
        super.endTrackingWithTouch(touch, withEvent: event)
        
        guard let touchPoint = touch?.locationInView(self) else {   return  }
        
        let currentPageIndicator = pageIndicators[currentPage]
        
        if touchPoint.x > currentPageIndicator.position.x + gap + indicatorRadius && (currentPage < numberOfPages-1) {
            
            currentPage++
            
        } else if touchPoint.x < currentPageIndicator.position.x - gap - indicatorRadius && (currentPage > 0) {
            
            currentPage--
        }
        
    }
    
}


extension Int {

    var toCGFloat : CGFloat {
        return CGFloat(self)
    }
}




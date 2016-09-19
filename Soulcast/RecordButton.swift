//
//  RecordButton.swift
//  Instant
//
//  Created by Samuel Beek on 21/06/15.
//  Copyright (c) 2015 Samuel Beek. All rights reserved.
//
import Foundation
import UIKit
//import QuartzCore

enum RecordButtonState : Int {
    case Standby // 0
    case RecordingStarted // 1
    case RecordingLongEnough // 2
    case Finished // 3
    case MutedDuringPlayBack //4
    case Failed //5
}

class RecordButton : UIButton {
    
    var buttonColor = offBlue{
        didSet {
            circleLayer.backgroundColor = buttonColor.CGColor
            circleBorder.borderColor = buttonColor.CGColor
        }
    }
    var progressColor = offRed {
        didSet {
            print("progressColor set to red")
            gradientMaskLayer.colors = [progressColor.CGColor, progressColor.CGColor]
        }
    }
    
    /// Closes the circle and hides when the RecordButton is finished
    var closeWhenFinished: Bool = false
    
    private var buttonState : RecordButtonState = .Standby {
        didSet {
            switch buttonState {
            case .Standby:
                self.alpha = 1.0
                currentProgress = 0
                setProgress(0)
                setRecording(false)
                print("RecordButton is Standby")
            case .RecordingStarted:
                self.alpha = 1.0
                setRecording(true)
                print("RecordButton is RecordingStarted")
            case .MutedDuringPlayBack:
                self.alpha = 0.2
                 print("RecordButton is MutedDuringPlayBack")
            case .RecordingLongEnough:
                finishingRecording()
                 print("RecordButton is RecordingLongEnough")
            case .Finished:
                resetSuccess()
                 print("RecordButton is Finished")
            default:
                //print("oldValue: \(oldValue.hashValue), state: \(state.hashValue)")
                assert(false, "OOPS!!!")
            }
        }
        
    }
    
    private var circleLayer: CALayer!
    private var circleBorder: CALayer!
    private var progressLayer: CAShapeLayer!
    private var gradientMaskLayer: CAGradientLayer!
    private var currentProgress: CGFloat! = 0
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        
        self.drawButton()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func drawButton() {
        
        self.backgroundColor = UIColor.clearColor()
        let layer = self.layer
        circleLayer = CALayer()
        circleLayer.backgroundColor = buttonColor.CGColor
        
        let size: CGFloat = self.frame.size.width / 1.5
        circleLayer.bounds = CGRectMake(0, 0, size, size)
        circleLayer.anchorPoint = CGPointMake(0.5, 0.5)
        circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds))
        circleLayer.cornerRadius = size / 2
        layer.insertSublayer(circleLayer, atIndex: 0)
        
        circleBorder = CALayer()
        circleBorder.backgroundColor = UIColor.clearColor().CGColor
        circleBorder.borderWidth = 1
        circleBorder.borderColor = buttonColor.CGColor
        circleBorder.bounds = CGRectMake(0, 0, self.bounds.size.width - 1.5, self.bounds.size.height - 1.5)
        circleBorder.anchorPoint = CGPointMake(0.5, 0.5)
        circleBorder.position = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds))
        circleBorder.cornerRadius = self.frame.size.width / 2
        layer.insertSublayer(circleBorder, atIndex: 0)
        
        let startAngle: CGFloat = CGFloat(M_PI) + CGFloat(M_PI_2)
        let endAngle: CGFloat = CGFloat(M_PI) * 3 + CGFloat(M_PI_2)
        let centerPoint: CGPoint = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2)
        gradientMaskLayer = self.gradientMask()
        progressLayer = CAShapeLayer()
        progressLayer.path = UIBezierPath(arcCenter: centerPoint, radius: self.frame.size.width / 2 - 2, startAngle: startAngle, endAngle: endAngle, clockwise: true).CGPath
        progressLayer.backgroundColor = UIColor.clearColor().CGColor
        progressLayer.fillColor = nil
        progressLayer.strokeColor = UIColor.blackColor().CGColor
        progressLayer.lineWidth = 4.0
        progressLayer.strokeStart = 0.0
        progressLayer.strokeEnd = 0.0
        gradientMaskLayer.mask = progressLayer
        layer.insertSublayer(gradientMaskLayer, atIndex: 0)
    }
    
    private func setRecording(recording: Bool) {
        
        let duration: NSTimeInterval = 0.15
        circleLayer.contentsGravity = "center"
        
        let scale = CABasicAnimation(keyPath: "transform.scale")
        scale.fromValue = recording ? 1.0 : 0.88
        scale.toValue = recording ? 0.88 : 1
        scale.duration = duration
        scale.fillMode = kCAFillModeForwards
        scale.removedOnCompletion = false
        
        let color = CABasicAnimation(keyPath: "backgroundColor")
        color.duration = duration
        color.fillMode = kCAFillModeForwards
        color.removedOnCompletion = false
        color.toValue = recording ? progressColor.CGColor : buttonColor.CGColor
        
        let circleAnimations = CAAnimationGroup()
        circleAnimations.removedOnCompletion = false
        circleAnimations.fillMode = kCAFillModeForwards
        circleAnimations.duration = duration
        circleAnimations.animations = [scale, color]
        
        let borderColor: CABasicAnimation = CABasicAnimation(keyPath: "borderColor")
        borderColor.duration = duration
        borderColor.fillMode = kCAFillModeForwards
        borderColor.removedOnCompletion = false
        borderColor.toValue = recording ? UIColor(red: 0.83, green: 0.86, blue: 0.89, alpha: 1).CGColor : buttonColor
        
        let borderScale = CABasicAnimation(keyPath: "transform.scale")
        borderScale.fromValue = recording ? 1.0 : 0.88
        borderScale.toValue = recording ? 0.88 : 1.0
        borderScale.duration = duration
        borderScale.fillMode = kCAFillModeForwards
        borderScale.removedOnCompletion = false
        
        let borderAnimations = CAAnimationGroup()
        borderAnimations.removedOnCompletion = false
        borderAnimations.fillMode = kCAFillModeForwards
        borderAnimations.duration = duration
        borderAnimations.animations = [borderColor, borderScale]
        
        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = recording ? 0.0 : 1.0
        fade.toValue = recording ? 1.0 : 0.0
        fade.duration = duration
        fade.fillMode = kCAFillModeForwards
        fade.removedOnCompletion = false
        
        circleLayer.addAnimation(circleAnimations, forKey: "circleAnimations")
        progressLayer.addAnimation(fade, forKey: "fade")
        circleBorder.addAnimation(borderAnimations, forKey: "borderAnimations")
        
    }
    
    private func gradientMask() -> CAGradientLayer {
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.0, 1.0]
        let topColor = progressColor
        let bottomColor = progressColor
        gradientLayer.colors = [topColor.CGColor, bottomColor.CGColor]
        return gradientLayer
    }
    
    override func layoutSubviews() {
        circleLayer.anchorPoint = CGPointMake(0.5, 0.5)
        circleLayer.position = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds))
        circleBorder.anchorPoint = CGPointMake(0.5, 0.5)
        circleBorder.position = CGPointMake(CGRectGetMidX(self.bounds),CGRectGetMidY(self.bounds))
        super.layoutSubviews()
    }
    
    func startProgress() {
        self.buttonState = .RecordingStarted
    }
    
    
    func shakeInDenial(){
        let animation = CABasicAnimation()
        animation.duration = 0.1
        animation.repeatCount = 4
        animation.fromValue = -10
        animation.toValue = 0
        
        self.layer.addAnimation(animation, forKey:"transform.translation.x")
    }
    
    func tintLongEnough() {
        //TODO:
        print("tintLongEnough()")
    }
    /**
     Set the relative length of the circle border to the specified progress
     
     - parameter newProgress: the relative lenght, a percentage as float.
     */
    func resetSuccess() {
        self.buttonState = .Standby
    }
    
    func resetFail() {
        //TODO: do something different
        self.buttonState = .Standby
    }
    
    func setProgress(newProgress: CGFloat) {
        /*
         [CATransaction setDisableActions:YES];
         myLayer.strokeEnd = 0.5;
         [CATransaction setDisableActions:NO];
 */
        CATransaction.setDisableActions(true)
        progressLayer.strokeEnd = newProgress
        CATransaction.setDisableActions(false)
    }
    
    func mute() {
         self.buttonState = .MutedDuringPlayBack
    }
    func finishingRecording(){
        self.buttonState = .Finished
    }
    
}

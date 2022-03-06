//
//  ScratchCardImageView.swift
//  ScratchCard
//
//  Created by David Grigoryan on 06.03.2022.
//

import UIKit

protocol ScratchCardImageViewDelegate: AnyObject {
    func scratchCardImageViewContentPresentedCompletly(_ scratchCardImageView: ScratchCardImageView)
}

extension ScratchCardImageViewDelegate {
    func scratchCardImageViewContentPresentedCompletly(_ scratchCardImageView: ScratchCardImageView) {}
}

struct ScratchCardPoint {
    let x: Int
    let y: Int
}

extension ScratchCardPoint: Hashable {}

class ScratchCardImageView: UIImageView {
    
    private var erasedPoints = Set<ScratchCardPoint>()
    private var lastPoint: CGPoint?
    
    var innerView: UIView!
    var lineType: CGLineCap = .round
    var lineWidth: CGFloat = 15
    weak var delegate: ScratchCardImageViewDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        isUserInteractionEnabled = true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard  let touch = touches.first else { return }
        lastPoint = touch.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let point = lastPoint else { return }
        
        let currentLocation = touch.location(in: self)
        let innerViewRelativePoint = convert(currentLocation, to: innerView)
        let erasedPoint = ScratchCardPoint(x: Int(innerViewRelativePoint.x),
                                         y: Int(innerViewRelativePoint.y))
        
        if innerView.bounds.contains(innerViewRelativePoint) {
            if !erasedPoints.contains(erasedPoint) {
                for i in -Int(lineWidth)...Int(lineWidth) {
                    for j in -Int(lineWidth)...Int(lineWidth) {
                        let xPos = min(max(0, erasedPoint.x - (i * -1)), Int(innerView.bounds.width))
                        let yPos = min(max(0, erasedPoint.y - (j * -1)), Int(innerView.bounds.height))
                        let point = ScratchCardPoint(x: xPos, y: yPos)
                        erasedPoints.insert(point)
                    }
                }
            }
        }
        
        let faultValue = 100
        if erasedPoints.count + faultValue >= Int(innerView.bounds.height * innerView.bounds.width) {
            delegate?.scratchCardImageViewContentPresentedCompletly(self)
        }
        
        lastPoint = currentLocation
        eraseBetween(fromPoint: point, currentPoint: currentLocation)
    }
    
    private func eraseBetween(fromPoint: CGPoint, currentPoint: CGPoint) {
    
        UIGraphicsBeginImageContext(self.frame.size)
        
        image?.draw(in: self.bounds)
        
        let path = CGMutablePath()
        path.move(to: fromPoint)
        path.addLine(to: currentPoint)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setShouldAntialias(true)
        context?.setLineCap(lineType)
        context?.setLineWidth(lineWidth)
        context?.setBlendMode(.clear)
        context?.addPath(path)
        context?.strokePath()
        
        image = UIGraphicsGetImageFromCurrentImageContext()
  
        UIGraphicsEndImageContext()
    }
}

public extension UIImage {
    func imageResize(sizeChange: CGSize) -> UIImage{
        
        let hasAlpha = true
        let scale: CGFloat = 0.0
        
        UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
        self.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        return scaledImage!
    }
}

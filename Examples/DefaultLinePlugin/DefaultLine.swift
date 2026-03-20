import DrawingSDK
import SwiftUI

struct DefaultLine: Drawable {
    var startPoint: CGPoint
    var endPoint: CGPoint
    var color: Color
    var fillColor: Color
    var lineWidth: CGFloat
    var isFilled: Bool
    
    func path() -> Path {
        var path = Path()
       path.move(to: startPoint)
       path.addLine(to: endPoint)
       return path
    }
    
    func contains(_ point: CGPoint) -> Bool {
        let radius: CGFloat = 10
                        
        let dx = endPoint.x - startPoint.x
        let dy = endPoint.y - startPoint.y
        let l2 = dx*dx + dy*dy
        
        if l2 == 0 {
            return sqrt(pow(point.x - startPoint.x, 2) + pow(point.y - startPoint.y, 2)) < radius
        }
        var t = ((point.x - startPoint.x) * dx + (point.y - startPoint.y) * dy) / l2
        t = max(0, min(1, t))

        let projection = CGPoint(
            x: startPoint.x + t * dx,
            y: startPoint.y + t * dy
        )

        let distance = sqrt(pow(point.x - projection.x, 2) + pow(point.y - projection.y, 2))
        
        return distance < radius
    }
    
    mutating func move(by offset: CGSize) {
        startPoint.x += offset.width
        startPoint.y += offset.height
        endPoint.x += offset.width
        endPoint.y += offset.height
    }
}

@objc(DefaultLinePlugin)
public class DefaultLinePlugin: NSObject ,DrawingPlugin {
    public var name: String = "Линия"
    public var iconName: String = "line.diagonal"
    
    public func create(at point: CGPoint, color: Color, width: CGFloat, filled: Bool, fillColor: Color) -> any Drawable {
        return DefaultLine(startPoint: point, endPoint: point, color: color, fillColor: fillColor, lineWidth: width, isFilled: filled)
    }
    
    public func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable {
        guard var line = shape as? DefaultLine else { return shape }
        line.endPoint = point
        return line
    }
    
    public required override init() {
        super.init()
    }
}

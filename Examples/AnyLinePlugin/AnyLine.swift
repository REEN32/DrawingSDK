import DrawingSDK
import SwiftUI

struct AnyLine: Drawable {
    var points: [CGPoint]
    var color: Color
    var lineWidth: CGFloat
    
    func path() -> Path {
        var path = Path()
        path.addLines(points)
        return path
    }
    
    func contains(_ point: CGPoint) -> Bool {
        for p in points {
            if point.x - 10 <= p.x, p.x <= point.x + 10 && point.y - 10 <= p.y, p.y <= point.y + 10 {
                return true
            }
        }
        return false
    }
    
    mutating func move(by offset: CGSize) {
        for i in points.indices {
            points[i].x += offset.width
            points[i].y += offset.height
        }
    }
}

@objc(AnyLinePlugin)
public class AnyLinePlugin: NSObject, DrawingPlugin {
    public var name: String = "pen"
    public var iconName: String = "pencil"
    
    public func create(at point: CGPoint, color: Color, width: CGFloat) -> any Drawable {
        return AnyLine(points: [point], color: color, lineWidth: width)
    }
    
    public func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable {
        var line = shape as! AnyLine
        line.points.append(point)
        return line
    }
}

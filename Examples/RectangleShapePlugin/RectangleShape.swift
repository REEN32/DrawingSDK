import DrawingSDK
import SwiftUI

struct RectangleShape: Drawable {
    var startPoint: CGPoint
    var endPoint: CGPoint
    var color: Color
    var lineWidth: CGFloat
    
    func path() -> Path {
        var path = Path()
        path.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        path.addLine(to: CGPoint(x: endPoint.x, y: startPoint.y))
        path.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        path.addLine(to: CGPoint(x: startPoint.x, y: endPoint.y))
        path.closeSubpath()
        return path
    }
    
    func contains(_ point: CGPoint) -> Bool {
        let rect = self.path().boundingRect
        return rect.insetBy(dx: -10, dy: -10).contains(point)
    }
    
    mutating func move(by offset: CGSize) {
        startPoint.x += offset.width
        endPoint.x += offset.width
        startPoint.y += offset.height
        endPoint.y += offset.height
    }
}

@objc(RectangleShapePlugin)
public class RectangleShapePlugin: NSObject, DrawingPlugin {
    public var name: String = "Прямоугольник"
    public var iconName: String = "rectangle"
    
    public required override init() {
        super.init()
    }
    
    public func create(at point: CGPoint, color: Color, width: CGFloat) -> any Drawable {
        return RectangleShape(startPoint: point, endPoint: point, color: color, lineWidth: width)
    }
    
    public func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable {
        guard var rect = shape as? RectangleShape else { return shape }
        rect.endPoint = point
        return rect
    }
}

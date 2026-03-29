import DrawingSDK
import SwiftUI

struct RectangleShape: Drawable {
    var id: UUID = UUID()
    var startPoint: CGPoint
    var endPoint: CGPoint
    var color: Color
    var fillColor: Color
    var lineWidth: CGFloat
    var isFilled: Bool
    var layerID: UUID
    
    var height: CGFloat {
        abs(startPoint.y - endPoint.y)
    }
    
    var width: CGFloat {
        abs(startPoint.x - endPoint.x)
    }
    var rotation: CGFloat
    
    func path() -> Path {
        var path = Path()
        path.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        path.addLine(to: CGPoint(x: endPoint.x, y: startPoint.y))
        path.addLine(to: CGPoint(x: endPoint.x, y: endPoint.y))
        path.addLine(to: CGPoint(x: startPoint.x, y: endPoint.y))
        path.closeSubpath()
        return path
    }
    
    func selectionPath() -> Path {
        let path = self.path().boundingRect.insetBy(dx: -5 - (self.lineWidth / 2), dy: -5 - (self.lineWidth / 2))
        return Path(path)
    }
    
    func fillPath() -> Path {
        let path = self.path().boundingRect.insetBy(dx: (self.lineWidth / 2), dy: (self.lineWidth / 2))
        return Path(path)
    }
    
    func contains(_ point: CGPoint) -> Bool {
        let rect = self.path().boundingRect
        return rect.insetBy(dx: -10 - (self.lineWidth / 2), dy: -10 - (self.lineWidth / 2)).contains(point)
    }
    
    mutating func move(by offset: CGSize) {
        startPoint.x += offset.width
        endPoint.x += offset.width
        startPoint.y += offset.height
        endPoint.y += offset.height
    }
    
    mutating func resize(xOffset: CGFloat, yOffset: CGFloat) {
        startPoint.x -= xOffset / 2
        endPoint.x += xOffset / 2
        startPoint.y -= yOffset / 2
        endPoint.y += yOffset / 2
    }
}

@objc(RectangleShapePlugin)
public class RectangleShapePlugin: NSObject, DrawingPlugin {
    public var name: String = "Прямоугольник"
    public var iconName: String = "rectangle"
    
    public required override init() {
        super.init()
    }
    
    public func create(at point: CGPoint, color: Color, width: CGFloat, rotationAngle: CGFloat, filled: Bool, fillColor: Color, layerID: UUID) -> any Drawable {
        return RectangleShape(startPoint: point, endPoint: point, color: color, fillColor: fillColor, lineWidth: width, isFilled: filled, layerID: layerID, rotation: rotationAngle)
    }
    
    public func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable {
        guard var rect = shape as? RectangleShape else { return shape }
        rect.endPoint = point
        return rect
    }
}

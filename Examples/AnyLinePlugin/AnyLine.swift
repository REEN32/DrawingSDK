import DrawingSDK
import SwiftUI

struct AnyLine: Drawable {
    var typeName: String { "pencil" }
    
    var id: UUID = UUID()
    var points: [CGPoint]
    
    private var _color: CodableColor
    private var _fillColor: CodableColor
    
    var color: Color {
        get { _color.swiftUIColor }
        set { _color = CodableColor(newValue) }
    }
    
    var fillColor: Color {
        get { _fillColor.swiftUIColor }
        set { _fillColor = CodableColor(newValue) }
    }
    
    var lineWidth: CGFloat
    var isFilled: Bool
    var layerID: UUID
    var rotation: CGFloat
    
    init(id: UUID = UUID(), points: [CGPoint], color: Color, fillColor: Color, lineWidth: CGFloat, isFilled: Bool, layerID: UUID, rotation: CGFloat) {
        self.id = id
        self.points = points
        self._color = CodableColor(color)
        self._fillColor = CodableColor(fillColor)
        self.lineWidth = lineWidth
        self.isFilled = isFilled
        self.layerID = layerID
        self.rotation = rotation
    }

    func path() -> Path {
        var path = Path()
        if let firstPoint = points.first {
            path.move(to: firstPoint)
            path.addLines(points)
        }
        return path
    }
    
    func selectionPath() -> Path {
        let rect = self.path().boundingRect.insetBy(dx: -5 - (lineWidth/2), dy: -5 - (lineWidth/2))
        return Path(rect)
    }
    
    func fillPath() -> Path {
        return path()
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
    
    mutating func resize(xOffset: CGFloat, yOffset: CGFloat) {
        let rect = path().boundingRect
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        let scaleX = rect.width == 0 ? 1 : (rect.width + xOffset) / rect.width
        let scaleY = rect.height == 0 ? 1 : (rect.height + yOffset) / rect.height
        
        for i in points.indices {
            points[i].x = center.x + (points[i].x - center.x) * scaleX
            points[i].y = center.y + (points[i].y - center.y) * scaleY
        }
    }
    
    var width: CGFloat { path().boundingRect.width }
    var height: CGFloat { path().boundingRect.height }
}

@objc(AnyLinePlugin)
public class AnyLinePlugin: NSObject, DrawingPlugin {
    public var name: String = "Карандаш"
    public var iconName: String = "pencil"
    
    public required override init() {
        super.init()
        ShapeRegistry.shared.register(AnyLine.self, for: "pencil")
    }
    
    public func create(at point: CGPoint, color: Color, width: CGFloat, rotationAngle: CGFloat, filled: Bool, fillColor: Color, layerID: UUID) -> any Drawable {
        return AnyLine(points: [point], color: color, fillColor: fillColor, lineWidth: width, isFilled: filled, layerID: layerID, rotation: rotationAngle)
    }
    
    public func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable {
        guard var line = shape as? AnyLine else { return shape }
        line.points.append(point)
        return line
    }
}

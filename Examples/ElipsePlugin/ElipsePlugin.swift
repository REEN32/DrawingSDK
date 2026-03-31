import DrawingSDK
import SwiftUI

struct EllipseShape: Drawable {
    var typeName: String { "ellipse" }
    
    var id: UUID = UUID()
    var startPoint: CGPoint
    var endPoint: CGPoint
    
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
    
    init(id: UUID = UUID(), startPoint: CGPoint, endPoint: CGPoint, color: Color, fillColor: Color, lineWidth: CGFloat, isFilled: Bool, layerID: UUID, rotation: CGFloat) {
        self.id = id
        self.startPoint = startPoint
        self.endPoint = endPoint
        self._color = CodableColor(color)
        self._fillColor = CodableColor(fillColor)
        self.lineWidth = lineWidth
        self.isFilled = isFilled
        self.layerID = layerID
        self.rotation = rotation
    }

    private var rect: CGRect {
        CGRect(
            x: min(startPoint.x, endPoint.x),
            y: min(startPoint.y, endPoint.y),
            width: abs(startPoint.x - endPoint.x),
            height: abs(startPoint.y - endPoint.y)
        )
    }

    func path() -> Path {
        var path = Path()
        path.addEllipse(in: rect)
        return path
    }
    
    func selectionPath() -> Path {
        let selectionRect = rect.insetBy(dx: -5 - (lineWidth / 2), dy: -5 - (lineWidth / 2))
        return Path(selectionRect)
    }
    
    func fillPath() -> Path {
        let fillRect = rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2)
        var path = Path()
        path.addEllipse(in: fillRect)
        return path
    }
    
    func contains(_ point: CGPoint) -> Bool {
        let boundingPreview = rect.insetBy(dx: -10, dy: -10)
        guard boundingPreview.contains(point) else { return false }
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let rx = rect.width / 2 + 10
        let ry = rect.height / 2 + 10
        
        if rx <= 0 || ry <= 0 { return false }
        
        let dx = point.x - center.x
        let dy = point.y - center.y
        
        return (dx * dx) / (rx * rx) + (dy * dy) / (ry * ry) <= 1.0
    }
    
    mutating func move(by offset: CGSize) {
        startPoint.x += offset.width
        startPoint.y += offset.height
        endPoint.x += offset.width
        endPoint.y += offset.height
    }
    
    mutating func resize(xOffset: CGFloat, yOffset: CGFloat) {
        startPoint.x -= xOffset / 2
        endPoint.x += xOffset / 2
        startPoint.y -= yOffset / 2
        endPoint.y += yOffset / 2
    }
    
    var width: CGFloat { rect.width }
    var height: CGFloat { rect.height }
}


@objc(EllipsePlugin)
public class EllipsePlugin: NSObject, DrawingPlugin {
    public var name: String = "Эллипс"
    public var iconName: String = "circlebadge"
    
    public required override init() {
        super.init()
        ShapeRegistry.shared.register(EllipseShape.self, for: "ellipse")
    }
    
    public func create(at point: CGPoint, color: Color, width: CGFloat, rotationAngle: CGFloat, filled: Bool, fillColor: Color, layerID: UUID) -> any Drawable {
        return EllipseShape(
            startPoint: point,
            endPoint: point,
            color: color,
            fillColor: fillColor,
            lineWidth: width,
            isFilled: filled,
            layerID: layerID,
            rotation: rotationAngle
        )
    }
    
    public func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable {
        guard var ellipse = shape as? EllipseShape else { return shape }
        ellipse.endPoint = point
        return ellipse
    }
}

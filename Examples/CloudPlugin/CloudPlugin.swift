import DrawingSDK
import SwiftUI

struct CloudShape: Drawable {
    var typeName: String { "cloud" }
    
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
        let r = rect
        if r.width == 0 || r.height == 0 { return path }
        
        let center = CGPoint(x: r.midX, y: r.midY)
        let rx = r.width / 2
        let ry = r.height / 2
        
        let segments = 12
        let angleIncrement = CGFloat.pi * 2.0 / CGFloat(segments)
        
        let bubbleRadius = sqrt(r.width * r.height) / CGFloat(segments / 2)
        
        for i in 0..<segments {
            let angle = CGFloat(i) * angleIncrement
            let bubbleCenter = CGPoint(
                x: center.x + rx * cos(angle),
                y: center.y + ry * sin(angle)
            )
            path.addEllipse(in: CGRect(x: bubbleCenter.x - bubbleRadius,
                                       y: bubbleCenter.y - bubbleRadius,
                                       width: bubbleRadius * 2,
                                       height: bubbleRadius * 2))
        }
        
        return path
    }
    
    func selectionPath() -> Path {
        let rect = path().boundingRect.insetBy(dx: -10 - (lineWidth/2), dy: -10 - (lineWidth/2))
        return Path(rect)
    }
    
    func fillPath() -> Path {
        return path()
    }
    
    func contains(_ point: CGPoint) -> Bool {
        let boundingRect = path().boundingRect.insetBy(dx: -10, dy: -10)
        guard boundingRect.contains(point) else { return false }
        
        return path().contains(point)
    }
    
    mutating func move(by offset: CGSize) {
        startPoint.x += offset.width
        startPoint.y += offset.height
        endPoint.x += offset.width
        endPoint.y += offset.height
    }
    
    mutating func resize(xOffset: CGFloat, yOffset: CGFloat) {
        endPoint.x += xOffset
        endPoint.y += yOffset
    }
    
    var width: CGFloat { rect.width }
    var height: CGFloat { rect.height }
}

@objc(CloudPlugin)
public class CloudPlugin: NSObject, DrawingPlugin {
    public var name: String = "Думающее облачко"
    public var iconName: String = "cloud"
    
    public required override init() {
        super.init()
        ShapeRegistry.shared.register(CloudShape.self, for: "cloud")
    }
    
    public func create(at point: CGPoint, color: Color, width: CGFloat, rotationAngle: CGFloat, filled: Bool, fillColor: Color, layerID: UUID) -> any Drawable {
        return CloudShape(
            startPoint: point,
            endPoint: CGPoint(x: point.x + 1, y: point.y + 1),
            color: color,
            fillColor: fillColor,
            lineWidth: width,
            isFilled: filled,
            layerID: layerID,
            rotation: rotationAngle
        )
    }
    
    public func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable {
        guard var bubble = shape as? CloudShape else { return shape }
        bubble.endPoint = point
        return bubble
    }
}

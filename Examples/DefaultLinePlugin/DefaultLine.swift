import DrawingSDK
import SwiftUI

struct DefaultLine: Drawable {
    var typeName: String { "defaultLine" }
    
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

    func path() -> Path {
        var path = Path()
        path.move(to: startPoint)
        path.addLine(to: endPoint)
        return path
    }
    
    func selectionPath() -> Path {
        let rect = path().boundingRect.insetBy(dx: -10, dy: -10)
        return Path(rect)
    }
    
    func fillPath() -> Path {
        return path()
    }
    
    func contains(_ point: CGPoint) -> Bool {
        let radius: CGFloat = 10 + (lineWidth / 2)
        
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
    
    mutating func resize(xOffset: CGFloat, yOffset: CGFloat) {
        let midX = (startPoint.x + endPoint.x) / 2
        let midY = (startPoint.y + endPoint.y) / 2
        
        let currentWidth = abs(startPoint.x - endPoint.x)
        let currentHeight = abs(startPoint.y - endPoint.y)
        
        let scaleX = currentWidth == 0 ? 1 : (currentWidth + xOffset) / currentWidth
        let scaleY = currentHeight == 0 ? 1 : (currentHeight + yOffset) / currentHeight
        
        startPoint.x = midX + (startPoint.x - midX) * scaleX
        endPoint.x = midX + (endPoint.x - midX) * scaleX
        startPoint.y = midY + (startPoint.y - midY) * scaleY
        endPoint.y = midY + (endPoint.y - midY) * scaleY
    }
    
    var width: CGFloat { abs(startPoint.x - endPoint.x) }
    var height: CGFloat { abs(startPoint.y - endPoint.y) }
}


@objc(DefaultLinePlugin)
public class DefaultLinePlugin: NSObject, DrawingPlugin {
    public var name: String = "Линия"
    public var iconName: String = "line.diagonal"
    
    public required override init() {
        super.init()
        ShapeRegistry.shared.register(DefaultLine.self, for: "defaultLine")
    }
    
    public func create(at point: CGPoint, color: Color, width: CGFloat, rotationAngle: CGFloat, filled: Bool, fillColor: Color, layerID: UUID) -> any Drawable {
        return DefaultLine(startPoint: point, endPoint: point, color: color, fillColor: fillColor, lineWidth: width, isFilled: filled, layerID: layerID, rotation: rotationAngle)
    }
    
    public func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable {
        guard var line = shape as? DefaultLine else { return shape }
        line.endPoint = point
        return line
    }
}

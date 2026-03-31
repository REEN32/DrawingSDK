import DrawingSDK
import SwiftUI

struct PentagonShape: Drawable {
    var typeName: String { "pentagon" }
    
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
    
    var width: CGFloat {
        abs(endPoint.x - startPoint.x)
    }
    
    var height: CGFloat {
        abs(endPoint.y - startPoint.y)
    }
    
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
        guard r.width > 0 && r.height > 0 else { return path }
        
        let center = CGPoint(x: r.midX, y: r.midY)
        let rx = r.width / 2
        let ry = r.height / 2
        
        let sides = 5
        let startAngle = -CGFloat.pi / 2
        
        for i in 0..<sides {
            let angle = startAngle + CGFloat(i) * (2 * .pi / CGFloat(sides))
            let point = CGPoint(
                x: center.x + rx * cos(angle),
                y: center.y + ry * sin(angle)
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
    
    func selectionPath() -> Path {
        Path(rect.insetBy(dx: -lineWidth/2 - 5, dy: -lineWidth/2 - 5))
    }
    
    func fillPath() -> Path {
        path()
    }
    
    func contains(_ point: CGPoint) -> Bool {
        path().contains(point)
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
}


@objc(PentagonPlugin)
public class PentagonPlugin: NSObject, DrawingPlugin {
    public var name: String = "Пятиугольник"
    public var iconName: String = "pentagon"
    
    public required override init() {
        super.init()
        ShapeRegistry.shared.register(PentagonShape.self, for: "pentagon")
    }
    
    public func create(at point: CGPoint, color: Color, width: CGFloat, rotationAngle: CGFloat, filled: Bool, fillColor: Color, layerID: UUID) -> any Drawable {
        return PentagonShape(
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
        guard var pentagon = shape as? PentagonShape else { return shape }
        pentagon.endPoint = point
        return pentagon
    }
}

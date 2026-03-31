import DrawingSDK
import SwiftUI

struct PolylineShape: Drawable {
    var typeName: String { "polyline" }
    
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
        guard let first = points.first else { return path }
        path.move(to: first)
        for i in 1..<points.count {
            path.addLine(to: points[i])
        }
        return path
    }
    
    func selectionPath() -> Path {
        let rect = path().boundingRect.insetBy(dx: -10, dy: -10)
        return Path(rect)
    }
    
    func fillPath() -> Path {
        var path = self.path()
        path.closeSubpath()
        return path
    }
    
    func contains(_ point: CGPoint) -> Bool {
        let threshold: CGFloat = 10 + (lineWidth / 2)
        for i in 0..<points.count-1 {
            if isPoint(point, nearLineFrom: points[i], to: points[i+1], threshold: threshold) {
                return true
            }
        }
        return false
    }
    
    private func isPoint(_ p: CGPoint, nearLineFrom s: CGPoint, to e: CGPoint, threshold: CGFloat) -> Bool {
        let dx = e.x - s.x
        let dy = e.y - s.y
        let l2 = dx*dx + dy*dy
        if l2 == 0 { return sqrt(pow(p.x - s.x, 2) + pow(p.y - s.y, 2)) < threshold }
        var t = ((p.x - s.x) * dx + (p.y - s.y) * dy) / l2
        t = max(0, min(1, t))
        let proj = CGPoint(x: s.x + t * dx, y: s.y + t * dy)
        return sqrt(pow(p.x - proj.x, 2) + pow(p.y - proj.y, 2)) < threshold
    }

    mutating func move(by offset: CGSize) {
        for i in points.indices {
            points[i].x += offset.width
            points[i].y += offset.height
        }
    }
    
    mutating func resize(xOffset: CGFloat, yOffset: CGFloat) {
        let rect = path().boundingRect
        let midX = rect.midX
        let midY = rect.midY
        let scaleX = rect.width == 0 ? 1 : (rect.width + xOffset) / rect.width
        let scaleY = rect.height == 0 ? 1 : (rect.height + yOffset) / rect.height
        
        for i in points.indices {
            points[i].x = midX + (points[i].x - midX) * scaleX
            points[i].y = midY + (points[i].y - midY) * scaleY
        }
    }
    
    var width: CGFloat { path().boundingRect.width }
    var height: CGFloat { path().boundingRect.height }
}


@objc(PolylinePlugin)
public class PolylinePlugin: NSObject, DrawingPlugin {
    public var name: String = "Ломаная"
    public var iconName: String = "control"
    
    public required override init() {
        super.init()
        ShapeRegistry.shared.register(PolylineShape.self, for: "polyline")
    }
    
    public func create(at point: CGPoint, color: Color, width: CGFloat, rotationAngle: CGFloat, filled: Bool, fillColor: Color, layerID: UUID) -> any Drawable {
        return PolylineShape(points: [point, point], color: color, fillColor: fillColor, lineWidth: width, isFilled: filled, layerID: layerID, rotation: rotationAngle)
    }
    
    public func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable {
        guard var polyline = shape as? PolylineShape else { return shape }
        
        if !polyline.points.isEmpty {
            polyline.points[polyline.points.count - 1] = point
        }
        
        return polyline
    }
}

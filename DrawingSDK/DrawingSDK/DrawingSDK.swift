import SwiftUI

public struct CodableColor: Codable {
    public var red: CGFloat
    public var green: CGFloat
    public var blue: CGFloat
    public var alpha: CGFloat

    public init(_ color: Color) {
        let nsColor = NSColor(color).usingColorSpace(.deviceRGB) ?? .black
        self.red = nsColor.redComponent
        self.green = nsColor.greenComponent
        self.blue = nsColor.blueComponent
        self.alpha = nsColor.alphaComponent
    }

    public var swiftUIColor: Color {
        Color(.displayP3, red: red, green: green, blue: blue, opacity: alpha)
    }
}

public class ShapeRegistry {
    public static let shared = ShapeRegistry()
    private var types: [String: Drawable.Type] = [:]
    
    private init() {}

    public func register<T: Drawable>(_ type: T.Type, for typeName: String) {
        types[typeName] = type
    }

    public func getType(for typeName: String) -> Drawable.Type? {
        return types[typeName]
    }
}

public protocol Drawable: Codable {
    var typeName: String { get }
    var id: UUID { get set }
    var color: Color { get set }
    var fillColor: Color { get set }
    var lineWidth: CGFloat { get set }
    var isFilled: Bool { get set }
    var layerID: UUID { get set }
    
    var height: CGFloat { get }
    var width: CGFloat { get }
    var rotation: CGFloat { get set }
    
    func path() -> Path
    func selectionPath() -> Path
    func fillPath() -> Path
    func contains(_ point: CGPoint) -> Bool
    mutating func move(by offset: CGSize)
    mutating func resize(xOffset: CGFloat, yOffset: CGFloat)
}

public struct AnyDrawable: Codable {
    public let shape: any Drawable

    private enum CodingKeys: String, CodingKey {
        case typeName
        case shapeData
    }

    public init(_ shape: any Drawable) {
        self.shape = shape
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let typeName = try container.decode(String.self, forKey: .typeName)
        
        guard let type = ShapeRegistry.shared.getType(for: typeName) else {
            throw DecodingError.dataCorruptedError(
                forKey: .typeName,
                in: container,
                debugDescription: "Тип '\(typeName)' не зарегистрирован. Убедитесь, что плагин загружен."
            )
        }
        
        self.shape = try container.decode(type, forKey: .shapeData)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(shape.typeName, forKey: .typeName)
        
        try container.encode(shape, forKey: .shapeData)
    }
}


public protocol DrawingPlugin {
    var name: String { get }
    var iconName: String { get }
    
    func create(at point: CGPoint, color: Color, width: CGFloat, rotationAngle: CGFloat, filled: Bool, fillColor: Color, layerID: UUID) -> any Drawable
    func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable
    
    init()
}

import SwiftUI

public protocol Drawable {
    var id: UUID { get set }
    var color: Color { get set }
    var fillColor: Color { get set }
    var lineWidth: CGFloat { get set }
    var isFilled: Bool { get set }
    
    var height: CGFloat { get }
    var width: CGFloat { get }
    
    func path() -> Path
    func selectionPath() -> Path
    func fillPath() -> Path
    func contains(_ point: CGPoint) -> Bool
    mutating func move(by offset: CGSize)
    mutating func resize(xOffset: CGFloat, yOffset: CGFloat)
}

public protocol DrawingPlugin {
    var name: String { get }
    var iconName: String { get }
    
    func create(at point: CGPoint, color: Color, width: CGFloat, filled: Bool, fillColor: Color) -> any Drawable
    func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable
    
    init()
}

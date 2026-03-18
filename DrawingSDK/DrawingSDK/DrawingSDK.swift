import SwiftUI

public protocol Drawable {
    var color: Color { get set }
    var lineWidth: CGFloat { get set }
    
    func path() -> Path
    func contains(_ point: CGPoint) -> Bool
    mutating func move(by offset: CGSize)
}

public protocol DrawingPlugin {
    var name: String { get }
    var iconName: String { get }
    
    func create(at point: CGPoint, color: Color, width: CGFloat) -> any Drawable
    func update(_ shape: any Drawable, to point: CGPoint) -> any Drawable
    
    init()
}

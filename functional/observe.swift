import Foundation



public class Disposable {

    private let dispose: ()->()

    init(_ dispose: @escaping ()->()) {

        self.dispose = dispose
    }

    deinit {

        self.dispose()
    }
}



public extension NSObjectProtocol where Self: NSObject {
    func observe<Value>(_ keyPath: KeyPath<Self, Value>
        , onChange: @escaping (Value) -> ()) -> Disposable
    {
        let observation = observe(keyPath, options: [.initial, .new]) { _, change in

            switch (change.oldValue, change.newValue) {

            case (_, .some(let newValue)):
                onChange(newValue)
            case (.some(let oldValue), nil) where oldValue is ExpressibleByNilLiteral:
                let newValue = ((Value.self as! ExpressibleByNilLiteral.Type).init(nilLiteral: ())) as! Value
                onChange(newValue)
            default:
                break
            }
        }
        return Disposable { observation.invalidate() }
    }
}



public extension NSObjectProtocol where Self: NSObject {
    func bind<Value, Target: AnyObject>(_ sourceKeyPath: KeyPath<Self, Value>,
                             to target: Target,
                             at targetKeyPath: ReferenceWritableKeyPath<Target, Value>) -> Disposable
    {
        return observe(sourceKeyPath) { [weak target] in
            target?[keyPath: targetKeyPath] = $0 }
    }
}

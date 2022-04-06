import Combine

extension ObservedObject {
    
    /// Returns a `Publisher` that emits the value of a property as it changes over time.
    ///
    /// - Parameter keyPath: The keypath of the property to publish
    /// - Returns: A publisher that emits elements each time the property’s value changes.
    public func publisher<Value>(
        for keyPath: KeyPath<Self, Value>,
        options: ObservedObjectPropertyOptions = []
    ) -> Publishers.ObservedPropertyPublisher<Self, Value> {
        Publishers.ObservedPropertyPublisher(object: self, keyPath: keyPath, options: options)
    }
    
}

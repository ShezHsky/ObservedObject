import Combine

extension ObservedObject {
    
    /// Returns a `Publisher` that emits the value of a property as it changes over time.
    ///
    /// - Note: The value must be `Equatable` for the pipeline to be aware when the value has actually changed.
    ///
    /// - Parameter keyPath: The keypath of the property to publish.
    /// - Returns: A publisher that emits elements each time the property’s value changes.
    public func publisher<Value>(
        for keyPath: KeyPath<Self, Value>,
        options: ObservedObjectPropertyOptions = [.initial]
    ) -> Publishers.ObservedPropertyPublisher<Self, Value> where Value: Equatable {
        Publishers.ObservedPropertyPublisher(object: self, keyPath: keyPath, options: options)
    }
    
}

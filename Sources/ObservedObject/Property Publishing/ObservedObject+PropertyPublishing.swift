import Combine

extension ObservedObject {
    
    /// Returns a `Publisher` that emits the value of a property as it changes over time.
    ///
    /// - Note: The value must be `Equatable` for the pipeline to be aware when the value has actually changed.
    ///
    /// - Parameter keyPath: The keypath of the property to publish.
    /// - Parameter options: Property-observation options.
    /// - Returns: A publisher that emits elements each time the property’s value changes.
    public func publisher<Value>(
        for keyPath: KeyPath<Self, Value>,
        options: PropertyObservationOptions = [.initial]
    ) -> Publishers.PropertyPublisher<Self, Value> where Value: Equatable {
        Publishers.PropertyPublisher(
            pipelineFactory: PropertyPipelineFactory(
                object: self,
                keyPath: keyPath,
                options: options
            )
        )
    }
    
    /// Returns a `Publisher` that emits the value of a property as it changes over time.
    ///
    /// - Note: The value must be `Equatable` for the pipeline to be aware when the value has actually changed.
    ///
    /// - Parameter keyPath: The keypath of the property to publish.
    /// - Parameter options: Property-observation options.
    /// - Parameter equalityComparator: A closure to determine whether two `Value`s are the same.
    /// - Returns: A publisher that emits elements each time the property’s value changes.
    public func publisher<Value>(
        for keyPath: KeyPath<Self, Value>,
        options: PropertyObservationOptions = [.initial],
        propertyChangedBy equalityComparator: @escaping (Value, Value) -> Bool
    ) -> Publishers.PropertyPublisher<Self, Value> {
        Publishers.PropertyPublisher(
            pipelineFactory: PropertyPipelineFactory(
                object: self,
                keyPath: keyPath,
                options: options,
                propertyChangedBy: equalityComparator
            )
        )
    }
    
    public func publisher<Value1: Equatable, Value2: Equatable>(
        for firstKeyPath: KeyPath<Self, Value1>,
        _ secondKeyPath: KeyPath<Self, Value2>
    ) -> Publishers.PropertyPublisher2<Self, Value1, Value2> {
        Publishers.PropertyPublisher2(
            pipelineFactory: PropertyPipelineFactory2(
                object: self,
                firstKeyPath: firstKeyPath,
                secondKeyPath: secondKeyPath
            )
        )
    }
    
}

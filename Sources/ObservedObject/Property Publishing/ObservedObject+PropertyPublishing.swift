import Combine

extension ObservedObject {
    
    /// Returns a `Publisher` that emits the value of a property as it changes over time.
    ///
    /// - Note: The value must be `Equatable` for the pipeline to be aware when the value has actually changed.
    ///
    /// - Parameters:
    ///    - keyPath: The key path of the property to publish.
    ///    - options: Property-observation options.
    ///
    /// - Returns: A publisher that emits elements each time the property’s value changes.
    public func publisher<Value>(
        for keyPath: KeyPath<Self, Value>,
        options: PropertyObservationOptions = [.initial]
    ) -> Publishers.PropertyPublisher<Self, Value> where Value: Equatable {
        publisher(for: keyPath, options: options, propertyChangedBy: ==)
    }
    
    /// Returns a `Publisher` that emits the value of a property as it changes over time.
    ///
    /// - Parameters:
    ///    - keyPath: The key path of the property to publish.
    ///    - options: Property-observation options.
    ///    - equalityComparator: A closure to determine whether two `Value`s are the same.
    ///
    /// - Returns: A publisher that emits elements each time the property’s value changes.
    public func publisher<Value>(
        for keyPath: KeyPath<Self, Value>,
        options: PropertyObservationOptions = [.initial],
        propertyChangedBy equalityComparator: @escaping (Value, Value) -> Bool
    ) -> Publishers.PropertyPublisher<Self, Value> {
        Publishers.PropertyPublisher(
            object: self,
            keyPath: keyPath,
            options: options,
            equalityComparator: equalityComparator
        )
    }
    
    /// Returns a `Publisher` that emits the values of two properties as they change over time.
    ///
    /// - Parameters:
    ///   - firstKeyPath: The key path of the first property to publish.
    ///   - secondKeyPath: The key path of the second property to publish.
    ///   - options: Property-observation options.
    ///
    /// - Returns: A publisher that emits elements each time the property values change.
    public func publisher<Value1: Equatable, Value2: Equatable>(
        for firstKeyPath: KeyPath<Self, Value1>,
        _ secondKeyPath: KeyPath<Self, Value2>,
        options: PropertyObservationOptions = [.initial]
    ) -> Publishers.PropertyPublisher2<Self, Value1, Value2> {
        Publishers.PropertyPublisher2(
            object: self,
            firstKeyPath: firstKeyPath,
            secondKeyPath: secondKeyPath,
            options: options
        )
    }
    
    /// Returns a `Publisher` that emits the values of three properties as they change over time.
    ///
    /// - Parameters:
    ///   - firstKeyPath: The key path of the first property to publish.
    ///   - secondKeyPath: The key path of the second property to publish.
    ///   - thirdKeyPath: The key path of the third property to publish.
    ///   - options: Property-observation options.
    ///
    /// - Returns: A publisher that emits elements each time the property values change.
    public func publisher<Value1: Equatable, Value2: Equatable, Value3: Equatable>(
        for firstKeyPath: KeyPath<Self, Value1>,
        _ secondKeyPath: KeyPath<Self, Value2>,
        _ thirdKeyPath: KeyPath<Self, Value3>,
        options: PropertyObservationOptions = [.initial]
    ) -> Publishers.PropertyPublisher3<Self, Value1, Value2, Value3> {
        Publishers.PropertyPublisher3(
            object: self,
            firstKeyPath: firstKeyPath,
            secondKeyPath: secondKeyPath,
            thirdKeyPath: thirdKeyPath,
            options: options
        )
    }
    
}

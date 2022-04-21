import Combine

extension Publishers {
    
    /// A `Publisher` that emits events when the value of an ``ObservedObject``'s property changes.
    ///
    /// Use this publisher to integrate a property that’s observable with ``@Observed`` into a Combine publishing
    /// chain. You can create a publisher of this type with the ``ObservedObject`` instance method
    /// ``ObservedObject.publisher(for:options:)``, passing in the key path.
    public struct PropertyPublisher<Object, Value> where Object: ObservedObject {
        
        private let object: Object
        private let keyPath: KeyPath<Object, Value>
        private let options: PropertyObservationOptions
        private let equalityComparator: (Value, Value) -> Bool
        
        init(
            object: Object,
            keyPath: KeyPath<Object, Value>,
            options: PropertyObservationOptions,
            equalityComparator: @escaping (Value, Value) -> Bool
        ) {
            self.object = object
            self.keyPath = keyPath
            self.options = options
            self.equalityComparator = equalityComparator
        }
        
    }
    
}

extension Publishers.PropertyPublisher: Publisher {
    
    public typealias Output = Value
    public typealias Failure = Never
    
    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value, S.Failure == Never {
        let upstream = object
            .objectDidChange
            .map(keyPath)
            .merge(with: Just(object[keyPath: keyPath]))
            .removeDuplicates(by: equalityComparator)
            .dropFirst(options.ignoredElementsCount)
        
        let subscription = PropertyChangedSubscription(upstream: upstream, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
}

// MARK: - Convenience Publishing Functions

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
    
}

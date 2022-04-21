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

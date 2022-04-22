import Combine

extension Publishers {
    
    /// A `Publisher` that emits events when the values of three ``ObservedObject``'s properties change.
    ///
    /// Use this publisher to integrate three properties that are observable with ``@Observed`` into a Combine
    /// publishing chain. You can create a publisher of this type with the ``ObservedObject`` instance method
    /// ``ObservedObject.publisher(for:options:)``, passing in the key paths.
    public struct PropertyPublisher3<Object, Value1, Value2, Value3>
        where Object: ObservedObject, Value1: Equatable, Value2: Equatable, Value3: Equatable {
        
        private let object: Object
        private let firstKeyPath: KeyPath<Object, Value1>
        private let secondKeyPath: KeyPath<Object, Value2>
        private let thirdKeyPath: KeyPath<Object, Value3>
        private let options: PropertyObservationOptions
        
        init(
            object: Object,
            firstKeyPath: KeyPath<Object, Value1>,
            secondKeyPath: KeyPath<Object, Value2>,
            thirdKeyPath: KeyPath<Object, Value3>,
            options: PropertyObservationOptions
        ) {
            self.object = object
            self.firstKeyPath = firstKeyPath
            self.secondKeyPath = secondKeyPath
            self.thirdKeyPath = thirdKeyPath
            self.options = options
        }
        
    }
    
}

extension Publishers.PropertyPublisher3: Publisher {
    
    public typealias Output = (Value1, Value2, Value3)
    public typealias Failure = Never
    
    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
        let firstKeyPathPublisher = object.publisher(for: firstKeyPath, options: options)
        let secondKeyPathPublisher = object.publisher(for: secondKeyPath, options: options)
        let thirdKeyPathPublisher = object.publisher(for: thirdKeyPath, options: options)
        let upstream = Publishers.CombineLatest3(firstKeyPathPublisher, secondKeyPathPublisher, thirdKeyPathPublisher)
        let subscription = PropertyChangedSubscription(upstream: upstream, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
}

// MARK: - Convenience Publishing Functions

extension ObservedObject {
    
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

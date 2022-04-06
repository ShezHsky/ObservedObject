import Combine

extension ObservedObject {
    
    /// Returns a `Publisher` that emits the value of a property as it changes over time.
    ///
    /// - Parameter keyPath: The keypath of the property to publish
    /// - Returns: A publisher that emits elements each time the property’s value changes.
    public func publisher<Value>(
        for keyPath: KeyPath<Self, Value>
    ) -> Publishers.ObservedPropertyPublisher<Self, Value> {
        Publishers.ObservedPropertyPublisher(object: self, keyPath: keyPath)
    }
    
}

extension Publishers {
    
    /// A `Publisher` that emits events when the value of an `ObservedObject`'s property changes.
    ///
    /// Use this publisher to integrate a property that’s observable with key-value observing into a Combine publishing
    /// chain. You can create a publisher of this type with the `ObservedObject` instance method publisher(for:),
    /// passing in the key path.
    public struct ObservedPropertyPublisher<Object, Value> where Object: ObservedObject {
        
        private let object: Object
        private let keyPath: KeyPath<Object, Value>
        
        init(object: Object, keyPath: KeyPath<Object, Value>) {
            self.object = object
            self.keyPath = keyPath
        }
        
    }
    
}

extension Publishers.ObservedPropertyPublisher: Publisher {
    
    public typealias Output = Value
    public typealias Failure = Never
    
    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == Value, S.Failure == Never {
        let subscription = Subscription(object: object, keyPath: keyPath, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
    private class Subscription<S>: Combine.Subscription
        where S: Combine.Subscriber, S.Input == Output, S.Failure == Failure
    {
        
        private var object: Object!
        private let keyPath: KeyPath<Object, Value>
        private let subscriber: S
        private var propertyDidChange: Cancellable?
        
        private var currentValue: Value {
            object[keyPath: keyPath]
        }
        
        init(object: Object, keyPath: KeyPath<Object, Value>, subscriber: S) {
            self.object = object
            self.keyPath = keyPath
            self.subscriber = subscriber
            
            propertyDidChange = object
                .objectDidChange
                .map(keyPath)
                .sink { [weak self] (newValue) in
                    self?.updateSubscriber(value: newValue)
                }
            
            updateSubscriber(value: currentValue)
        }
        
        private func updateSubscriber(value: Value) {
            _ = subscriber.receive(value)
        }
        
        let combineIdentifier = CombineIdentifier()
        
        func request(_ demand: Subscribers.Demand) {
            
        }
        
        func cancel() {
            
        }
        
    }
    
}

import Combine

extension Publishers {
    
    /// A `Publisher` that emits events when the values of two ``ObservedObject``'s properties change.
    ///
    /// Use this publisher to integrate two properties that are observable with ``@Observed`` into a Combine publishing
    /// chain. You can create a publisher of this type with the ``ObservedObject`` instance method
    /// ``ObservedObject.publisher(for:options:)``, passing in the key paths.
    public struct PropertyPublisher2<Object, Value1, Value2>
        where Object: ObservedObject, Value1: Equatable, Value2: Equatable
    {
        
        private let object: Object
        private let firstKeyPath: KeyPath<Object, Value1>
        private let secondKeyPath: KeyPath<Object, Value2>
//        private let options: PropertyObservationOptions
        
        init(
            object: Object,
            firstKeyPath: KeyPath<Object, Value1>,
            secondKeyPath: KeyPath<Object, Value2>//,
//            options: PropertyObservationOptions
        ) {
            self.object = object
            self.firstKeyPath = firstKeyPath
            self.secondKeyPath = secondKeyPath
//            self.options = options
        }
        
    }
    
}

extension Publishers.PropertyPublisher2: Publisher {
    
    public typealias Output = (Value1, Value2)
    public typealias Failure = Never
    
    public func receive<S>(subscriber: S) where S: Subscriber, S.Input == (Value1, Value2), S.Failure == Never {
        let initalSubject: AnyPublisher<(Value1, Value2), Never> = {
//            if options.contains(.initial) {
                return Just(object[keyPath: firstKeyPath]).combineLatest(Just(object[keyPath: secondKeyPath])).eraseToAnyPublisher()
//            } else {
//                return Empty().combineLatest(Empty()).eraseToAnyPublisher()
//            }
        }()
        
        let upstream = object
            .objectDidChange
            .map({ (object) in (object[keyPath: firstKeyPath], object[keyPath: secondKeyPath]) })
            .merge(with: initalSubject)
        
        let subscription = PropertyChangedSubscription(upstream: upstream, subscriber: subscriber)
        subscriber.receive(subscription: subscription)
    }
    
}

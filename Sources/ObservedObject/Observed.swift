import Combine

/// A type that publishes a property marked with an attribute.
///
/// Publishing a property with the `@Observed` attribute creates a publisher of this type. You access the publisher with
/// the `$` operator, as shown here:
///
///     class Weather {
///         @Observed var temperature: Double
///         init(temperature: Double) {
///             self.temperature = temperature
///         }
///     }
///
///     let weather = Weather(temperature: 20)
///     cancellable = weather.$temperature
///         .sink() {
///             print ("Temperature now: \($0)")
///     }
///
///     weather.temperature = 25
///
///     // Prints:
///     // Temperature now: 20.0
///     // Temperature now: 25.0
///
/// When the property changes, publishing occurs in the property's `didSet` block, meaning subscribers receive the new
/// value after it's set on the property.
///
/// > Important: The `@Observed` attribute is class constrained. Use it with properties of classes, not with non-class
/// types like structures.
@propertyWrapper public struct Observed<Value> {
    
    public static subscript<EnclosingSelf>(
          _enclosingInstance observed: EnclosingSelf,
          wrapped wrappedKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Value>,
          storage storageKeyPath: ReferenceWritableKeyPath<EnclosingSelf, Self>
    ) -> Value where EnclosingSelf: ObservedObject {
        get {
            observed[keyPath: storageKeyPath].currentValueSubject.value
        }
        set {
            observed[keyPath: storageKeyPath].currentValueSubject.value = newValue
            
            if let publisher = observed.objectDidChange as? ObservedObjectPublisher {
                publisher.send()
            }
        }
    }
    
    private let currentValueSubject: CurrentValueSubject<Value, Never>
        
    public init(wrappedValue: Value) {
        self.currentValueSubject = CurrentValueSubject(wrappedValue)
        self.projectedValue = Publisher(currentValueSubject: currentValueSubject)
    }
    
    /// The property for which this instance exposes a publisher.
    ///
    /// The ``Observed/projectedValue`` is the property accessed with the `$` operator.
    public let projectedValue: Observed<Value>.Publisher
    
    @available(*, unavailable, message: "@Observed can only be applied to classes")
    public var wrappedValue: Value {
        get {
            fatalError("@Observed can only be applied to classes")
        }
        set {
            fatalError("@Observed can only be applied to classes")
        }
    }
    
}

// MARK: - Custom Publisher

extension Observed {
    
    /// A publisher for properties marked with the ``Observed`` attribute.
    public struct Publisher: Combine.Publisher {
        
        let currentValueSubject: CurrentValueSubject<Value, Never>
        
        public typealias Output = Value
        
        public typealias Failure = Never
        
        public func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
            currentValueSubject.receive(subscriber: subscriber)
        }
        
    }
    
}

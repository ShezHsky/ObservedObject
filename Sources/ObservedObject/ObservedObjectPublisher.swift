import Combine

/// A publisher that publishes changes from an ``ObservedObject``.
public final class ObservedObjectPublisher<Object>: Publisher where Object: ObservedObject {
    
    private let passthroughSubject = PassthroughSubject<Object, Never>()
    private unowned let object: Object

    public typealias Output = Object
    
    public typealias Failure = Never

    /// Creates an observable object publisher instance.
    public init(_ object: Object) {
        self.object = object
    }

    public final func receive<S>(subscriber: S) where S: Subscriber, S.Input == Output, S.Failure == Failure {
        passthroughSubject.receive(subscriber: subscriber)
    }

    /// Sends the changed value to the downstream subscriber.
    public final func send() {
        passthroughSubject.send(object)
    }
    
}

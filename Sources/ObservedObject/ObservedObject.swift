import Combine

/// A type of object with a publisher that emits after the object has changed.
///
/// By default an ``ObservedObject`` synthesizes an ``objectDidChange-1ftr4`` publisher that emits the
/// changed value after any of its `@Observed` properties changes.
///
///     class Contact: ObservedObject {
///         @Observed var name: String
///         @Observed var age: Int
///
///         init(name: String, age: Int) {
///             self.name = name
///             self.age = age
///         }
///
///         func haveBirthday() {
///             age += 1
///         }
///     }
///
///     let john = Contact(name: "John Appleseed", age: 24)
///     cancellable = john.objectDidChange
///         .sink { _ in
///             print("John is now \(john.age)")
///     }
///
///     john.haveBirthday()
///
///     // Prints "John is now 25"
///
/// - Note: Not to be confused with the SwiftUI `ObservedObject` property wrapper.
public protocol ObservedObject: AnyObject {
    
    /// The type of publisher that emits after the object has changed.
    associatedtype ObjectDidChangePublisher: Publisher = ObservedObjectPublisher<Self> where ObjectDidChangePublisher.Failure == Never

    /// A publisher that emits after the object has changed.
    var objectDidChange: ObjectDidChangePublisher { get }
    
}

extension ObservedObject {
    
    public var objectDidChange: ObservedObjectPublisher<Self> {
        ObservedObjectPublisherStorage[self]
    }
    
}

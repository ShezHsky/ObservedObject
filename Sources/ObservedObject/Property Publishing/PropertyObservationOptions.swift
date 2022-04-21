/// The values that can be provided to subscribers of a `PropertyPublisher` pipeline.
///
/// These constants are passed to ``ObservedObject/publisher(for:options:)`` and determine the values that are returned
/// as part of the change dictionary to the Combine publishing chain.
public struct PropertyObservationOptions: OptionSet {
    
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// If specified, the subscriber should receive the current value immediately, before the subscription registration
    /// method even returns.
    public static let initial = PropertyObservationOptions(rawValue: 1 << 0)
    
}

extension PropertyObservationOptions {
    
    var ignoredElementsCount: Int {
        contains(.initial) ? 0 : 1
    }
    
}

/// The values that can be returned in a change dictionary.
///
/// These constants are passed to ``publisher(for:options:)`` and determine the values that are returned as part of the
/// change dictionary to the Combine publishing chain. You can pass 0 if you require no change dictionary values.
public struct ObservedObjectPropertyOptions: OptionSet {
    
    public var rawValue: Int
    
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }
    
    /// If specified, the subscriber should receive the current value immediately, before the subscription registration
    /// method even returns.
    public static let initial = ObservedObjectPropertyOptions(rawValue: 1 << 0)
    
}

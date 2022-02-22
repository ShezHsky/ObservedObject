import Foundation

class ObservedObjectPublisherStorage {
    
    private static let storage = NSMapTable<AnyObject, AnyObject>(
        keyOptions: .weakMemory,
        valueOptions: .strongMemory
    )
    
    static subscript <Object> (object: Object) -> ObservedObjectPublisher<Object> where Object: ObservedObject {
        get {
            let publisher: ObservedObjectPublisher<Object>
            if let existing = storage.object(forKey: object) as? ObservedObjectPublisher<Object> {
                publisher = existing
            } else {
                publisher = ObservedObjectPublisher(object)
                storage.setObject(publisher, forKey: object)
            }
            
            return publisher
        }
    }
    
}

import Foundation

@propertyWrapper
struct AppStorageUserDefault<T: Codable> {
    private let key: String
    private let defaultValue: T
    private let userDefaults: UserDefaults

    init(key: String, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }
    
    var wrappedValue: T {
        get {
            if let data = userDefaults.data(forKey: key) {
                let decoder = JSONDecoder()
                do {
                    return try decoder.decode(T.self, from: data)
                } catch {
                    Log.error("Failed to decode \(T.self) for key \(key):", error)
                    return defaultValue
                }
            }
            return defaultValue
        }
        set {
            let encoder = JSONEncoder()
            do {
                let data = try encoder.encode(newValue)
                userDefaults.set(data, forKey: key)
                userDefaults.synchronize()
            } catch {
                Log.error("Failed to encode \(T.self) for key \(key):", error)
            }
        }
    }
    func remove() {
        userDefaults.removeObject(forKey: key)
    }
}

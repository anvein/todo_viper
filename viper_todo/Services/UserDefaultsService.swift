
import Foundation

class UserDefaultsService {

    static let shared: UserDefaultsService = .init()

    // MARK: - Services

    private var userDefaults: UserDefaults = .standard

    // MARK: - Init

    private init() { }

    // MARK: - Parameters Keys

    private static var isTasksFirstLoad: String = "isTasksFirstLoad"

    // MARK: - Data manipulation

    func getIsTasksFirstLoad() -> Bool {
        return userDefaults.bool(forKey: Self.isTasksFirstLoad)
    }

    func setIsTasksFirstLoad(_ value: Bool) {
        userDefaults.setValue(value, forKey: Self.isTasksFirstLoad)
    }
}

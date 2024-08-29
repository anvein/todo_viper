
import Foundation

extension String {
    var stringOrNilIfEmpty: String? {
        return self.isEmpty ? nil : self
    }
}

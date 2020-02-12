
import Foundation
import RealmSwift

class House: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    let rooms = List<Room>()
}

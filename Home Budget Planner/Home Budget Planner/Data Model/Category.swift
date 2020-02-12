
import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    var parentRoom = LinkingObjects(fromType: Room.self, property: "categories")
    var items = List<Item>()
}

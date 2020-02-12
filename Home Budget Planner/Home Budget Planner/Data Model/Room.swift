
import Foundation
import RealmSwift

class Room: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var colour: String = ""
    var parentHouse = LinkingObjects(fromType: House.self, property: "rooms")
    let categories = List<Category>()
}


import UIKit
import RealmSwift
import ChameleonFramework

class RoomViewController: SwipeTableViewController, CAAnimationDelegate {
    
    let realm = try! Realm()

    var rooms: List<Room>? {
        return selectedHouse?.rooms
    }
    
    var selectedHouse: House? {
        didSet {
            loadRooms()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientView()
        loadRooms()
        tableView.separatorStyle = .none
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        animateGradient()
        
        if let colourHex = selectedHouse?.colour {
            title = selectedHouse!.name
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
            }
            if let navBarColour = UIColor(hexString: colourHex) {
                //navBar.backgroundColor = navBarColour
                //navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                navBar.isTranslucent = true
                tableView.backgroundColor = navBarColour
            }
        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        if let room = rooms?[indexPath.row] {
            cell.textLabel?.text = room.name
            if let colour = UIColor(hexString: selectedHouse!.colour, withAlpha: CGFloat(0.3))?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(rooms!.count)) {
                cell.backgroundColor = colour
                cell.textLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
        } else {
            cell.textLabel?.text = "No Items Added"
        }
        return cell
    }
    
    
    //MARK: - Data Manipulation Methods
    
    func save(room: Room) {
        guard let house = selectedHouse else { return }
        
        do {
            try realm.write {
                house.rooms.append(room)
            }
        } catch {
            print("Error saving room \(error)")
        }
        tableView.reloadData()
    }
    
    func loadRooms() {
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let roomForDeletion = self.rooms?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(roomForDeletion)
                }
            } catch {
                print("Error deleting room, \(error)")
            }
        }
    }
    
    //MARK: - Add New Rooms
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a New Room", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            if let currentHouse = self.selectedHouse {
                        do {
                            try self.realm.write {
                                let newRoom = Room()
                                newRoom.name = textField.text!
                                newRoom.colour = UIColor.randomFlat().hexValue()
                                currentHouse.rooms.append(newRoom)
                            }
                        } catch {
                            print("Error saving new rooms, \(error)")
                        }
                    }
                    self.tableView.reloadData()
                }
                alert.addTextField { (alertTextField) in
                    alertTextField.placeholder = "Create new room"
                    textField = alertTextField
                }
                alert.addAction(action)
                present(alert, animated: true, completion: nil)
            }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToCategories", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! CategoryViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedRoom = rooms?[indexPath.row]
        }
    }
    
    //MARK: - Background Animation
       
       let gradient = CAGradientLayer()
       
       var gradientSet = [[CGColor]]()
       
       var currentGradient: Int = 0
       
       let colorOne = #colorLiteral(red: 0.4, green: 0.631372549, blue: 1, alpha: 1).cgColor
       let colorTwo = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1).cgColor
       let colorThree = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1).cgColor
       
       func createGradientView() {
           gradientSet.append([colorOne, colorTwo])
           gradientSet.append([colorTwo, colorThree])
           gradientSet.append([colorThree, colorOne])
           
           gradient.frame = self.view.bounds
           gradient.colors = gradientSet[currentGradient]
           gradient.startPoint = CGPoint(x: 0, y: 0)
           gradient.endPoint = CGPoint(x: 1, y: 1)
           gradient.drawsAsynchronously = true
           
           
           let backgroundView = UIView(frame: tableView.bounds)
           backgroundView.layer.insertSublayer(gradient, at: 0)
           tableView.backgroundView = backgroundView
           
           //self.view.layer.insertSublayer(gradient, at: 0)
           
           animateGradient()
       }
       
       func animateGradient() {
           
           if currentGradient < gradientSet.count - 1 {
               currentGradient += 1
           } else {
               currentGradient = 0
           }
           
           let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
           gradientChangeAnimation.duration = 3.0
           gradientChangeAnimation.toValue = gradientSet[currentGradient]
           gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
           gradientChangeAnimation.isRemovedOnCompletion = false
           gradientChangeAnimation.delegate = self
           gradient.add(gradientChangeAnimation, forKey: "gradientChangeAnimation")
           
       }
       
       func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
           if flag {
               gradient.colors = gradientSet[currentGradient]
               animateGradient()
           }
       }
       
 
}


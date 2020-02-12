
import UIKit
import RealmSwift
import ChameleonFramework

class HouseViewController: SwipeTableViewController, CAAnimationDelegate {
    
    let realm = try! Realm()
    
    var houses: Results<House>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientView()
        loadHouses()
        tableView.separatorStyle = .none
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let selectedRow = tableView.indexPathForSelectedRow {
            tableView.deselectRow(at: selectedRow, animated: true)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
        }
        //navBar.backgroundColor = UIColor(hexString: "#1D9BF6")
        //navBar.setBackgroundImage(UIImage(), for: .default)
        //navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        animateGradient()
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return houses?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.textLabel?.text = houses?[indexPath.row].name ?? "No Houses/Appartments added yet"
        
        if let house = houses?[indexPath.row] {
            guard let houseColour = UIColor(hexString: house.colour, withAlpha: CGFloat(0.3)) else {fatalError()}
            cell.backgroundColor = houseColour
            cell.textLabel?.textColor = ContrastColorOf(houseColour, returnFlat: true)
        }
        return cell
    }
    
    //MARK: - Data Manipulation Methods
    
    func save(house: House) {
        do {
            try realm.write {
                realm.add(house)
            }
        } catch {
            print("Error saving house \(error)")
        }
        tableView.reloadData()
    }
    
    func loadHouses() {
        
        houses = realm.objects(House.self)
        tableView.reloadData()
    }
    
    //MARK: - Delete Data from Swipe
    
    override func updateModel(at indexPath: IndexPath) {
        if let houseForDeletion = self.houses?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(houseForDeletion)
                }
            } catch {
                print("Error deleting house, \(error)")
            }
        }
    }
    
    //MARK: - Add New Houses
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add a New Home", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add", style: .default) { (action) in
            let newHouse = House()
            newHouse.name = textField.text!
            newHouse.colour = UIColor.randomFlat().hexValue()
            self.save(house: newHouse)
        }
        
        alert.addAction(action)
        alert.addTextField { (field) in
            textField = field
            textField.placeholder = "Add a new home"
        }
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Tableview Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "goToRooms", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationVC = segue.destination as! RoomViewController
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedHouse = houses?[indexPath.row]
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


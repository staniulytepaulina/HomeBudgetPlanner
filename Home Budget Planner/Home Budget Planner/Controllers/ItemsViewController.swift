
import UIKit
import RealmSwift
import ChameleonFramework

class ItemsViewController: ItemsTableViewController, ImagePickerDelegate, CAAnimationDelegate {
    
    //UINavigationControllerDelegate, UIImagePickerControllerDelegate 
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let realm = try! Realm()
    
    var selectedCategory: Category? {
        didSet {
            loadItems()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientView()
        tableView.separatorStyle = .none
        tableView.register(UINib(nibName: "ItemsCell", bundle: nil), forCellReuseIdentifier: "ItemCell")

    }
    
    override func viewWillAppear(_ animated: Bool) {
        animateGradient()
        
        if let colourHex = selectedCategory?.colour {
            title = selectedCategory!.name
            guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.")
            }
            if let navBarColour = UIColor(hexString: colourHex) {
                //navBar.backgroundColor = navBarColour
                //navBar.tintColor = ContrastColorOf(navBarColour, returnFlat: true)
                navBar.isTranslucent = true
                searchBar.isTranslucent = true
                //searchBar.barTintColor = navBarColour
                tableView.backgroundColor = navBarColour
            }
        }
    }
    
    //MARK: - Tableview Datasource Methods
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedCategory?.items.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath) as! ItemsCell
        if let item = selectedCategory?.items[indexPath.row] {
            cell.itemLabel?.text = item.title
            if let colour = UIColor(hexString: selectedCategory!.colour, withAlpha: CGFloat(0.3))?.darken(byPercentage: CGFloat(indexPath.row) / CGFloat(selectedCategory?.items.count ?? 0)) {
                cell.backgroundColor = colour
                cell.itemLabel?.textColor = ContrastColorOf(colour, returnFlat: true)
            }
            cell.accessoryType = item.done ? .checkmark : .none
        } else {
            cell.itemLabel?.text = "No Items Added"
        }
        
        return cell
    }
    
    //MARK: - TableView Delegate Methods
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let item = selectedCategory?.items[indexPath.row] {
            do {
                try realm.write{
                    // realm.delete(item)
                    item.done = !item.done
                }
            } catch {
                print("Error saving done status, \(error)")
            }
        }
        
        tableView.reloadData()
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    //MARK: - Add New Items
    
    @IBAction func addButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "Add Item", style: .default) { (action) in
            if let currentCategory = self.selectedCategory {
                do {
                    try self.realm.write {
                        let newItem = Item()
                        newItem.title = textField.text!
                        currentCategory.items.append(newItem)
                    }
                } catch {
                    print("Error saving new items, \(error)")
                }
            }
            self.tableView.reloadData()
        }
        alert.addTextField { (alertTextField) in
            alertTextField.placeholder = "Create new item"
            textField = alertTextField
        }
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - Model Manipulation Methods
    
    func loadItems() {
        
//        func sorted(byKeyPath keyPath: String, ascending: Bool = true) -> List<Item> {
//            return sorted(byKeyPath: keyPath, ascending: true)
//        }
        
        //myItems?.sorted(byKeyPath: "title")
        
        try? realm.write {
            selectedCategory?.items.sort() {
                return $0.title > $1.title
            }
        }
        
        //data = data!.sorted("date", ascending: false)
        
        //myItems = myItems.sorted(byKeyPath: "title", ascending: true)
        
        //sorted(byKeyPath: "title")
        
        tableView.reloadData()
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let item = selectedCategory?.items[indexPath.row] {
            do {
                try realm.write{
                    realm.delete(item)
                }
            } catch {
                print("Error deleting item, \(error)")
            }
        }
    }
    
    //MARK: - Image Picker Controller

    func pickImage() {

          let imagePicker = UIImagePickerController()
          imagePicker.delegate = self
          imagePicker.sourceType = .photoLibrary
          imagePicker.allowsEditing = false
          self.present(imagePicker, animated: true, completion: nil)
      }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {

        dismiss(animated: true, completion: nil)

        var cell = tableView.cellForRow(at: NSIndexPath(row: 0, section: 0) as IndexPath) as! ItemsCell
        cell.itemImage.image = image
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



    //MARK: - Searchbar delegate methods

extension ItemsViewController: UISearchBarDelegate{
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // myItems = myItems?.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "title", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadItems()
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
    
    
    
}

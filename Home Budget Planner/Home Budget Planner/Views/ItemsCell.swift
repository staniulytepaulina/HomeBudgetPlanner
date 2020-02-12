
import UIKit

class ItemsCell: UITableViewCell, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    
    func pickerView(_ pickerView: UIPickerView,
     titleForRow row: Int,
     forComponent component: Int) -> String? {
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = pickerData[row]
        let title = NSAttributedString(string: titleData, attributes: [.font:UIFont(name: "Georgia", size: 15.0)!, .foregroundColor:UIColor.white])

        return title
    }
    
    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemLabel: UILabel!
    @IBOutlet weak var addImageButton: UIButton!
    @IBOutlet weak var picker: UIPickerView!
    
    var pickerData = [String]()
    var delegate : ImagePickerDelegate?
    
    var onImageSelect: (() -> UIImage)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        itemImage.layer.cornerRadius = 10.0
        addImageButton.layer.cornerRadius = 5.0
        
        
        self.picker.delegate = self
        self.picker.dataSource = self
        pickerData = ["Unit", "m", "m2"]
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        // This method is triggered whenever the user makes a change to the picker selection.
        // The parameter named row and component represents what was selected.
    }
    
    
    @IBAction func pickImage(_ sender: UIButton) {
        delegate?.pickImage()
        onImageSelect?()
    }
    
    
}

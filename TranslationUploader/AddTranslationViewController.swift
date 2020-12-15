import Cocoa

protocol AddTranslationDelegate: class {
    func addTranslation(key: String, value: String, isEditMode: Bool, completion: @escaping ()->())
}

class AddTranslationViewController: NSViewController {

    @IBOutlet weak var keyTextField: NSTextField!
    @IBOutlet weak var valueTextField: NSTextField!
    var key: String?
    var value: String?
    weak var delegate: AddTranslationDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        keyTextField.stringValue = key ?? ""
        valueTextField.stringValue = value ?? ""
    }

    @IBAction func addTranslationTapped(_ sender: Any) {
        let isEditMode = !(key ?? "").isEmpty && !(value ?? "").isEmpty
        delegate?.addTranslation(key: keyTextField.stringValue, value: valueTextField.stringValue, isEditMode: isEditMode, completion: {
            self.dismiss(self)
        })
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(self)
    }

}

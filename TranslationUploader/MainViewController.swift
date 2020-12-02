import Cocoa

class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    var translations: [(String, String)] = []

    @IBOutlet weak var keyTextField: NSTextField!
    @IBOutlet weak var valueTextField: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var saveToDevButton: NSButton!
    @IBOutlet weak var saveToProdButton: NSButton!

    let firebaseUploaderService = TranslationsUploaderFirebaseService()

    override func viewDidLoad() {
        super.viewDidLoad()

        saveToDevButton.isEnabled = false
        saveToProdButton.isEnabled = false
    }

    @IBAction func addTranslationTapped(_ sender: Any) {
        if !keyTextField.stringValue.isEmpty && !valueTextField.stringValue.isEmpty && !translations.contains(where: { $0.0 == keyTextField.stringValue }) {
            translations.append((keyTextField.stringValue, valueTextField.stringValue))
            keyTextField.stringValue = ""
            valueTextField.stringValue = ""
            saveToDevButton.isEnabled = !translations.isEmpty
            saveToProdButton.isEnabled = !translations.isEmpty
            keyTextField.becomeFirstResponder()
            tableView.reloadData()
        }
    }

    @IBAction func saveToDevTapped(_ sender: Any) {
        firebaseUploaderService.uploadNewTranslations(translations: translations, forDevelop: true) { [weak self] in
            self?.translations.removeAll()
            self?.tableView.reloadData()
        }
    }

    @IBAction func saveToProdTapped(_ sender: Any) {
        if showAlert(question: "Warning", text: "You are uploading to produciton, are you sure?") {
            firebaseUploaderService.uploadNewTranslations(translations: translations, forDevelop: false) { [weak self] in
                self?.translations.removeAll()
                self?.tableView.reloadData()
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return translations.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let recordCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "recordCell"), owner: self) as? TranslationRecordCell else { return nil }

        let item = translations[row]
        let key = item.0
        let value = item.1
        recordCell.set(record: (key, value))
        recordCell.removeRecord = { [weak self] key in
            self?.translations.removeAll { $0.0 == key }
            self?.saveToDevButton.isEnabled = !(self?.translations ?? []).isEmpty
            self?.saveToProdButton.isEnabled = !(self?.translations ?? []).isEmpty
            self?.tableView.reloadData()
        }
        return recordCell
    }

    func showAlert(question: String, text: String) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        return alert.runModal() == .alertFirstButtonReturn
    }
}


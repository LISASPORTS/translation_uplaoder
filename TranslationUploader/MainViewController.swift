import Cocoa

class MainViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource {
    var translations: [(String, String)] = []
    var translationsFileNames: [String] = []

    @IBOutlet weak var fileNamesTableView: NSTableView!
    @IBOutlet weak var stringsTableView: NSTableView!
    @IBOutlet weak var saveToFirebaseButton: NSButton!

    let firebaseUploaderService = TranslationsUploaderFirebaseService()

    override func viewDidLoad() {
        super.viewDidLoad()

        firebaseUploaderService.getTranslationsFileNames { [weak self] fileNames in
            self?.translationsFileNames = fileNames
            self?.fileNamesTableView.reloadData()
        }
        saveToFirebaseButton.isEnabled = false
    }

    @IBAction func addTranslationTapped(_ sender: Any) {
        presentAddTranslationPopup()
    }

    private func presentAddTranslationPopup(key: String? = nil, value: String? = nil) {
        let mainStoryboard = NSStoryboard(name: NSStoryboard.Name("Main"), bundle: nil)
        if let addTranslationViewController = mainStoryboard.instantiateController(withIdentifier: "AddTranslationViewController") as? AddTranslationViewController {
            addTranslationViewController.key = key
            addTranslationViewController.value = value
            addTranslationViewController.delegate = self
            presentAsSheet(addTranslationViewController)
        }
    }

    @IBAction func saveToFirebaseTapped(_ sender: Any) {
        let filename = translationsFileNames[fileNamesTableView.selectedRow]
        if filename.contains("dev") {
            firebaseUploaderService.uploadNewTranslations(translations: translations, translationFileName: filename) { [weak self] in
                self?.translations.removeAll()
                self?.stringsTableView.reloadData()
            }
        } else {
            if showAlert(question: NSLocalizedString("Warning", comment: "production upload"), text: NSLocalizedString("You are uploading to produciton, are you sure?", comment: "")) {
                firebaseUploaderService.uploadNewTranslations(translations: translations, translationFileName: filename) { [weak self] in
                    self?.translations.removeAll()
                    self?.stringsTableView.reloadData()
                }
            }
        }
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView == fileNamesTableView {
            return translationsFileNames.count
        } else {
            return translations.count
        }
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        if tableView == fileNamesTableView {
            guard let fileNameCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "fileNameCell"), owner: self) as? NSTableCellView else { return nil }
            fileNameCell.textField?.stringValue = translationsFileNames[row]
            return fileNameCell
        } else {
            guard let recordCell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "recordCell"), owner: self) as? TranslationRecordCell else { return nil }

            let item = translations[row]
            let key = item.0
            let value = item.1
            recordCell.set(record: (key, value))
            recordCell.editRecord = { [weak self] (key, value) in
                self?.presentAddTranslationPopup(key: key, value: value)
            }
            return recordCell
        }
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if let tableView = notification.object as? NSTableView {
            firebaseUploaderService.getTranslationJson(translationFileName: translationsFileNames[tableView.selectedRow]) { [weak self] json in
                self?.translations = json.map { ($0.key, $0.value) }
                self?.saveToFirebaseButton.isEnabled = false
                self?.stringsTableView.reloadData()
            }
        }
    }

    func showAlert(question: String, text: String, shouldShowCancelButton: Bool = true) -> Bool {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: NSLocalizedString("OK", comment: ""))
        if shouldShowCancelButton {
            alert.addButton(withTitle: NSLocalizedString("Cancel", comment: ""))
        }
        return alert.runModal() == .alertFirstButtonReturn
    }
}

extension MainViewController: AddTranslationDelegate {
    func addTranslation(key: String, value: String, isEditMode: Bool, completion: @escaping () -> ()) {
        if key.isEmpty {
            let _ = showAlert(question: NSLocalizedString("Error", comment: ""), text: NSLocalizedString("Key not inserted.", comment: ""), shouldShowCancelButton: false)
        } else if value.isEmpty {
            let _ = showAlert(question: NSLocalizedString("Error", comment: ""), text: NSLocalizedString("Value not inserted.", comment: ""), shouldShowCancelButton: false)
        } else if !isEditMode && translations.contains(where: { $0.0 == key }) {
            let _ = showAlert(question: NSLocalizedString("Error", comment: ""), text: NSLocalizedString("Key already exists.", comment: "") , shouldShowCancelButton: false)
        } else {
            if isEditMode {
                translations.removeAll { (oldKey, oldValue) in
                    oldKey == key
                }
            }
            translations.append((key, value))
            saveToFirebaseButton.isEnabled = true
            stringsTableView.reloadData()
            completion()
        }
    }
}

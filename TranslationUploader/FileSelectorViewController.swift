import Cocoa
import FirebaseCore

class FileSelectorViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    @IBAction func selectFileTapped(_ sender: Any) {
        showPicker()
    }

    private func showPicker() {
        let dialog = NSOpenPanel()

        dialog.title = "Choose an image | Our Code World"
        dialog.allowedFileTypes = ["plist"]

        if (dialog.runModal() ==  NSApplication.ModalResponse.OK) {
            let result = dialog.url

            if (result != nil) {
                let filePath: String = result!.path
                let options = FirebaseOptions(contentsOfFile: filePath)
                FirebaseApp.configure(options: options!)
                switchToMainViewController()
            }

        } else {
            return
        }
    }

    private func switchToMainViewController() {
        let mainStoryboard = NSStoryboard(name: "Main", bundle: Bundle.main)

        guard let mainViewController = mainStoryboard.instantiateController(withIdentifier: "MainViewController") as? MainViewController else {
            print("Could not find MainViewController")
            return
        }
        view.window?.contentViewController = mainViewController
    }
}

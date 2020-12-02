import Cocoa
import FirebaseStorage

final class TranslationsUploaderFirebaseService {

    func uploadNewTranslations(translations: [(String, String)], forDevelop: Bool, completion: @escaping ()->()) {
        let translationFileName = forDevelop ? "texts_2_dev_nl.json" : "texts_2_nl.json"
        do {
            let translationFileReference = Storage.storage().reference().child(translationFileName)
            translationFileReference.getData(maxSize: 1 * 1024 * 1024) { [weak self] (data, error) in
                if let error = error {
                    self?.showAlert(question: "Error", text: error.localizedDescription)
                } else if let data = data {
                    if self?.validateNewTranslations(for: data, translations: translations) ?? false {
                        self?.addNewTranslations(to: data, translations: translations, fileName: translationFileName, completion: completion)
                    }
                }
            }
        }
    }

    private func validateNewTranslations(for data: Data, translations: [(String, String)]) -> Bool {
        do {
            if let dictionaryData = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                var areKeysUnique: Bool = true
                translations.forEach {
                    let key = $0.0
                    if dictionaryData.keys.contains(key) {
                        areKeysUnique = false
                        showAlert(question: "Key already exists", text: "Translation file contains already key \"\(key)\", please change it")
                    }
                }
                return areKeysUnique
            }
        } catch let error {
            showAlert(question: "Error", text: error.localizedDescription)
        }
        showAlert(question: "Error", text: "Something went wrong")
        return false
    }

    private func addNewTranslations(to data: Data, translations: [(String, String)], fileName: String, completion: ()->()) {
        var stringData = String(decoding: data, as: UTF8.self)
        stringData.removeLast(3)
        stringData.append(",")
        translations.forEach {
            let key = $0.0
            let value = $0.1
            let newKeyValue = "\n  \"\(key)\": \"\(value)\","
            stringData.append(newKeyValue)
        }
        stringData.removeLast(1)
        stringData.append("\n}")
        stringData.append("\n")

        if let dataFromString = stringData.data(using: .utf8), validateNewDataFile(data: dataFromString) {
            let translationFileReference = Storage.storage().reference().child(fileName)
            let metadata = StorageMetadata()
            metadata.contentType = "application/json"
            translationFileReference.putData(dataFromString, metadata: metadata)
            showAlert(question: "Success!", text: "Successfully added new translations")
            completion()
        }
    }

    private func validateNewDataFile(data: Data) -> Bool {
        do {
            if try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] != nil {
                return true
            } else {
                return false
            }
        } catch let error {
            showAlert(question: "Error", text: error.localizedDescription)
            return false
        }
    }

    func showAlert(question: String, text: String) {
        let alert = NSAlert()
        alert.messageText = question
        alert.informativeText = text
        alert.alertStyle = .warning
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }
}

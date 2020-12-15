import Cocoa
import FirebaseStorage

extension String: Error {}

final class TranslationsUploaderFirebaseService {

    func getTranslationsFileNames(completion: @escaping ([String])->()) {
        Storage.storage().reference().listAll { (result, error) in
            completion(result.items.map { $0.name })
        }
    }

    func getTranslationJson(translationFileName: String, completion: @escaping ([String: String])->()) {
        let translationFileReference = Storage.storage().reference().child(translationFileName)

        translationFileReference.getData(maxSize: 1 * 1024 * 1024) { data, error in
            if let error = error {
                debugPrint("Could not load language file \(translationFileName): \(error)")
            } else if let data = data {
                do {
                    if let translationsJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String] {
                        completion(translationsJSON)
                    }

                } catch let error {
                    print("Language file \(translationFileName) parsing failed with error: \(error)")
                }
            }
        }
    }

    func uploadNewTranslations(translations: [(String, String)], translationFileName: String, completion: ()->()) {
        var stringData = "{\n"
        translations.forEach {
            let key = $0.0
            let value = $0.1
            let newKeyValue = "  \"\(key)\": \"\(value)\",\n"
            stringData.append(newKeyValue)
        }
        stringData.removeLast(2)
        stringData.append("\n}")
        stringData.append("\n")

        if let dataFromString = stringData.data(using: .utf8), validateNewDataFile(data: dataFromString) {
            let translationFileReference = Storage.storage().reference().child(translationFileName)
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

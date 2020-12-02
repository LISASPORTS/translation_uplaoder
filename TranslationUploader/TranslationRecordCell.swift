import Cocoa

class TranslationRecordCell: NSTableCellView {

    @IBOutlet weak var keyLabel: NSTextField!
    @IBOutlet weak var valueLabel: NSTextField!
    @IBOutlet weak var separatorView: NSView!

    var removeRecord: ((_ key: String) -> ())?

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)

        separatorView.wantsLayer = true
        separatorView.layer?.backgroundColor = NSColor.lightGray.cgColor
    }
    
    @IBAction func removeRecordTapped(_ sender: Any) {
        removeRecord?(keyLabel.stringValue)
    }

    func set(record: (String, String)) {
        keyLabel.stringValue = record.0
        valueLabel.stringValue = record.1
    }
}

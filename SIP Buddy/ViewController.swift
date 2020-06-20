//
//  ViewController.swift
//  SIP Buddy
//
//  Created by Keaton Burleson on 6/20/20.
//  Copyright © 2020 Keaton Burleson. All rights reserved.
//

import Cocoa
import STPrivilegedTask

class ViewController: NSViewController {
    @IBOutlet var tableView: NSTableView!
    
    var statuses: [Status] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.statuses = self.getStatuses()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        print(self.statuses)
    }

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
    }

    func getStatuses() -> [Status] {
        var statuses: [Status] = []
        let statusTask = Process()
        let outputPipe = Pipe()

        statusTask.launchPath = "/usr/bin/csrutil"
        statusTask.arguments = ["status"]
        statusTask.standardOutput = outputPipe
        statusTask.launch()

        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        if let outputString = String(data: outputData, encoding: .utf8) {
            let outputLines = outputString.split(separator: "\n")

            statuses = outputLines[2...8].map {
                let statusData = String($0).replacingOccurrences(of: "\t", with: "").split(separator: ":")

                return Status(statusData.first!, statusData.last!)
            }
        }

        return statuses
    }
    
    
    @IBAction func toggleSIP(_ sender: NSButton) {
        sender.isEnabled = false
        
        let isDisabled = self.statuses.firstIndex { (status) -> Bool in
            return !status.isDisabled
        } == nil
        let toggleTask = STPrivilegedTask(launchPath: "/bin/bash")
        let execute = "/usr/bin/csrutil \(isDisabled ? "disable" : "disable") 2>&1"
        toggleTask?.setArguments(["-c", execute])
        
        toggleTask?.launch()
        toggleTask?.waitUntilExit()
        
        
        if let outputData = toggleTask?.outputFileHandle()?.readDataToEndOfFile(),
            let outputString = String(data: outputData, encoding: .utf8) {
            if (outputString.contains("failed")) {
                let alert = NSAlert()
                alert.messageText = "Could not disable SIP"
                alert.informativeText = outputString.replacingOccurrences(of: "csrutil: ", with: "")
                alert.addButton(withTitle: "OK")
                alert.alertStyle = .critical
                alert.runModal()
            }
        }
        
    }
}

extension ViewController: NSTableViewDataSource {

    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.statuses.count
    }

}

extension ViewController: NSTableViewDelegate {

    fileprivate enum CellIdentifiers {
        static let NameCell = "NameCell"
        static let StatusCell = "StatusCell"
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        var image: NSImage?
        var text: String = ""
        var cellIdentifier: String = ""


        let statusItem = self.statuses[row]


        if tableColumn == tableView.tableColumns[0] {
            text = statusItem.name
            cellIdentifier = CellIdentifiers.NameCell
        } else if tableColumn == tableView.tableColumns[1] {
            image = statusItem.isDisabled ? NSImage(named: "NSStatusUnavailable") : NSImage(named: "NSStatusAvailable")
            cellIdentifier = CellIdentifiers.StatusCell
        }


        if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: cellIdentifier), owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.imageView?.image = image ?? nil
            return cell
        }
        return nil
    }

}

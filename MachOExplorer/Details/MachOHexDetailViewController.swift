//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MachOHexDetailViewController.swift
//!
//! @author     D.V.
//! @copyright  Copyright (c) 2018 D.V. All rights reserved.
//|
//| Permission is hereby granted, free of charge, to any person obtaining a
//| copy of this software and associated documentation files (the "Software"),
//| to deal in the Software without restriction, including without limitation
//| the rights to use, copy, modify, merge, publish, distribute, sublicense,
//| and/or sell copies of the Software, and to permit persons to whom the
//| Software is furnished to do so, subject to the following conditions:
//|
//| The above copyright notice and this permission notice shall be included
//| in all copies or substantial portions of the Software.
//|
//| THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
//| OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//| MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
//| IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//| CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
//| TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
//| SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//----------------------------------------------------------------------------//

import Cocoa
import MachOKit

class MachOHexDetailViewController: MachODetailViewController
{
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var addressColumn: NSTableColumn!
    @IBOutlet weak var dataLoColumn: NSTableColumn!
    @IBOutlet weak var dataHiColumn: NSTableColumn!
    @IBOutlet weak var valueColumn: NSTableColumn!
    
    override func commonInit() {
        self.title = "Data"
    }
    
    var nodeAddress: mk_vm_address_t?
    var nodeData: Data?
    
    override var addressMode: MKNodeAddressType {
        didSet {
            if let model = self.model as? DataModel {
                self.nodeAddress = model.address(mode: self.addressMode) as! mk_vm_address_t?
            }
            
            update()
        }
    }
    
    override var model: Model? {
        didSet {
            guard self.model?.isEqual(oldValue) == false else { return }
            
            if let model = self.model as? DataModel {
                self.nodeAddress = model.address(mode: self.addressMode) as! mk_vm_address_t?
                self.nodeData = model.data
            } else {
                self.nodeAddress = nil
                self.nodeData = nil
            }
            
            update()
        }
    }
    
    func update() {
        if let tableView = self.tableView {
            tableView.reloadData()
        }
        
        if self.nodeData != nil {
            self.wantsDisplay = true
        } else {
            self.wantsDisplay = false
        }
    }
}


extension MachOHexDetailViewController: NSTableViewDataSource
{
    func numberOfRows(in tableView: NSTableView) -> Int {
        guard let nodeData = self.nodeData else { return 0 }
        
        var numRows = nodeData.count / 16
        if nodeData.count % 16 != 0 {
            numRows += 1
        }
        
        return numRows
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        guard let nodeData = self.nodeData else { return nil }
        
        let offset = row * 16
        
        if tableColumn == self.addressColumn, let baseAddress = self.nodeAddress {
            let address = Int(baseAddress) + offset
            
            return NSString(format: "%.8lX", address)
        }
        
        let len = min(nodeData.count - offset, 16)
        let start = offset
        let end = start + len
        
        var buffer = Array<UInt8>(repeating: 0, count: 16)
        nodeData.copyBytes(to: &buffer, from: start..<end)
        
        if tableColumn == self.dataLoColumn {
            return NSString(format: "%.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X ", buffer[0], buffer[1], buffer[2], buffer[3], buffer[4], buffer[5], buffer[6], buffer[7])
        }
        else  if tableColumn == self.dataHiColumn {
            return NSString(format: "%.2X %.2X %.2X %.2X %.2X %.2X %.2X %.2X ", buffer[8], buffer[9], buffer[10], buffer[11], buffer[12], buffer[13], buffer[14], buffer[15])
        }
        else if tableColumn == self.valueColumn {
            buffer = buffer.map({ byte -> UInt8 in
                if byte < 32 || byte > 126 {
                    return 46 // '.'
                } else {
                    return byte;
                }
            })
            
            return NSString(bytes: &buffer, length: buffer.count, encoding: String.Encoding.ascii.rawValue)
        }
        
        return nil
    }
}


extension MachOHexDetailViewController: NSTableViewDelegate
{
    class TableRow: NSTableRowView
    {
        override func drawSelection(in dirtyRect: NSRect) {
            super.drawSelection(in: dirtyRect)
            
            if self.interiorBackgroundStyle == .dark && self.isSelected && self.isEmphasized == false {
                NSColor(calibratedWhite: 78.0/255.0, alpha: 1.0).set()
                NSBezierPath.fill(self.bounds)
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return TableRow()
    }
}

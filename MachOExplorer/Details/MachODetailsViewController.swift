//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MachODetailsViewController.swift
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

class MachODetailsViewController: MachODetailViewController
{
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var addressColumn: NSTableColumn!
    @IBOutlet weak var dataColumn: NSTableColumn!
    @IBOutlet weak var descriptionColumn: NSTableColumn!
    @IBOutlet weak var valueColumn: NSTableColumn!
    
    override func commonInit() {
        self.title = "Details"
    }
    
    @IBOutlet var controller: NSArrayController!
    
    @objc dynamic var rowData: [Row] = []
    
    override var model: Model? {
        didSet {
            guard self.model?.isEqual(oldValue) == false else { return }
            
            if let model = self.model as? DetailModel {
                self.rowData = MachODetailsViewController.makeRowData(for: model) ?? []
            } else {
                self.rowData = []
            }
            
            update()
        }
    }
    
    override var addressMode: MKNodeAddressType {
        didSet {
            update()
        }
    }
    
    func update() {
        self.tableView?.deselectAll(self)
        
        if self.rowData.count > 0 {
            self.wantsDisplay = true
        } else {
            self.wantsDisplay = false
        }
        
        let formatter = MKHexNumberFormatter(digits: 8)
        formatter.uppercase = true
        formatter.omitPrefix = true
        
        for row in rowData {
            switch self.addressMode {
            case .contextAddress:
                row.address = formatter.string(for: row.rawAddress != nil ? row.rawAddress! as NSNumber : nil)
            case .vmAddress:
                row.address = formatter.string(for: row.rvaAddress != nil ? row.rvaAddress! as NSNumber : nil)
            }
        }
    }
}


extension MachODetailsViewController
{
    @objc(MachODetailsViewControllerRow)
    final class Row: NSObject {
        var rawAddress: mk_vm_address_t?
        var rvaAddress: mk_vm_address_t?
        
        @objc dynamic var address: String?
        @objc var data: String?
        @objc var name: String?
        @objc var value: String?
        
        var underline: Bool = false
        
        override var description: String {
            return self.name ?? ""
        }
    }
    
    static func makeRowData(for model: DetailModel) -> [Row]? {
        var previous: (UInt, Row)?
        
        return autoreleasepool {
            return model.detail_rows.map({ detailNode -> MachODetailsViewController.Row in
                let row = MachODetailsViewController.Row()
                
                if let contextAddress = detailNode.detail_address(mode: .contextAddress) {
                    row.rawAddress = contextAddress as! mk_vm_address_t
                }
                if let vmAddress = detailNode.detail_address(mode: .vmAddress) {
                    row.rvaAddress = vmAddress as! mk_vm_address_t
                }
                
                if var data = detailNode.detail_data {
                    let transformer = HexRepresentationValueTransformer()
                    
                    // Cap the number of bytes we will format
                    if data.count > 50 {
                        data = data.subdata(in: 0..<50)
                    }
                    
                    row.data = transformer.transformedValue(data) as? String;
                }
                
                row.name = detailNode.detail_description
                row.value = detailNode.detail_value
                
                let groupIdentifier: UInt
                if let detailNode = detailNode as? DetailRowDisplayModel {
                    groupIdentifier = detailNode.detail_group_identifier
                } else {
                    groupIdentifier = 0
                }
                
                if let (p, _) = previous, p != groupIdentifier {
                    row.underline = true
                }
                previous = (groupIdentifier, row)
                
                return row
            })
        }
    }
}


extension MachODetailsViewController: NSTableViewDelegate
{
    class TableRow: NSTableRowView
    {
        var border: Bool = false
        
        override func drawBackground(in dirtyRect: NSRect) {
            super.drawBackground(in: dirtyRect)
            
            if self.border {
                if let tableView = self.superview as? NSTableView {
                    tableView.gridColor.set()
                } else {
                    NSColor.separatorColor.set()
                }
                
                // Hack - tableView.gridColor does not look correct in dark mode
                if (self.effectiveAppearance.name == NSAppearance.Name.darkAqua) {
                    NSColor.lightGray.set()
                }
                
                NSBezierPath.strokeLine(
                    from: NSPoint(x: self.bounds.origin.x, y: self.bounds.origin.y),
                    to: NSPoint(x: self.bounds.origin.x + self.bounds.size.width, y: self.bounds.origin.y)
                )
            }
        }
    }
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        let rowView = TableRow()
        
        if self.rowData[row].underline {
            rowView.border = true
        }
        
        return rowView
    }
}

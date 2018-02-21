//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MKNode+Detail.swift
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

import MachOKit

extension MKNode /* DetailModel */
{
    override var detail_rows: [DetailRowModel] {
        var rows = Array<DetailRowModel>()
        
        let nodeLayout = self.layout
        let nodeFields = nodeLayout.allFields
        
        for field in nodeFields {
            guard field.options.contains(.displayAsDetail) || field.options.contains(.displayAsChild) == false else { continue }
            
            if let fieldAdapter = self.adapter(forField: field) {
                rows += fieldAdapter.detail_rows
            }
        }
        
        return rows
    }
}

extension MKNode /* DetailRowModel */
{
    override var detail_value: String? {
    #if TRACE_DESCRIPTIONS_AND_VALUES
        return "[N]" + self.description
    #else
        return self.description
    #endif
    }
    
    override var detail_description: String? {
    #if TRACE_DESCRIPTIONS_AND_VALUES
        return "[N]" + type(of: self).description()
    #else
        return type(of: self).description()
    #endif
    }
    
    override var detail_data: Data? {
        return nil
    }
    
    override func detail_address(mode addressMode: MKNodeAddressType) -> NSNumber? {
        return nil
    }
}

extension MKNode: DetailRowDisplayModel
{
    var detail_group_identifier: UInt {
        return unsafeBitCast(self, to: UInt.self)
    }
    
    var detail_backgroundColor: NSColor? {
        return nil
    }
}

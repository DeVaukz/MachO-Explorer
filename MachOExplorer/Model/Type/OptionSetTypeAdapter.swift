//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       OptionSetTypeAdapter.swift
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

class OptionSetTypeAdapter: TypeAdapter
{
    required init(value: NSObject, ofType type: MKNodeFieldType, inNode node: MKNode) {
        assert(type is MKNodeFieldOptionSetType)
        super.init(value: value, ofType: type, inNode: node)
    }
    
    override var providesSubFields: Bool { return true }
}

extension OptionSetTypeAdapter /* DetailModel, DetailRowModel */
{
    class OptionDetailRowAdapter: NSObject
    {
        let value: NSNumber
        let name: String
        
        init(_ value: NSNumber, _ name: String) {
            self.value = value
            self.name = name
        }
        
        override var detail_value: String? {
            return self.name
        }
        
        override var detail_description: String? {
            return Formatter.mk_hex().string(for: self.value)
        }
    }
    
    override var detail_rows: [DetailRowModel] {
        guard let value = self.value as? NSNumber else { return [] }
        
        let v: UInt64 = value.mk_UnsignedValue(nil)
        guard v != 0 else { return super.detail_rows }
        
        var rows = Array<DetailRowModel>()
        
        for (mask, name) in (self.type as! MKNodeFieldOptionSetType).options {
            let m: UInt64 = mask.mk_UnsignedValue(nil)
            
            if m == 0 && v != 0 {
                continue
            }
            
            if (v & m) == m {
                rows.append(OptionDetailRowAdapter(mask, name))
            }
        }
        
        return rows
    }
}

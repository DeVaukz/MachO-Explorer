//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       BitFieldTypeAdapter.swift
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

class BitfieldTypeAdapter: TypeAdapter
{
    required init(value: NSObject, ofType type: MKNodeFieldType, inNode node: MKNode) {
        assert(type is MKNodeFieldBitfieldType)
        super.init(value: value, ofType: type, inNode: node)
    }
    
    override var providesSubFields: Bool {
        let type = self.type as! MKNodeFieldBitfieldType
        
        if type.bits.count > 1 {
            return true
        } else {
            return false
        }
    }
}

extension BitfieldTypeAdapter /* DetailModel */
{
    override var detail_rows: [DetailRowModel] {
        guard let value = self.value as? NSNumber else { return super.detail_rows }
        
        let type = self.type as! MKNodeFieldBitfieldType
        var rows = Array<DetailRowModel>()
        
        for mask in type.bits {
            let maskedValue = value.mk_mask(using: mask)
            let shiftedValue = maskedValue.mk_shift(type.shift(forMask: mask))
            
            if let type = type.type(forMask: mask) {
                if type is MKNodeFieldEnumerationType {
                    rows += BitfieldEnumerationTypeAdapter(value: shiftedValue, unshiftedValue: maskedValue, ofType: type, inContainerType: self.type, inNode: self.node).detail_rows
                } else {
                    rows += TypeAdapter.For(value: shiftedValue, ofType: type, inNode: self.node).detail_rows
                }
            } else {
                // TODO -
                continue;
            }
        }
        
        return rows
    }
}



class BitfieldEnumerationTypeAdapter: TypeAdapter
{
    let unshiftedValue: NSObject
    let containerType: MKNodeFieldType
    
    required init(value: NSObject, unshiftedValue: NSObject, ofType type: MKNodeFieldType, inContainerType containerType: MKNodeFieldType, inNode node: MKNode) {
        assert(type is MKNodeFieldEnumerationType)
        self.unshiftedValue = unshiftedValue
        self.containerType = containerType
        super.init(value: value, ofType: type, inNode: node)
    }
    
    required init(value: NSObject, ofType type: MKNodeFieldType, inNode node: MKNode) {
        assert(type is MKNodeFieldContainerType)
        self.unshiftedValue = value
        self.containerType = type
        super.init(value: value, ofType: type, inNode: node)
    }
    
    override var detail_description: String? {
        switch (self.containerType as! MKNodeFieldNumericType).size(for: self.node) {
        case 1:
            return Formatter.mk_hex8().string(for: self.unshiftedValue)
        case 2:
            return Formatter.mk_hex16().string(for: self.unshiftedValue)
        case 4:
            return Formatter.mk_hex32().string(for: self.unshiftedValue)
        case 8:
            return Formatter.mk_hex64().string(for: self.unshiftedValue)
        default:
            return Formatter.mk_hex().string(for: self.unshiftedValue)
        }
    }
}

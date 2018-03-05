//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MKFixup+Model.swift
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

extension MKFixup /* DetailModel */
{
    override var detail_rows: [DetailRowModel] {
        return [self]
    }
}

extension MKFixup /* DetailRowModel */
{
    override var detail_value: String? {
        let addressField = self.layout.field(withName: "address", searchAllFields: false)!
        let address = addressField.valueFormatter?.string(for: addressField.valueRecipe.value(for: addressField, of: self).value)
        
        let sectionField = self.layout.field(withName: "section", searchAllFields: false)!
        let section = sectionField.valueRecipe.value(for: sectionField, of: self).value?.description
        
        if let section = section {
            return "\(address!) (\(section))"
        } else {
            return "\(address!)"
        }
    }
    
    override var detail_description: String? {
        let typeField = self.layout.field(withName: "type", searchAllFields: false)!
        let type = typeField.valueFormatter?.string(for: typeField.valueRecipe.value(for: typeField, of: self).value)
        
        return type
    }
}

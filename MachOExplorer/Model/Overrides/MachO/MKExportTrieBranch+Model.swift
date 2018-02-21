//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MKExportTrieBranch+Model.swift
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

extension MKExportTrieBranch
{
    @objc var address: mk_vm_address_t {
        return (self.nearestAncestor(ofType: MKExportsInfo.self) as! MKExportsInfo).nodeVMAddress + self.offset
    }
    
    override func adapter(forField field: MKNodeField) -> FieldAdapter? {
        if field.name == "offset" {
            let modifiedValueRecipe = MKNodeFieldOperationReadKeyPath(keyPath: "address")
            let modifiedField = MKNodeField(name: field.name, description: "Next Node", type: field.type, value: modifiedValueRecipe, data: field.dataRecipe, formatter: Formatter.mk_hexCompact(), options: field.options)
            
            return FieldAdapter(field: modifiedField, ofNode: self)
        } else {
            return super.adapter(forField: field)
        }
    }
}

extension MKExportTrieBranch /* DetailRowDisplayModel */
{
    override var detail_group_identifier: UInt {
        return unsafeBitCast(self.parent, to: UInt.self)
    }
}

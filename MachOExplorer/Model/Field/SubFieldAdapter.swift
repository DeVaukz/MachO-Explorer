//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       SubFieldAdapter.swift
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

class SubFieldAdapter: NSObject
{
    unowned let field: FieldAdapter
    let valueProvider: NSObject
    
    init(valueProvider: NSObject, inField field: FieldAdapter) {
        self.field = field
        self.valueProvider = valueProvider
    }
}

extension SubFieldAdapter /* OutlineNodeModel */
{
    override var outline_title: String {
        return self.valueProvider.outline_title
    }
}

extension SubFieldAdapter /* DetailRowModel */
{
    override var detail_value: String? {
        return self.valueProvider.detail_value
    }
    
    override var detail_description: String? {
        return self.valueProvider.detail_description
    }
}

extension SubFieldAdapter: DetailRowDisplayModel
{
    var detail_group_identifier: UInt {
        return self.field.detail_group_identifier
    }
    
    var detail_backgroundColor: NSColor? {
        return self.field.detail_backgroundColor
    }
}

//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       MKFunctionStarts+Model.swift
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

extension MKFunctionStarts /* OutlineNodeModel */
{
    override var outline_children: [OutlineNodeModel] {
        return []
    }
}

extension MKFunctionStarts /* DetailModel */
{
    class Adapter: NSObject {
        var offset: MKFunctionOffset?
        var function: MKFunction?
        
        init(offset: MKFunctionOffset?, function: MKFunction?) {
            super.init()
            self.offset = offset
            self.function = function
        }
        
        override var detail_value: String? {
            return self.function?.detail_value
        }
        
        override var detail_description: String? {
            return self.offset?.detail_value
        }
        
        override var detail_data: Data? {
            return self.offset?.detail_data
        }
        
        override func detail_address(mode addressMode: MKNodeAddressType) -> NSNumber? {
            return self.offset?.detail_address(mode: addressMode)
        }
    }
    
    override var detail_rows: [DetailRowModel] {
        var rows = Array<Adapter>()
        
        let offsets = self.offsets
        let functions = self.functions
        
        var i = 0;
        let count = max(offsets.count, functions.count)
        while i < count {
            let offset = i < offsets.count ? offsets[i] : nil
            let function = i < functions.count ? functions[i] : nil
            
            rows.append(Adapter(offset: offset, function: function))
            i = i + 1
        }
        
        return rows
    }
}

//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       CollectionTypeAdapter.swift
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

class CollectionTypeAdapter: TypeAdapter
{
    required init(value: NSObject, ofType type: MKNodeFieldType, inNode node: MKNode) {
        assert(type is MKNodeFieldCollectionType)
        super.init(value: value, ofType: type, inNode: node)
    }
}

extension CollectionTypeAdapter /* OutlineModel */
{
    override var outline_nodes: [OutlineNodeModel] {
        let collectionType = self.type as! MKNodeFieldCollectionType
        
        if let elementType = collectionType.elementType {
            return self.value.outline_nodes.reduce([], { $0 + TypeAdapter.For(value: $1 as! NSObject, ofType: elementType, inNode: self.node).outline_nodes })
        } else {
            return self.value.outline_nodes
        }
    }
}

extension CollectionTypeAdapter /* DetailModel */
{
    override var detail_rows: [DetailRowModel] {
        let collectionType = self.type as! MKNodeFieldCollectionType
        
        if let elementType = collectionType.elementType {
            return self.value.detail_rows.reduce([], { $0 + TypeAdapter.For(value: $1 as! NSObject, ofType: elementType, inNode: self.node).detail_rows })
        } else {
            return self.value.detail_rows
        }
    }
}

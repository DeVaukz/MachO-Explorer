//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       TypeAdapter.swift
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

class TypeAdapter: NSObject
{
    let value: NSObject
    let type: MKNodeFieldType
    
    init(for value: NSObject, ofType type: MKNodeFieldType) {
        self.value = value
        self.type = type
    }
}

extension TypeAdapter /* OutlineModel */
{
    override var outline_nodes: [OutlineNodeModel] {
        if let collectionType = self.type as? MKNodeFieldCollectionType {
            if let elementType = collectionType.elementType {
                return self.value.outline_nodes.reduce([], { $0 + TypeAdapter(for: $1 as! NSObject, ofType: elementType).outline_nodes })
            } else {
                return self.value.outline_nodes
            }
        }
        if self.type is MKNodeFieldNodeType {
            return self.value.outline_nodes
        }
        
        return [self]
    }
}

extension TypeAdapter /* OutlineNodeModel */
{
    override var outline_isLeaf: Bool {
        return self.value.outline_isLeaf
    }
    
    override var outline_childCount: Int {
        return self.value.outline_childCount
    }
    
    override var outline_children: [OutlineNodeModel] {
        return self.value.outline_children
    }
    
    override var outline_title: String {
        if let formatter = self.type.formatter,
           let formattedDescription = formatter.string(for: self.value) {
        #if TRACE_DESCRIPTIONS_AND_VALUES
            return "[T]" + formattedDescription
        #else
            return formattedDescription
        #endif
        } else {
        #if TRACE_DESCRIPTIONS_AND_VALUES
            return "[T]" + self.value.outline_title
        #else
            return self.value.outline_title
        #endif
        }
    }
}

extension TypeAdapter /* DetailModel */
{
    override var detail_rows: [DetailRowModel] {
        if let collectionType = self.type as? MKNodeFieldCollectionType {
            if let elementType = collectionType.elementType {
                return self.value.detail_rows.reduce([], { $0 + TypeAdapter(for: $1 as! NSObject, ofType: elementType).detail_rows })
            } else {
                return self.value.detail_rows
            }
        }
        if self.type is MKNodeFieldNodeType {
            return self.value.detail_rows
        }
        
        return [self]
    }
}

extension TypeAdapter /* DetailRowModel */
{
    override var detail_value: String? {
        if let formatter = self.type.formatter,
           let formattedDescription = formatter.string(for: self.value) {
        #if TRACE_DESCRIPTIONS_AND_VALUES
            return "[T]" + formattedDescription
        #else
            return formattedDescription
        #endif
        } else if let valueDescription = self.value.detail_value {
        #if TRACE_DESCRIPTIONS_AND_VALUES
            return "[T]" + valueDescription
        #else
            return valueDescription
        #endif
        } else {
            return nil
        }
    }
    
    override var detail_description: String? {
        return self.type.name
    }
    
    override var detail_data: Data? {
        return self.value.detail_data
    }
    
    override func detail_address(mode addressMode: MKNodeAddressType) -> NSNumber? {
        return self.value.detail_address(mode: addressMode)
    }
}

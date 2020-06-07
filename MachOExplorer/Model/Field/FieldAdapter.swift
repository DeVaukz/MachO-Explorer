//----------------------------------------------------------------------------//
//|
//|             MachOExplorer - A Graphical Mach-O Viewer
//! @file       FieldAdapter.swift
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

class FieldAdapter: NSObject
{
    let node: MKNode
    let field: MKNodeField
    
    var type: MKNodeFieldType? {
        return self.field.type
    }
    
    var value: NSObject! {
        let value = self.field.valueRecipe.value(for: self.field, of: self.node)
        return value.value as! NSObject?
    }
    
    var typeAdapter: TypeAdapter? {
        if let type = self.type {
            return TypeAdapter.For(value: self.value, ofType: type, inNode: self.node)
        } else {
            return nil
        }
    }
    
    var fieldIndex: UInt {
        let layout = self.node.layout
        var i: UInt = 0
        for field in layout.allFields {
            if field.name == self.field.name {
                break
            } else {
                i += 1
            }
        }
        return i
    }
    
    var alternateFieldAdapter: FieldAdapter? {
        if let alternateFieldName = self.field.alternateFieldName {
            if let field = self.node.layout.field(withName: alternateFieldName, searchAllFields: true) {
                return self.node.adapter(forField: field)
            }
        }
        
        return nil
    }
    
    init(field: MKNodeField, ofNode node: MKNode) {
        self.node = node
        self.field = field
    }
}

extension FieldAdapter /* OutlineModel */
{
    override var outline_nodes: [OutlineNodeModel] {
        guard self.field.options.contains(.hidden) == false else { return [] }
        guard self.field.options.contains(.displayAsChild) else { return [] }
        guard let value = self.value else { return [] }
        
        if field.options.contains(.mergeContainerContents) {
            if let collectionType = self.type as? MKNodeFieldCollectionType,
               let elementType = collectionType.elementType {
                return value.outline_nodes.reduce([], { $0 + TypeAdapter.For(value: $1 as! NSObject, ofType: elementType, inNode: self.node).outline_nodes })
            }
            else if self.type is MKNodeFieldContainerType {
                return value.outline_nodes
            }
            else if self.type is MKNodeFieldPointerType,
                 let pointer = value as? MKPointer<AnyObject> {
                if let pointee = pointer.pointee.value(forKey: "value") {
                    return (pointee as! NSObject).outline_nodes
                } else {
                    return []
                }
            }
        }
        
        // If the type is a pointer and there is no pointee, hide the field
        if self.type is MKNodeFieldPointerType,
           let pointer = value as? MKPointer<AnyObject>,
            pointer.pointee.value == nil {
            return []
        }
        
        // If the value is an MKNode then always merge the contents unless
        // the field options contains ignoreContainerContents.
        if value is MKNode && field.options.contains(.ignoreContainerContents) == false {
            return value.outline_nodes
        }
        
        return [self]
    }
}

extension FieldAdapter /* DetailModel */
{
    override var detail_rows: [DetailRowModel] {
        guard self.field.options.contains(.hidden) == false else { return [] }
        guard let value = self.value else { return [] }
        
        if field.options.contains(.displayAsDetail) || field.options.contains(.displayAsChild) == false
        {
            if field.options.contains(.mergeContainerContents) {
                if let collectionType = field.type as? MKNodeFieldCollectionType,
                   let elementType = collectionType.elementType {
                    let valueDetailRowModels = value.detail_rows
                    
                    var detailRowModels = Array<DetailRowModel>()
                    detailRowModels.reserveCapacity(valueDetailRowModels.count)
                    for item in valueDetailRowModels {
                        if item is FieldAdapter || item is SubFieldAdapter {
                            detailRowModels.append(item)
                        } else {
                            detailRowModels += TypeAdapter.For(value: item as! NSObject, ofType: elementType, inNode: self.node).detail_rows
                        }
                    }
                    
                    return detailRowModels
                }
                else if self.field.type is MKNodeFieldContainerType {
                    return value.detail_rows
                }
            }
            else if field.options.contains(.ignoreContainerContents) == false,
                    let typeAdapter = self.typeAdapter,
                    typeAdapter.providesSubFields {
                return [self] + typeAdapter.detail_rows.map({ detailRowModel -> SubFieldAdapter in
                    return SubFieldAdapter(valueProvider: detailRowModel as! NSObject, inField: self)
                })
            }
            
            return [self]
        }
        else if field.options.contains(.displayContainerContentsAsDetail)
        {
            if let collectionType = field.type as? MKNodeFieldCollectionType,
               let elementType = collectionType.elementType,
               elementType is MKNodeFieldTypeNode == false {
                return value.detail_rows.reduce([], { $0 + TypeAdapter.For(value: $1 as! NSObject, ofType: elementType, inNode: self.node).detail_rows })
            }
            else if self.field.type is MKNodeFieldContainerType {
                return value.detail_rows
            }
        }
        
        // If the type is a pointer, then we always proxy the contents
        if self.type is MKNodeFieldPointerType,
           let pointer = value as? MKPointer<AnyObject> {
            if let pointee = pointer.pointee.value(forKey: "value") {
                return (pointee as! NSObject).detail_rows
            } else {
                //return []
            }
        }
        
        return []
    }
}

extension FieldAdapter /* OutlineNodeModel */
{
    override var outline_isLeaf: Bool {
        return self.outline_childCount == 0
    }
    
    override var outline_childCount: Int {
        return self.outline_children.count
    }
    
    override var outline_children: [OutlineNodeModel] {
        if self.field.options.contains(.displayContainerContentsAsChild)
        {
            if let collectionType = field.type as? MKNodeFieldCollectionType {
                if let elementType = collectionType.elementType {
                    return value.outline_nodes.reduce([], { $0 + TypeAdapter.For(value: $1 as! NSObject, ofType: elementType, inNode: self.node).outline_nodes })
                } else {
                    return value.outline_nodes
                }
            }
        }
        
        // If the type is a pointer, then we always proxy the contents
        if self.type is MKNodeFieldPointerType,
           let pointer = value as? MKPointer<AnyObject> {
            if let pointee = pointer.pointee.value(forKey: "value") {
                return (pointee as! NSObject).outline_children
            } else {
                return []
            }
        }
        
        return self.value.outline_children
    }
    
    override var outline_title: String {
        if let description = self.field.description {
            return description
        } else {
            return self.field.name
        }
    }
}

extension FieldAdapter /* DetailRowModel */
{
    override var detail_value: String? {
        let fieldValue: String?
        let alternateValue: String? = self.alternateFieldAdapter?.detail_value
        
        if let alternateValue = alternateValue,
           self.field.options.contains(.substituteAlternateFieldValue) {
            return alternateValue
        }
        
        if self.field.options.contains(.ignoreContainerContents) == false,
           let typeAdapter = self.typeAdapter,
           typeAdapter.providesSubFields {
            return alternateValue
        }
        
        if let formatter = self.field.valueFormatter,
           let formattedDescription = formatter.string(for: self.value) {
            fieldValue = formattedDescription
        } else {
            fieldValue = self.value?.detail_value
        }
        
        if let alternateValue = alternateValue,
           let fieldValue = fieldValue,
           self.field.options.contains(.hideAlternateFieldValue) == false {
            return fieldValue + " (" + alternateValue + ")"
        } else {
            return fieldValue
        }
    }
    
    override var detail_description: String? {
        let fieldDescription: String?
        let alternateDescription: String? = self.alternateFieldAdapter?.detail_description
        
        if let alternateDescription = alternateDescription,
           self.field.options.contains(.substituteAlternateFieldDescription) {
            return alternateDescription
        }
        
        
        if let fd = self.field.description {
            fieldDescription = fd
        } else {
            fieldDescription = self.field.name
        }
        
        if let alternateDescription = alternateDescription,
           let fieldDescription = fieldDescription,
           self.field.options.contains(.showAlternateFieldDescription) {
            return fieldDescription + " (" + alternateDescription + ")"
        } else {
            return fieldDescription
        }
    }
    
    override var detail_data: Data? {
        guard self.field.options.contains(.hideData) == false else { return nil }
        
        if let dataRecipe = self.field.dataRecipe,
           let node = self.node as? MKBackedNode {
            return dataRecipe.data(for: self.field, of: node)
        } else {
            return self.value.detail_data
        }
    }
    
    override func detail_address(mode addressMode: MKNodeAddressType) -> NSNumber? {
        guard self.field.options.contains(.hideAddress) == false else { return nil }
        
        if let dataRecipe = self.field.dataRecipe,
           let node = self.node as? MKBackedNode {
            var addr: NSNumber?
            
            ExceptionSafePerform {
                addr = dataRecipe.address(addressMode.rawValue, of: self.field, of: node)
            }
            
            return addr
        }
        else if let node = self.node as? MKAddressedNode, self.fieldIndex == 0 {
            return node.nodeAddress(addressMode) as NSNumber
        }
        else {
            return self.value.detail_address(mode: addressMode)
        }
    }
}

extension FieldAdapter: DetailRowDisplayModel
{
    var detail_group_identifier: UInt {
        return self.node.detail_group_identifier
    }
    
    var detail_backgroundColor: NSColor? {
        return nil
    }
}

extension FieldAdapter: DataModel
{
    func address(mode addressMode: MKNodeAddressType) -> NSNumber? {
        if let dataRecipe = self.field.dataRecipe,
           let node = self.node as? MKBackedNode {
            return dataRecipe.address(addressMode.rawValue, of: self.field, of: node)
        } else {
            return nil
        }
    }
    
    var data: Data? {
        if let dataRecipe = self.field.dataRecipe,
           let node = self.node as? MKBackedNode {
            return dataRecipe.data(for: self.field, of: node)
        } else {
            return nil
        }
    }
}

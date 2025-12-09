//
//  FLEXSwiftMetadatas.swift
//  Reflex
//
//  Created by Tanner Bennett on 10/24/21.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

import FLEX
import Echo

extension SwiftMirror {
    static func imagePath(for pointer: UnsafeRawPointer) -> String? {
        var exeInfo = Dl_info()
        if (dladdr(pointer, &exeInfo) != 0) {
            if let fname = exeInfo.dli_fname {
                return String(cString: fname)
            }
        }
        
        return nil
    }
}

@objc(FLEXSwiftIvar)
public class SwiftIvar: FLEXIvar {
    
    convenience init(field: Field, class: ClassMetadata) {
        self.init(
            field: field,
            offset: `class`.fieldOffset(for: field.name)!,
            parent: `class`
        )
    }
    
    init(field: Field, offset: Int, parent: Metadata) {
        self.property = field
        self._offset = offset
        self._imagePath = SwiftMirror.imagePath(for: parent.ptr)
    }
    
    public override var name: String { self.property.name }
    public override var type: FLEXTypeEncoding { _typeChar }
    public override var typeEncoding: String { _typeEncodingString }
    public override var offset: Int { _offset }
    public override var size: UInt { UInt(self.property.type.vwt.size) }
    public override var imagePath: String? { self._imagePath }
    
    private let property: Field
    private let _offset: Int
    private let _imagePath: String?
    
    private lazy var _typeChar = self.property.type.typeEncoding
    private lazy var _typeEncodingString = self.property.type.typeEncodingString
    
    public override var details: String {
        "\(size) bytes, \(offset), \(typeEncoding)"
    }
    
    public override func description() -> String! {
        if self.type == .structBegin, let structMetadata = self.property.type as? StructMetadata {
            return "\(structMetadata.description) \(self.name)"
        }
        
        let desc = super.description()
        // Make things like `String *foo` appear as `String foo`
        if self.property.type.isNonTriviallyBridgedToObjc {
            return desc?.replacingOccurrences(of: " *", with: " ")
        }
        
        return desc
    }
    
    public override func getValue(_ target: Any) -> Any? {
        // Target must be AnyObject for KVC to work
        let target = target as AnyObject
        let type = reflect(target) as! ClassMetadata
        
        return type.getValueBox(forKey: self.name, from: target).toAny
    }
    
    public override func setValue(_ value: Any?, on target: Any) {
        // Target must be AnyObject for KVC to work
        let target = target as AnyObject
        let type = reflect(target) as! ClassMetadata
        
        if let value = value {
            // Not nil, nothing to do here
            type.set(value: value, forKey: self.name, pointer: target~)
        } else {
            // Value was nil; only supported on optional types or class types
            let kind = self.property.type.kind
            let nilValue: Any
            
            switch kind {
                case .enum:
                    nilValue = AnyExistentialContainer(nil: self.property.type as! EnumMetadata)
                case .class:
                    nilValue = AnyExistentialContainer(nil: self.property.type as! ClassMetadata)
                default:
                    fatalError("Attempting to set nil to non-optional property")
            }
            
            type.set(value: nilValue, forKey: self.name, pointer: target~)
        }
        
    }
    
    public override func getPotentiallyUnboxedValue(_ target: Any) -> Any? {
        return self.getValue(target)
    }
    
    public override func auxiliaryInfo(forKey key: String) -> Any? {
        switch key {
            case FLEXAuxiliarynfoKeyFieldLabels:
                return self.structFieldNamesDict(from: self.property.type.struct)
            default:
                return nil
        }
    }
    
    private func structFieldNamesDict(from metadata: StructMetadata?) -> [String: [String]] {
        guard let metadata = metadata else { return [:] }
        
        func typeAndLabels(from metadata: StructMetadata) -> (String, [String]) {
            let key = metadata.typeEncodingString
            let labels = metadata.fields.map { "\($0.type.description) \($0.name)" }
            return (key, labels)
        }
        
        let topLevel = typeAndLabels(from: metadata)
        var mapping = [topLevel.0: topLevel.1]
        
        let childTypes = metadata.fields
            .compactMap { $0.type.struct }
            .map { typeAndLabels(from: $0) }
        
        for (key, labels) in childTypes {
            mapping[key] = labels
        }
        
        return mapping
    }
}

fileprivate extension Metadata {
    var `struct`: StructMetadata? { self as? StructMetadata }
}

@objc(FLEXSwiftProtocol)
public class SwiftProtocol: FLEXProtocol {
    private let `protocol`: ProtocolDescriptor
    
    init(protocol ptcl: ProtocolDescriptor) {
        self.protocol = ptcl
        
        super.init()
    }
    
    public override var name: String {
        return self.protocol.name
    }
    
    public override var objc_protocol: Protocol {
        // Swift protocol requirements have no names (to my knowledge)
        // and a Swift protocol is not an objc object, so returning
        // this protocol is the best we can do, and has no drawbacks
        return NSObjectProtocol.self
    }
    
    private lazy var _imagePath: String? = {
        var exeInfo: Dl_info! = nil
        if (dladdr(self.protocol.ptr, &exeInfo) != 0) {
            if let fname = exeInfo.dli_fname {
                return String(cString: fname)
            }
        }
        
        return nil
    }()
    
    private lazy var swiftProtocols: [ProtocolDescriptor] = []
    
    public override var imagePath: String? { self._imagePath }
    
    public override var protocols: [FLEXProtocol] { self.swiftProtocols.map(SwiftProtocol.init(protocol:)) }
    public override var requiredMethods: [FLEXMethodDescription] { [] }
    public override var optionalMethods: [FLEXMethodDescription] { [] }
    
    public override var requiredProperties: [FLEXProperty] { [] }
    public override var optionalProperties: [FLEXProperty] { [] }
}

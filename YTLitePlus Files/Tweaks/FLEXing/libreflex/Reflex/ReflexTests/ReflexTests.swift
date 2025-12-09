//
//  ReflexTests.swift
//  ReflexTests
//
//  Created by Tanner Bennett on 4/8/21.
//

import XCTest
import Combine
import Echo
@testable import Reflex

class ReflexTests: XCTestCase {
    var bob = Employee(name: "Bob", age: 55, position: "Programmer")
    lazy var employee = reflectClass(bob)!
    lazy var person = employee.superclassMetadata!
    lazy var employeeFields = employee.descriptor.fields
    lazy var personFields = person.descriptor.fields
    
    func assertFieldsEqual(_ expectedNames: [String], _ fields: FieldDescriptor) {
        let fieldNames: Set<String> = Set(fields.records.map(\.name))
        XCTAssertEqual(fieldNames, Set(expectedNames))
    }
    
    func testPointerSemantics() {
        let point = Point(x: 5, y: 7)
        let yval = withUnsafeBytes(of: point) { (ptr) -> Int in
            return ptr.load(fromByteOffset: MemoryLayout<Int>.size, as: Int.self)
        }
        
        XCTAssertEqual(yval, 7)
    }
    
    func testKVCGetters() {
        assertFieldsEqual(["position", "salary", "cubicleSize"], employeeFields)
        assertFieldsEqual(["name", "age"], personFields)
        
        XCTAssertEqual(bob.position, employee.getValue(forKey: "position", from: bob))
        XCTAssertEqual(bob.salary, employee.getValue(forKey: "salary", from: bob))
        XCTAssertEqual(bob.cubicleSize, employee.getValue(forKey: "cubicleSize", from: bob))
        XCTAssertEqual(bob.name, person.getValue(forKey: "name", from: bob))
        XCTAssertEqual(bob.age, person.getValue(forKey: "age", from: bob))
    }
    
    func testKVCSetters() {
        person.set(value: "Robert", forKey: "name", on: &bob)
        XCTAssertEqual("Robert", bob.name)
        XCTAssertEqual(bob.name, person.getValue(forKey: "name", from: bob))
        
        person.set(value: 23, forKey: "age", on: &bob)
        XCTAssertEqual(23, bob.age)
        XCTAssertEqual(bob.age, person.getValue(forKey: "age", from: bob))
        
        employee.set(value: "Janitor", forKey: "position", on: &bob)
        XCTAssertEqual("Janitor", bob.position)
        XCTAssertEqual(bob.position, employee.getValue(forKey: "position", from: bob))
        
        employee.set(value: 3.14159, forKey: "salary", on: &bob)
        XCTAssertEqual(3.14159, bob.salary)
        XCTAssertEqual(bob.salary, employee.getValue(forKey: "salary", from: bob))
    }
    
    func testTypeNames() {
        XCTAssertEqual(person.descriptor.name, "Person")
    }
    
    func testAbilityToDetectSwiftTypes() {
        let nonSwiftObjects: [Any] = [
            NSObject.self,
            NSObject(),
            UIView.self,
            UIView(),
            "a string",
            12345,
            self.superclass!,
        ]
        
        let swiftObjects: [Any] = [
            ReflexTests.self,
            self,
            Person.self,
            bob,
            [1, 2, 3],
            [Point(x: 1, y: 2)]
        ]
        
        for obj in swiftObjects {
            XCTAssertTrue(isSwiftObjectOrClass(obj))
        }
        for obj in nonSwiftObjects {
            XCTAssertFalse(isSwiftObjectOrClass(obj))
        }
    }
    
    @available(iOS 13.0, *)
    func testTypeDescriptions() {
        typealias LongPublisher = Publishers.CombineLatest<AnyPublisher<Any, Error>,AnyPublisher<Any, Error>>
        
        XCTAssertEqual("Any",        reflect(Any.self).description)
        XCTAssertEqual("AnyObject",  reflect(AnyObject.self).description)
        XCTAssertEqual("AnyClass",   reflect(AnyClass.self).description)
        
        XCTAssertEqual("String?",              reflect(String?.self).description)
        XCTAssertEqual("Counter<Int>",         reflect(Counter<Int>.self).description)
        XCTAssertEqual("Array<Int>",           reflect([Int].self).description)
        XCTAssertEqual("(id: Int, 1: Person)", reflect((id: Int, Person).self).description)
        XCTAssertEqual("Counter<Int>",         reflect(Counter<Int>.self).description)
        XCTAssertEqual("Array<Counter<Int>>",  reflect([Counter<Int>].self).description)
        XCTAssertEqual("CombineLatest<AnyPublisher<Any, Error>, AnyPublisher<Any, Error>>",
                       reflect(LongPublisher.self).description
        )
        
        let ikur: (inout Person) -> Bool = isKnownUniquelyReferenced
        XCTAssertEqual("(ReflexTests) -> () -> ()", reflect(Self.testTypeDescriptions).description)
        XCTAssertEqual("(Person) -> Bool", reflect(ikur).description)
    }
    
    func testValueDescriptions() {
        
    }
    
    func testTypeEncodings() {
        let rect = reflect(CGRect.self)
        XCTAssertEqual(rect.typeEncodingString, "{CGRect={CGPoint=dd}{CGSize=dd}}")
        
        let size = reflect(Size.self)
        XCTAssertEqual(size.typeEncodingString, "{Size=qq}")
    }
    
    func testStructFieldLabels() {
        let mirror = SwiftMirror(reflecting: Sprite.self)
        let structIvar = mirror.ivars.first(where: { $0.name == "boundingBox" })!
        
        let info = structIvar.auxiliaryInfo(forKey: FLEXAuxiliarynfoKeyFieldLabels)
        if let labels = info as? [String: [String]] {
            XCTAssertEqual(labels.count, 3)
            XCTAssertEqual(labels["{Rect={Point=qq}{Size=qq}}"], ["Point origin", "Size size"])
            XCTAssertEqual(labels["{Point=qq}"], ["Int x", "Int y"])
            XCTAssertEqual(labels["{Size=qq}"], ["Int width", "Int height"])
        } else {
            XCTFail()
        }
    }
    
    func testSwiftMirrorAvailable() {
        XCTAssertNotNil(NSClassFromString("FLEXSwiftMirror"))
    }
    
    func testSwiftMirror() {
        let slider = RFSlider(color: .red, frame: .zero)
        let sliderMirror = SwiftMirror(reflecting: slider)
        let bob = Employee(name: "Bob", age: 45, position: "Programmer", salary: 100_000)
        let employeeMirror = SwiftMirror(reflecting: bob)
        
        XCTAssertEqual(sliderMirror.ivars.count, 8)
        XCTAssertEqual(sliderMirror.properties.count, 1)
        XCTAssertEqual(sliderMirror.methods.count, 6)
        XCTAssertEqual(sliderMirror.protocols.count, 1)
        
        slider.tag = 0xAABB
        
        // Swift mirror //
        
        let smirror = Mirror(reflecting: slider)
        let smtag = smirror.children.filter { $0.label == "tag" }.first!.value as! Int
        XCTAssertEqual(smtag, slider.tag)
        
        // Echo //
        let tagp = sliderMirror.ivars.filter { $0.name == "tag" }.first!
        let titlep = sliderMirror.ivars.filter { $0.name == "title" }.first!
        let subtitlep = sliderMirror.ivars.filter { $0.name == "subtitle" }.first!
        let sizep = employeeMirror.ivars.filter { $0.name == "cubicleSize" }.first!
        
        // Read
        let tag: Int = tagp.getValue(slider) as! Int
        XCTAssertEqual(tag, slider.tag)
        // Write
        tagp.setValue(0xDDCC, on: slider)
        XCTAssertEqual(0xDDCC, slider.tag)
        let newTag = tagp.getValue(slider) as! Int
        XCTAssertEqual(newTag, slider.tag)
        
        // Type encodings
        XCTAssertEqual(tagp.type, .longLong)
        XCTAssertEqual(tagp.typeEncoding, "q")
        XCTAssertEqual(tagp.description, "NSInteger tag")
        XCTAssertEqual(titlep.description, "String title")
        XCTAssertEqual(subtitlep.description, "String? subtitle")
        XCTAssertEqual(sizep.description, "Size cubicleSize")
    }
}

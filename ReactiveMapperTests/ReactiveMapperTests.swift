//
//  ReactiveMapperTests.swift
//  ReactiveMapperTests
//
//  Created by Alexander Schuch on 11/11/16.
//  Copyright © 2016 Alexander Schuch. All rights reserved.
//

import XCTest
import ReactiveSwift
@testable import ReactiveMapper

class ReactiveMapperTests: XCTestCase {

    let mockData = MockDataLoader()

    func testMapToObject() {
        var user: User?
        mockData.dictionary("user")
            .mapToType(User.self)
            .startWithResult { user = $0.value }

        XCTAssertNotNil(user, "mapToType should not return nil user")
    }

    func testMapToObjectArray() {
        var tasks: [Task]?
        mockData.array("tasks")
            .mapToTypeArray(Task.self)
            .startWithResult { tasks = $0.value }

        XCTAssertNotNil(tasks, "mapToType should not return nil tasks")
        XCTAssertTrue((tasks!).count == 3, "mapJSON returned wrong number of tasks")
    }

    func testInvalidTasks() {
        var invalidTasks: [Task]? = nil
        mockData.array("tasks_invalid")
            .mapToTypeArray(Task.self)
            .startWithResult { invalidTasks = $0.value }

        XCTAssert(invalidTasks == nil, "mapToType should return nil tasks for invalid JSON")
    }

    func testInvalidUser() {
        var invalidUser: User? = nil
        mockData.dictionary("user_invalid")
            .mapToType(User.self)
            .startWithResult { invalidUser = $0.value }

        XCTAssert(invalidUser == nil, "mapToType should return nil user for invalid JSON")
    }

    func testUnderlyingError() {
        var error: ReactiveMapperError?
        let sentError = NSError(domain: "test", code: -9000, userInfo: nil)
        let (signal, sink) = Signal<Any, NSError>.pipe()

        signal.mapToType(User.self).observeFailed { error = $0 }
        sink.send(error: sentError)

        XCTAssertNotNil(error, "error should not be nil")
        XCTAssertEqual(error?.nsError, sentError, "the sent error should be wrapped in an .Underlying error")
    }

    func testMapToObjectRootKey() {
        var user: User?
        mockData.dictionary("user_rootkey")
            .mapToType(User.self, rootKeys: ["user"])
            .startWithResult { user = $0.value }

        XCTAssertNotNil(user, "mapToType should not return nil user")
    }

    func testMapToObjectArrayRootKey() {
        var tasks: [Task]?
        mockData.dictionary("tasks_rootkey")
            .mapToTypeArray(Task.self, rootKeys: ["tasks"])
            .startWithResult { tasks = $0.value }

        XCTAssertNotNil(tasks, "mapToType should not return nil tasks")
        XCTAssertTrue((tasks!).count == 3, "mapJSON returned wrong number of tasks")
    }

    func testMapToObjectArrayMultipleRootKey() {
        var tasks: [Task]?
        mockData.dictionary("tasks_multiplerootkey")
            .mapToTypeArray(Task.self, rootKeys: ["taskList", "tasks"])
            .startWithResult { tasks = $0.value }

        XCTAssertNotNil(tasks, "mapToType should not return nil tasks")
        XCTAssertTrue((tasks!).count == 3, "mapJSON returned wrong number of tasks")
    }

    func testMapToObjectArrayInnerRootKey() {
        var tasks: [Task]?
        mockData.dictionary("tasks_innerrootkey")
            .mapToTypeArray(Task.self, rootKeys: ["tasks"], innerRootKeys: ["task"])
            .startWithResult { tasks = $0.value }

        XCTAssertNotNil(tasks, "mapToType should not return nil tasks")
        XCTAssertTrue((tasks!).count == 3, "mapJSON returned wrong number of tasks")
    }

    func testMapToObjectArrayMultipleInnerRootKey() {
        var tasks: [Task]?
        mockData.dictionary("tasks_multipleinnerrootkey")
            .mapToTypeArray(Task.self, rootKeys: ["taskList", "tasks"], innerRootKeys: ["task", "t"])
            .startWithResult { tasks = $0.value }

        XCTAssertNotNil(tasks, "mapToType should not return nil tasks")
        XCTAssertTrue((tasks!).count == 3, "mapJSON returned wrong number of tasks")
    }

}

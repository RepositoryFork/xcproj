import Foundation
import PathKit
import XCTest
@testable import xcproj

class PathHelpersSpec: XCTestCase {

    func test_fixtureProject_returnsCorrectName() {
        let fixtures = Path(#file).parent().parent().parent() + Path("Fixtures")
        let iosProjectPath = fixtures + Path("iOS/Project.xcodeproj/project.pbxproj")
        let projectName = iosProjectPath.projectName()
        XCTAssertEqual(projectName, "Project")
    }

    func test_pathWithPBXProj_returnsXcodeprojName() {
        let projectName = Path("iOS/MyProject.xcodeproj/project.pbxproj").projectName()
        XCTAssertEqual(projectName, "MyProject")
    }

    func test_pathWithoutPBXproj_doesNotReturnProjectName() {
        let projectName = Path("iOS/project.pbxproj").projectName()
        XCTAssertNil(projectName)
    }
}

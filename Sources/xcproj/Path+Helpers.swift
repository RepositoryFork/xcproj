import PathKit

// MARK: - Path Extension (Extras)

extension Path {

    /// - Returns: Base name for xcodeproj directory
    internal func projectName() -> String? {
        if parent().extension == "xcodeproj" {
            return parent().lastComponentWithoutExtension
        } else {
            return nil
        }
    }

}

import UIKit
import Flutter

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // App-managed files must not enter an iCloud/device backup. Configure the
    // parent directories before plugins create Firestore, picker or cache data.
    let fileManager = FileManager.default
    for directory in [FileManager.SearchPathDirectory.documentDirectory,
                      FileManager.SearchPathDirectory.libraryDirectory] {
      guard var url = fileManager.urls(for: directory, in: .userDomainMask).first else {
        return false
      }
      do {
        try fileManager.createDirectory(at: url, withIntermediateDirectories: true)
        var values = URLResourceValues()
        values.isExcludedFromBackup = true
        try url.setResourceValues(values)
        try fileManager.setAttributes(
          [.protectionKey: FileProtectionType.completeUntilFirstUserAuthentication],
          ofItemAtPath: url.path
        )
      } catch {
        // Do not start an app handling sensitive data without this protection.
        return false
      }
    }
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

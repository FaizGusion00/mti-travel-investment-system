import Flutter
import UIKit
import BackgroundTasks

@main
@objc class AppDelegate: FlutterAppDelegate {
  // App version constant for logging
  private let appVersion = "0.0.4"
  
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Log app startup with version information
    NSLog("MTI Travel Investment v\(appVersion) starting up...")
    
    // Configure application appearance
    configureAppAppearance()
    
    // Register Flutter plugins
    GeneratedPluginRegistrant.register(with: self)
    
    // Configure performance optimizations
    configurePerformanceSettings()
    
    // Return super implementation result
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  
  // MARK: - Configuration Methods
  
  private func configureAppAppearance() {
    if #available(iOS 13.0, *) {
      // Force app to use dark mode
      UIApplication.shared.windows.forEach { window in
        window.overrideUserInterfaceStyle = .dark
      }
    }
  }
  
  private func configurePerformanceSettings() {
    // Optimize memory usage
    if #available(iOS 13.0, *) {
      // Enable memory usage optimization for newer iOS versions
      let scene = UIApplication.shared.connectedScenes.first
      if let windowScene = scene as? UIWindowScene {
        windowScene.performanceHintRenderingLabel = .preferPerformance
      }
    }
    
    // Set up background task handling
    if #available(iOS 13.0, *) {
      BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.mti.travel.investment.refresh", using: nil) { task in
        // Handle background refresh task
        self.handleBackgroundRefresh(task: task as! BGAppRefreshTask)
      }
    }
  }
  
  // MARK: - Background Task Handling
  
  @available(iOS 13.0, *)
  private func handleBackgroundRefresh(task: BGAppRefreshTask) {
    // Schedule a new refresh task
    scheduleBackgroundRefresh()
    
    // Create task request with a 30-second timeout
    let taskID = UIApplication.shared.beginBackgroundTask {
      // Handle timeout by completing the background task
      task.setTaskCompleted(success: false)
    }
    
    // Simulate network operation (this would be replaced with real refresh logic)
    DispatchQueue.global().async {
      // Mark the task complete
      task.setTaskCompleted(success: true)
      
      // End the background task
      UIApplication.shared.endBackgroundTask(taskID)
    }
  }
  
  @available(iOS 13.0, *)
  private func scheduleBackgroundRefresh() {
    let request = BGAppRefreshTaskRequest(identifier: "com.mti.travel.investment.refresh")
    request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60) // 15 minutes
    
    do {
      try BGTaskScheduler.shared.submit(request)
    } catch {
      NSLog("Could not schedule app refresh: \(error)")
    }
  }
}

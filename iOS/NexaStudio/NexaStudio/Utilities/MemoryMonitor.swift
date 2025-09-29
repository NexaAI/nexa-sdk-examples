import Foundation

class MemoryMonitor {
    private var start: UInt64 = 0
    private var end: UInt64 = 0
    private var peak: UInt64 = 0
    private var samplingQueue: DispatchQueue?
    private var semaphore: DispatchSemaphore?
    private var isMonitoring = false

    static let shared = MemoryMonitor()

    private init() {}

    /// GB
    static var totalDeviceMemory: Double {
        Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024 / 1024
    }

    static func currentMemoryUsage() -> UInt64 {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        if kerr == KERN_SUCCESS {
            return info.resident_size
        } else {
            return 0
        }
    }

    func begin() {
        guard !isMonitoring else { return }
        isMonitoring = true
        start = Self.currentMemoryUsage()
        peak = start
        semaphore = DispatchSemaphore(value: 0)
        samplingQueue = DispatchQueue(label: "memory.monitor.sampling")
        samplingQueue?.async { [weak self] in
            guard let self = self, let semaphore = self.semaphore else { return }
            while semaphore.wait(timeout: .now() + 0.01) == .timedOut {
                let usage = Self.currentMemoryUsage()
                if usage > self.peak { self.peak = usage }
            }
        }
    }

    func stop() {
        guard isMonitoring else { return }
        end = Self.currentMemoryUsage()
        semaphore?.signal()
        Thread.sleep(forTimeInterval: 0.02)
        isMonitoring = false
    }

    var startMemory: Double { Double(start) / 1024 / 1024 }
    var endMemory: Double { Double(end) / 1024 / 1024 }
    var peakMemory: Double { Double(peak) / 1024 / 1024 }
}

class MemoryMonitorScope {
    init() {
        MemoryMonitor.shared.begin()
    }
    deinit {
        MemoryMonitor.shared.stop()
    }

    var startMemory: Double { MemoryMonitor.shared.startMemory }
    var endMemory: Double { MemoryMonitor.shared.endMemory }
    var peakMemory: Double { MemoryMonitor.shared.peakMemory }
}

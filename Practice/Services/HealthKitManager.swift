import HealthKit

final class HealthKitManager: @unchecked Sendable {
    static let shared = HealthKitManager()

    private let store = HKHealthStore()

    private var isAvailable: Bool {
        HKHealthStore.isHealthDataAvailable()
    }

    private init() {}

    func requestAuthorization() async -> Bool {
        guard isAvailable,
              let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)
        else { return false }

        do {
            try await store.requestAuthorization(toShare: [mindfulType], read: [])
            return true
        } catch {
            return false
        }
    }

    func saveMindfulSession(start: Date, end: Date) async {
        guard isAvailable,
              let mindfulType = HKObjectType.categoryType(forIdentifier: .mindfulSession)
        else { return }

        let sample = HKCategorySample(
            type: mindfulType,
            value: HKCategoryValue.notApplicable.rawValue,
            start: start,
            end: end
        )

        do {
            try await store.save(sample)
        } catch {
            print("HealthKitManager: failed to save mindful session: \(error)")
        }
    }
}

import CoreData
import FHBFoundation

public final class PersistenceController: Sendable {
    public static let shared = PersistenceController()

    public let container: NSPersistentContainer

    private let logger = FHBLogger(category: "Persistence")

    public init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "FanhB")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        } else if let appGroupURL = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.com.fanhb.shared"
        ) {
            let storeURL = appGroupURL.appendingPathComponent("FanhB.sqlite")
            let description = NSPersistentStoreDescription(url: storeURL)
            description.shouldMigrateStoreAutomatically = true
            description.shouldInferMappingModelAutomatically = true
            container.persistentStoreDescriptions = [description]
        }

        container.loadPersistentStores { [weak self] _, error in
            if let error {
                self?.logger.fault("Failed to load persistent store: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    public func newBackgroundContext() -> NSManagedObjectContext {
        let ctx = container.newBackgroundContext()
        ctx.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return ctx
    }
}

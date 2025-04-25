import Foundation
import StoreKit

class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var isSubscribed = false
    @Published var trialDaysRemaining: Int?
    @Published var subscriptionStatus: SubscriptionStatus = .notSubscribed
    
    enum SubscriptionStatus {
        case notSubscribed
        case inTrial(remainingDays: Int)
        case subscribed
    }
    
    private let subscriptionProductID = "com.infinivision.monthly"
    private let trialKey = "trialStartDate"
    private let subscriptionKey = "subscriptionStatus"
    
    private init() {
        loadSubscriptionStatus()
    }
    
    private func loadSubscriptionStatus() {
        if let trialStartDate = UserDefaults.standard.object(forKey: trialKey) as? Date {
            let trialEndDate = Calendar.current.date(byAdding: .day, value: 3, to: trialStartDate)!
            let remainingDays = Calendar.current.dateComponents([.day], from: Date(), to: trialEndDate).day ?? 0
            
            if remainingDays > 0 {
                trialDaysRemaining = remainingDays
                subscriptionStatus = .inTrial(remainingDays: remainingDays)
            } else {
                checkSubscription()
            }
        } else {
            startTrial()
        }
    }
    
    private func startTrial() {
        UserDefaults.standard.set(Date(), forKey: trialKey)
        trialDaysRemaining = 3
        subscriptionStatus = .inTrial(remainingDays: 3)
    }
    
    private func checkSubscription() {
        // Implement StoreKit subscription verification
        // This is a placeholder for the actual implementation
        isSubscribed = UserDefaults.standard.bool(forKey: subscriptionKey)
        subscriptionStatus = isSubscribed ? .subscribed : .notSubscribed
    }
    
    func purchaseSubscription() async throws {
        // Implement StoreKit purchase flow
        // This is a placeholder for the actual implementation
        let products = try await Product.products(for: [subscriptionProductID])
        guard let product = products.first else { return }
        
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            // Verify the transaction
            switch verification {
            case .verified(let transaction):
                await transaction.finish()
                UserDefaults.standard.set(true, forKey: subscriptionKey)
                isSubscribed = true
                subscriptionStatus = .subscribed
            case .unverified:
                throw SubscriptionError.verificationFailed
            }
        case .pending:
            throw SubscriptionError.pending
        case .userCancelled:
            throw SubscriptionError.cancelled
        @unknown default:
            throw SubscriptionError.unknown
        }
    }
    
    enum SubscriptionError: Error {
        case verificationFailed
        case pending
        case cancelled
        case unknown
    }
} 
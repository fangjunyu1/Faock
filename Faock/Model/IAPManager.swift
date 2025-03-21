//
//  IAPManager.swift
//  Faock
//
//  Created by 方君宇 on 2025/3/15.
//

import Foundation
//
//  IAPManager.swift
//  piglet
//
//  Created by 方君宇 on 2024/5/29.
//

import StoreKit

@available(iOS 15.0, *)
class IAPManager:ObservableObject {
    static let shared = IAPManager()
    
    private init() {}
    
    @Published var productID = ["GameMembership20250315"]  //  需要内购的产品ID数组
    @Published var products: [Product] = []    // 存储从 App Store 获取的内购商品信息
    @Published var loadPurchased = false    // 如果开始内购流程，loadPurchased为true，View视图显示加载画布
    
    // 视图自动加载loadProduct()方法
    func loadProduct() async {
        do {
            // 传入 productID 产品ID数组，调取Product.products接口从App Store返回产品信息
            // App Store会返回对应的产品信息，如果数组中个别产品ID有误，只会返回正确的产品ID的产品信息
            let fetchedProducts = try await Product.products(for: productID)
            if fetchedProducts.isEmpty {    // 判断返回的是否是否为空
                // 抛出内购信息为空的错误,可能是所有的产品ID都不存在，中断执行，不会return返回products产品信息
                throw StoreError.IAPInformationIsEmpty
            }
            DispatchQueue.main.async {
                self.products = fetchedProducts  // 将获取的内购商品保存到products变量
                print("products:\(self.products)")
            }
            print("成功加载产品: \(products)")    // 输出内购商品数组信息
        } catch {
            print("加载产品失败：\(error)")    // 输出报错
        }
    }
    
    // purchaseProduct：购买商品的方法，返回购买结果
    func purchaseProduct(_ product: Product) {
        // 在这里输出要购买的商品id
        print("Purchasing product: \(product.id)")
        Task {  @MainActor in
            do {
                let result = try await product.purchase()
                switch result {
                case .success(let verification):    // 购买成功的情况，返回verification包含交易的验证信息
                    let transaction = try checkVerified(verification)    // 验证交易
                    savePurchasedState(for: product.id)    // 更新UserDefaults中的购买状态
                    await transaction.finish()    // 告诉系统交易完成
                    print("交易成功：\(result)")
                case .userCancelled:    // 用户取消交易
                    print("用户取消交易：\(result)")
                case .pending:    // 购买交易被挂起
                    print("购买交易被挂起：\(result)")
                default:    // 其他情况
                    throw StoreError.failedVerification    // 购买失败
                }
            } catch {
                print("购买失败：\(error)")
                await resetProduct()    // 购买失败后重置 product 以便允许再次尝试购买
            }
            DispatchQueue.main.async {
                self.loadPurchased = false   // 隐藏内购时的加载画布
            }
            print("loadPurchased:\(loadPurchased)")
        }
    }
    // 验证购买结果
    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:    // unverified校验失败，StoreKit不能确定交易有效
            print("校验购买结果失败")
            throw StoreError.failedVerification
        case .verified(let signedType):    // verfied校验成功
            print("校验购买结果成功")
            return signedType    // StoreKit确认本笔交易信息由苹果服务器合法签署
        }
    }
    // handleTransactions处理所有的交易情况
    func handleTransactions() async {
        print("进入handleTransactions方法")
        for await result in Transaction.updates {
            // 遍历当前所有已完成的交易
            do {
                let transaction = try checkVerified(result) // 验证交易
                print("transaction:\(transaction)")
                
                // 处理交易，例如解锁内容
                savePurchasedState(for: transaction.productID)
                await transaction.finish()
            } catch {
                print("交易处理失败：\(error)")
            }
        }
    }
    
    // 检查所有交易，如果用户退款，则取消内购标识。
    func checkAllTransactions() async {
        print("开始检查所有交易记录...")
        let allTransactions = Transaction.all
        var latestTransactions: [String: Transaction] = [:]
        
        for await transaction in allTransactions {
            do {
                let verifiedTransaction = try checkVerified(transaction)
                print("verifiedTransaction:\(verifiedTransaction)")
                // 只保留最新的交易
                if let existingTransaction = latestTransactions[verifiedTransaction.productID] {
                    if verifiedTransaction.purchaseDate > existingTransaction.purchaseDate {
                        latestTransactions[verifiedTransaction.productID] = verifiedTransaction
                    }
                } else {
                    latestTransactions[verifiedTransaction.productID] = verifiedTransaction
                }
            } catch {
                print("交易验证失败：\(error)")
            }
        }
        
        var validPurchasedProducts: Set<String> = []
        
        // 处理最新的交易
        for (productID, transaction) in latestTransactions {
            if let revocationDate = transaction.revocationDate {
                print("交易 \(productID) 已退款，撤销日期: \(revocationDate)")
                removePurchasedState(for: productID)
            } else {
                validPurchasedProducts.insert(productID)
                savePurchasedState(for: productID)
            }
        }
        
        // **移除所有未在最新交易中的商品**
        let allPossibleProductIDs: Set<String> = Set(productID) // 所有可能的商品 ID
        let productsToRemove = allPossibleProductIDs.subtracting(validPurchasedProducts)
        
        for id in productsToRemove {
            removePurchasedState(for: id)
        }
    }
    
    // 当购买失败时，会尝试重新加载产品信息。
    func resetProduct() async {
        self.products = []
        await loadProduct()    // 调取loadProduct方法获取产品信息
    }
    // 保存购买状态到用户偏好设置或其他存储位置
    func savePurchasedState(for productID: String) {
        AppStorageManager.shared.isInAppPurchase = true // 设置 AppStorageManager 的内购标识为 true
        print("保存购买状态: \(productID)")
    }
    // 移除内购状态
    func removePurchasedState(for productID: String) {
        AppStorageManager.shared.isInAppPurchase = false    // 设置 AppStorageManager 的内购标识为 false
        print("已移除购买状态: \(productID)")
    }
    
    // 通过productID检查是否已完成购买
    func loadPurchasedState(for productID: String) -> Bool{
        let isPurchased = AppStorageManager.shared.isInAppPurchase    // UserDefaults读取购买状态
        print("Purchased state loaded for product: \(productID) - \(isPurchased)")
        return isPurchased    // 返回购买状态
    }
    
    // 调用恢复购买的函数
    func restorePurchases() async {
        let entitlements = Transaction.currentEntitlements
        var hasTransactions = false
        print("开始等待 Transaction.currentEntitlements")
        for await result in entitlements {
            hasTransactions = true
            print("发现交易：\(result)")
            switch result {
            case .verified(let transaction):
                print("处理已验证的交易")
                // 处理已验证的交易
                await handleVerifiedTransaction(transaction)
            case .unverified(_, let error):
                print("交易未验证，错误：\(error.localizedDescription)")
            }
        }
        
        if !hasTransactions {
            print("没有找到任何有效的交易，可能是用户没有购买过任何项目")
        }
    }
    
    // 处理已验证的交易
    func handleVerifiedTransaction(_ transaction: Transaction) async {
        print("transaction:\(transaction)")
        switch transaction.productType {
        case .nonConsumable, .autoRenewable, .nonRenewable:
            print("已恢复商品：\(transaction.productID)")
            savePurchasedState(for: transaction.productID)
        default:
            print("其他类型商品无需恢复")
        }
    }
}
// 定义 throws 报错
enum StoreError: Error {
    case IAPInformationIsEmpty
    case failedVerification
    case invalidURL
    case serverVerificationFailed
}

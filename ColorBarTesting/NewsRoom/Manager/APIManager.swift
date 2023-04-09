//
//  APIManager.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/3.
//

import Foundation

struct APIManager {
    static var shared = APIManager()
    let semaphore = DispatchSemaphore (value: 10)
    var requests: [URLRequest: URLSessionDataTask] = [:]

    
    static func DataRequest<T:Decodable>(router: APIClientConfig, completion: @escaping (Result<T, Error>)->Void) {
        var request = URLRequest(url: URL(string: router.path)!)
        request.httpMethod = router.httpMethod
        if let query = router.queryParameter {
            let filterQuery = query.filter { item in
                !item.value!.isEmpty
            }
            request.url?.append(queryItems: filterQuery)
        }
        
        // 檢查是否已經有相同的 request 正在進行
        if self.shared.requests[request] != nil {
             print("Request in progress: \(router.path)")
             self.shared.semaphore.signal()
             return
         }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                shared.semaphore.signal()
                shared.requests.removeValue(forKey: request)
             }
            guard let data = data else {
              print(String(describing: error))
              return
            }
            print(String(data: data, encoding: .utf8)!)
            var apiResponse: Result<T, Error> {
                return Result {
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
                        return result
                    } catch {
                        print(error)
                        throw error
                    }
                }
            }
            DispatchQueue.main.async {
                completion(apiResponse)
            }
        }
        print("Url: \(String(describing: request.url)), qeuery: \(router.queryParameter)")
        task.resume()
        shared.requests[request] = task
        shared.semaphore.wait()
    }
}

extension APIManager {
    static func topHeadlines(country: String, category: String, page: Int, completion: @escaping (Result<NewsAPIResponse, Error>) -> Void) {
        APIManager.DataRequest(router: NewsRouter.topHeadlines(country: country, category: category, page: page), completion: completion)
    }
    
    static func searchNews(query: String, language: String = "", pageSize: Int = 50, page: Int = 1, completion: @escaping (Result<NewsAPIResponse, Error>) -> Void) {
        let searchIn = newsSettingManager.getSearchIn(isForApi: true)
        let searchDate = newsSettingManager.getSearchDate()
        let sortBy = newsSettingManager.getSearchSortBy(isForApi: true)
        APIManager.DataRequest(router: NewsRouter.searchNews(query: query, searchIn: searchIn, from: searchDate.0, to: searchDate.1, language: language, pageSize: pageSize, page: page, sortBy: sortBy), completion: completion)
    }
}

enum NewsRouter: APIClientConfig {
    case searchNews(query: String, searchIn: String, from: String, to: String, language: String, pageSize: Int, page: Int, sortBy: String)
    case topHeadlines(country: String, category: String, page: Int)
    
    var apiKey: String {
        // your NewsAPI key
//        return "cbe29cc43e2544fda19aa684517aadd4"
        return "b6a92da50ecb45fdbe56aaf376cc2f39"
    }
    
    var httpMethod: String {
        switch self {
        default: return "GET"
        }
    }
    
    var schema: String {
        switch self {
        default:
            return "https"
        }
    }
    
    var host: String {
        switch self {
        default:
            return "newsapi.org"
        }
    }
    
    var urlPrefix: String {
        switch self {
        case .searchNews:
            return "/v2/everything"
        case .topHeadlines:
            return "/v2/top-headlines"
        }
    }
    
    var path: String {
        switch self {
        default:
            return "\(schema)://\(host)\(urlPrefix)"
        }
    }
    
    var queryParameter: [URLQueryItem]? {
        switch self {
        case .searchNews(let query, let searchIn, let from, let to, let language, let pageSize, let page, let sortBy):
            let queryItems = [URLQueryItem(name: QueryKey.q, value: query),
                              URLQueryItem(name: QueryKey.apiKey, value: self.apiKey),
                              URLQueryItem(name: QueryKey.searchIn, value: searchIn),
                              URLQueryItem(name: QueryKey.from, value: from),
                              URLQueryItem(name: QueryKey.to, value: to),
                              URLQueryItem(name: QueryKey.language, value: language),
                              URLQueryItem(name: QueryKey.pageSize, value: "\(pageSize)"),
                              URLQueryItem(name: QueryKey.page, value: "\(page)"),
                              URLQueryItem(name: QueryKey.sortBy, value: sortBy)]
            return queryItems
            
        case .topHeadlines(country: let country, let category, page: let page):
            let queryItems = [URLQueryItem(name: QueryKey.country, value: country),
                              URLQueryItem(name: QueryKey.apiKey, value: self.apiKey),
                              URLQueryItem(name: QueryKey.category, value: category),
                              URLQueryItem(name: QueryKey.page, value: "\(page)")]
            return queryItems
        }
    }
}


struct QueryKey {
    static let q = "q"
    static let apiKey = "apiKey"
    static let searchIn = "searchIn"
    static let from = "from"
    static let to = "to"
    static let language = "language"
    static let pageSize = "pageSize"
    static let page = "page"
    static let sortBy = "sortBy"
    static let country = "country"
    static let category = "category"
}

protocol APIClientConfig {
    var httpMethod: String {get}
    var path: String {get}
    var queryParameter: [URLQueryItem]? {get}
}

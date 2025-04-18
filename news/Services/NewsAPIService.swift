import Foundation

class NewsAPIService {
    static let shared = NewsAPIService()
    private init() {}
    
    private let apiKey = "9e4a7448b2e1474ca95d63228f134874"
    private let baseURL = "https://newsapi.org/v2/everything"
    
    func fetchArticles(query: String, page: Int = 1, pageSize: Int = 20) async throws -> [Article] {
        guard var urlComponents = URLComponents(string: baseURL) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "from", value: oneMonthAgoISO8601()),
            URLQueryItem(name: "sortBy", value: "publishedAt"),
            URLQueryItem(name: "apiKey", value: apiKey),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "pageSize", value: String(pageSize))
        ]
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }

        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              (200..<300).contains(httpResponse.statusCode) else {
            throw URLError(.badServerResponse)
        }
        
        let decoded = try JSONDecoder().decode(NewsResponse.self, from: data)
        return decoded.articles
    }
    
    private func oneMonthAgoISO8601() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let date = Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        return formatter.string(from: date)
    }
}


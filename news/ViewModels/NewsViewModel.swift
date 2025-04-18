import Foundation

@MainActor
class NewsViewModel: ObservableObject {
    @Published var articles: [Article] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var page = 1
    @Published var hasMorePages = true

    private let pageSize = 20
    private var currentQuery = ""

    func searchArticles(reset: Bool = false) async {
        let trimmedQuery = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return }

        if reset {
            page = 1
            hasMorePages = true
            articles = []
            currentQuery = trimmedQuery
        } else if currentQuery != trimmedQuery {
            // New search keyword
            page = 1
            hasMorePages = true
            articles = []
            currentQuery = trimmedQuery
        }

        guard hasMorePages, !isLoading else { return }

        isLoading = true

        do {
            let newArticles = try await NewsAPIService.shared.fetchArticles(query: currentQuery, page: page, pageSize: pageSize)
            articles.append(contentsOf: newArticles)
            hasMorePages = newArticles.count == pageSize
            page += 1
        } catch {
            print("Error fetching articles: \(error)")
        }

        isLoading = false
    }

    func loadMoreArticlesIfNeeded(currentArticle: Article) async {
        guard let lastArticle = articles.last else { return }
        if currentArticle.id == lastArticle.id {
            await searchArticles(reset: false)
        }
    }
}

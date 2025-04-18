import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = NewsViewModel()

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $viewModel.searchText, onSearch: {
                    Task {
                        await viewModel.searchArticles(reset: true)
                    }
                })
                .padding()

                if viewModel.articles.isEmpty && !viewModel.isLoading {
                    Spacer()
                    Text("No articles yet. Try searching something!")
                        .foregroundColor(.gray)
                    Spacer()
                } else {
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.articles) { article in
                                ArticleRowView(article: article)
                                    .onAppear {
                                        Task {
                                            await viewModel.loadMoreArticlesIfNeeded(currentArticle: article)
                                        }
                                    }
                            }

                            if viewModel.isLoading {
                                ProgressView()
                                    .padding()
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
            .navigationTitle("News")
        }
        .onAppear {
            Task {
                await viewModel.searchArticles(reset: true)
            }
        }
    }
}

struct MyPreviewProvider_Previews: PreviewProvider {
    static var previews: some View {
            ContentView()
    }
}

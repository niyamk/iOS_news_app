import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    var onSearch: () -> Void

    var body: some View {
        HStack {
            TextField("Search news...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onSubmit {
                    onSearch()
                }

            Button(action: {
                onSearch()
            }) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
}

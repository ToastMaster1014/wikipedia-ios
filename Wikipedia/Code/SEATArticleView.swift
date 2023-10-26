import SwiftUI
import Components

struct SEATArticleView: UIViewControllerRepresentable {
    
    @ObservedObject private var appEnvironment = WKAppEnvironment.current

    private var theme: WKTheme {
        appEnvironment.theme
    }
    
    typealias UIViewControllerType = ArticleViewController

    let articleURL: URL
    
    func makeUIViewController(context: Context) -> ArticleViewController {
        return ArticleViewController(articleURL: articleURL, dataStore: MWKDataStore.shared(), theme: WKTheme.theme(from: theme))!
    }

    func updateUIViewController(_ uiViewController: ArticleViewController, context: Context) {
        uiViewController.apply(theme: WKTheme.theme(from: theme))
    }
}
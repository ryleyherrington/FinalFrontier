import SwiftUI

struct ContentView: View {
    @Namespace private var animation
    @State private var isLoading = false
    
    @State private var currentPage = 0
    @State private var isScrolling = false
    @State private var scrollOffset: CGFloat = 0
    @State private var previousScrollOffset: CGFloat = 0
    @State private var scrollVelocity: CGFloat = 0
    @State private var scrollingTimer: Timer?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.black
                HyperspaceBackground(currentPage: $currentPage, isScrolling: $isScrolling)
                    .edgesIgnoringSafeArea(.all)
                
                    TabView(selection: $currentPage) {
                        ForEach(0...10, id: \.self) { index in
                            VStack(alignment: .leading) {
                                Group {
                                    Text("Card \(index)")
                                        .font(.title)
                                        .foregroundStyle(.white)
                                        .padding(.bottom, 5)
                                    Text("Sub info")
                                        .font(.body)
                                        .foregroundStyle(.white)
                                    Text("Cool stuff")
                                        .font(.body)
                                        .foregroundStyle(.white)
                                }
                                .padding(5)
                            }
                            .background(.ultraThinMaterial)
                            .cornerRadius(10)
                            .tag(index)
                            .padding(.horizontal)
                            .overlay(
                                GeometryReader { proxy in
                                    Color.clear.preference(key: ScrollOffsetPreferenceKey.self, value: proxy.frame(in: .named("scroll")).minX)
                                }
                            )
                        }
                    }
                    .animation(.easeInOut, value: currentPage)
                    .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
        .coordinateSpace(name: "scroll")
        .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
            //            let oldScrollOffset = scrollOffset
            scrollOffset = value
            
            // Calculate scroll velocity
            scrollVelocity = scrollOffset - previousScrollOffset
            previousScrollOffset = scrollOffset
            
            // Determine if scrolling based on velocity
            if abs(scrollVelocity) > 10.0 {
                isScrolling = true
                resetScrollingTimer()
            }
            
            // Update current page
            if scrollOffset == 0 {
                isScrolling = false
            }
        }
    }
    
    private func resetScrollingTimer() {
        scrollingTimer?.invalidate()
        scrollingTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false) { _ in
            isScrolling = false
        }
    }
}

#Preview {
    ContentView()
}

struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

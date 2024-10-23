import SwiftUI

struct HyperspaceStar: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var length: CGFloat
    var speed: Double
}

struct StationaryStar: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
}

struct HyperspaceBackground: View {
    let numberOfStars = 100
    @Binding var currentPage: Int
    @Binding var isScrolling: Bool
    
    @State private var stars: [HyperspaceStar] = []
    
    var body: some View {
        ZStack {
            SpaceBackground(pageIndex: currentPage, isScrolling: $isScrolling)
                .edgesIgnoringSafeArea(.all)
            
            if isScrolling {
                TimelineView(.animation) { timeline in
                    Canvas { context, size in
                        let timelineDate = timeline.date.timeIntervalSinceReferenceDate
                        
                        for star in stars {
                            var path = Path()
                            let xOffset = star.speed * timelineDate.truncatingRemainder(dividingBy: 1)
                            let startX = (star.x * size.width - xOffset).truncatingRemainder(dividingBy: size.width)
                            path.move(to: CGPoint(x: startX, y: star.y * size.height))
                            path.addLine(to: CGPoint(x: startX + star.length, y: star.y * size.height))
                            
                            context.stroke(path, with: .color(.white), lineWidth: 2)
                        }
                    }
                }
                .transition(.slide.combined(with: .opacity))
            }
        }
        .onAppear {
            stars = (0..<numberOfStars).map { _ in
                HyperspaceStar(
                    x: CGFloat.random(in: 0...1),
                    y: CGFloat.random(in: 0...1),
                    length: CGFloat.random(in: 20...100),
                    speed: Double.random(in: 200...600)
                )
            }
        }
    }
}

import SwiftUI

struct Star: Identifiable {
    let id = UUID()
    let shape: AnyShape
    var starX: CGFloat
    var starY: CGFloat
    var size: CGFloat
    var speed: CGFloat
    var direction: CGFloat
}

struct SpaceBackground: View {
    let numberOfStars = 200
    let pageIndex: Int
    @Binding var isScrolling: Bool
    @State var showStars: Bool = false
    @State var colors: [Color] = [
        .black, .purple.mix(with: .black, by: 0.5), .indigo.mix(with: .black, by: 0.8),
        .black, .blue.mix(with: .black, by: 0.5), .black,
        .indigo.mix(with: .black, by: 0.5), .green.mix(with: .black, by: 0.7), .green.mix(with: .black, by: 0.8)
    ]
    @State private var stars: [Star] = []

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                MeshGradientView(colors: $colors)
                    .onChange(of: pageIndex) { oldValue, newValue in
                        colors = colors.shuffled()
                    }
                    .onChange(of: isScrolling) { oldValue, newValue in
                        withAnimation {
                            showStars = newValue
                        }
                    }

                if !showStars {
                    ForEach(stars) { star in
                        star.shape
                            .fill(Color.white)
                            .frame(width: star.size, height: star.size)
                            .position(x: star.starX, y: star.starY)
                            .transition(.opacity)
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    stars = createStars(for: geometry.size)
                    startStarAnimation(geometry.size)
                    print("SIZE \(geometry.size)")
                }
            }
        }
        .animation(.easeInOut, value: pageIndex)
    }
    
    private func moveStar(_ x: CGFloat, _ y: CGFloat, _ velocity: CGFloat, _ direction: CGFloat ) -> (x: CGFloat, y: CGFloat) {
        let newX = x + cos(direction) * velocity
        let newY = y + sin(direction) * velocity
        return (newX, newY)
    }

    private func createStars(for size: CGSize) -> [Star] {
        let halfWidth = size.width / 2
        let halfHeight = size.height / 2
        return (0..<numberOfStars).map { _ in
            let starSize = CGFloat.random(in: 1...5)
            let speed = starSize / 5
            
            let xOffset = CGFloat.random(in: -halfWidth...halfWidth)
            let yOffset = CGFloat.random(in: -halfHeight...halfHeight)
            let direction = atan2(yOffset, xOffset)
            
            return Star(
                shape: Bool.random() ? AnyShape(Rhombus()) : AnyShape(Circle()),
                starX: xOffset + halfWidth,
                starY: yOffset + halfHeight,
                size: starSize,
                speed: speed,
                direction: direction
            )
        }
    }

    private func startStarAnimation(_ size: CGSize) {
        let centerX = size.width / 2  // Correct center X
        let centerY = size.height / 2 // Correct center Y
        
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            for index in stars.indices {
                let star = stars[index]
                
                let (newX, newY) = moveStar(star.starX, star.starY, star.speed, star.direction)
                stars[index].starX = newX
                stars[index].starY = newY

                // If star goes off-screen, reset it at the center
                if stars[index].starX < 0 || stars[index].starX > size.width || stars[index].starY < 0 || stars[index].starY > size.height {
                    stars[index].starX = centerX
                    stars[index].starY = centerY
                }
            }
        }
    }
}

struct AnyShape: Shape {
    private let pathFunction: (CGRect) -> Path

    init<S: Shape>(_ wrapped: S) {
        pathFunction = { rect in
            wrapped.path(in: rect)
        }
    }

    func path(in rect: CGRect) -> Path {
        pathFunction(rect)
    }
}

struct Rhombus: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        path.move(to: CGPoint(x: width / 2, y: 0))
        path.addLine(to: CGPoint(x: width, y: height / 2))
        path.addLine(to: CGPoint(x: width / 2, y: height))
        path.addLine(to: CGPoint(x: 0, y: height / 2))
        path.closeSubpath()
        
        return path
    }
}

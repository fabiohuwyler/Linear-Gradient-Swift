import SwiftUI
import simd

struct DemoMeshGradientBackground: View {
    @EnvironmentObject private var themeManager: ThemeManager
    @State private var phase: Double = 0
    private let timer = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    @State private var animationAmount = 0.0
    
    var body: some View {
        let points: [SIMD2<Float>] = [
            SIMD2(0.0, 0.0),
            SIMD2(0.5 + Float(0.15 * sin(phase)), 0.0),
            SIMD2(1.0, 0.0),
            SIMD2(0.0, 0.5),
            SIMD2(0.8 + Float(0.15 * cos(phase)), 0.5 + Float(0.15 * sin(phase))),
            SIMD2(1.0, 0.5),
            SIMD2(0.0, 1.0),
            SIMD2(0.5 + Float(0.15 * sin(phase + .pi)), 1.0),
            SIMD2(1.0, 1.0)
        ]
        
        MeshGradient(
            width: 3,
            height: 3,
            points: points,
            colors: themeColors
        )
        .ignoresSafeArea()
        .onReceive(timer) { _ in
            withAnimation(.linear(duration: 0.05)) {
                phase += 0.02
                if phase > 2 * .pi {
                    phase = 0
                }
            }
        }
    }
    
    private var themeColors: [Color] {
        let colors = themeManager.selectedTheme.colors
        return [
            colors[2], colors[0], colors[0],
            colors[1], colors[2], colors[1],
            colors[2], colors[3], colors[3]
        ]
    }
}

#Preview {
    DemoMeshGradientBackground()
        .environmentObject(ThemeManager())
}

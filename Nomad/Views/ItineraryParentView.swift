import SwiftUI

struct ItineraryParentView: View {
    @State private var showAtlas = false
    @State private var showWipeOverlay = false
    @ObservedObject var vm: UserViewModel
    @ObservedObject var cvm: ChatViewModel
    

    var body: some View {
        ZStack {
            // Background views that will transition
            if showAtlas {
                AIAssistantView(vm: vm, chatViewModel: cvm)
                    .transition(.identity) // No animation on the content itself
            } else {
                FindStopView(vm: vm)
                    .transition(.identity) // No animation on the content itself
            }
            
            // Overlay that wipes in and out
            if showWipeOverlay {
                Color.blue
                    .edgesIgnoringSafeArea(.all)
                    .transition(.wipe)
                    .zIndex(1) // Ensure the blue overlay is on top
                
                Image(systemName: "pencil.circle") // Replace "YourLogo" with the name of your logo asset
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100) // Adjust size as needed
                .foregroundColor(.white) // Set logo color if it’s a template
                .opacity(showWipeOverlay ? 1 : 0) // Fade in and out
                .animation(.easeInOut(duration: 0.5), value: showWipeOverlay)
                .zIndex(2)// Fade animation for the logo
            }

            // Floating button
            VStack {
                if showAtlas {
                    // Positioning the button at the top right
                    HStack {
                        Spacer()
                        Button(action: {
                            // Trigger the wipe overlay and then toggle the view after the delay
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showWipeOverlay = true
                            }
                            
                            
                            // Delay the screen transition
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showAtlas.toggle()
                                    showWipeOverlay = false
                                }
                            }
                        }) {
                            Text("Return")
                                .font(.subheadline)
                                .foregroundColor(.white)
                                .padding(10)
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                    Spacer()
                    
                } else {
                    // Positioning the button at the bottom right
                    Spacer() // Push the button to the bottom
                    HStack {
                        Spacer()
                        Button(action: {
                            // Trigger the wipe overlay and then toggle the view after the delay
                            withAnimation(.easeInOut(duration: 0.5)) {
                                showWipeOverlay = true
                            }
                            // Delay the screen transition
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                withAnimation(.easeInOut(duration: 0.5)) {
                                    showAtlas.toggle()
                                    showWipeOverlay = false
                                }
                            }
                        }) {
                            Text("Consult Atlas")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(10)
                        }
                        .padding()
                    }
                }
            }
        }
        .animation(.easeInOut, value: showAtlas) // Apply animation to the view transition
    }
}

// Custom wipe transition
extension AnyTransition {
    static var wipe: AnyTransition {
        AnyTransition.modifier(
            active: WipeModifier(percent: 0),
            identity: WipeModifier(percent: 1)
        )
    }
}

// Modifier for the wipe effect
struct WipeModifier: ViewModifier {
    var percent: CGFloat

    func body(content: Content) -> some View {
        content
            .clipShape(WipeShape(percent: percent))
    }
}

// Shape that animates from left to right
struct WipeShape: Shape {
    var percent: CGFloat

    var animatableData: CGFloat {
        get { percent }
        set { percent = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.width * percent
        path.addRect(CGRect(x: 0, y: 0, width: width, height: rect.height))
        return path
    }
}

#Preview {
    ItineraryParentView(vm: UserViewModel(), cvm: ChatViewModel())
}

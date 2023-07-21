//
//  ContentView.swift
//  NavigationProfileAnimation
//
//  Created by Andrew Kurdin on 21.07.2023.
//

import SwiftUI

struct ContentView: View {
  // View properties
  @State private var selectedProfile: Profile?
  @State private var pushView: Bool = false
  @State private var hideView: (Bool, Bool) = (false, false)
  /*
   So what are these tuples used for? It plays a major role in the Custom Matched Geometry Effect. The first tuple value indicates whether the animation is completely finished, so why do we need to know this? Because once the animation is complete, we can remove the overlay view (Which we used to animate) and show the original Destination View. The second tuple value is used to animate contents like the close button and other header views contained inside the destination view
   Итак, для чего используются эти кортежи? Он играет важную роль в эффекте Custom Matched Geometry Effect. Первое значение кортежа указывает, полностью ли завершена анимация, так зачем нам это знать? Потому что, как только анимация завершена, мы можем удалить наложенный вид (который мы использовали для анимации) и показать исходный вид назначения. Второе значение кортежа используется для анимации содержимого, такого как кнопка закрытия и другие виды заголовков, содержащиеся в целевом представлении.
   */
  
  var body: some View {
    NavigationStack {
      HomeView(selectedProfile: $selectedProfile, pushView: $pushView)
        .navigationTitle("Profile")
        .navigationDestination(isPresented: $pushView) {
          DetailView(selectedProfile: $selectedProfile, pushView: $pushView, hideView: $hideView)
        }
    }
    .overlayPreferenceValue(MAnchorKey.self) { value in
      GeometryReader { geometry in
        if let selectedProfile, let anchor = value[selectedProfile.id], !hideView.0 { // , !hideView.0 add for BackBtn
          let rect = geometry[anchor]
          ImageView(profile: selectedProfile, size: rect.size)
            .offset(x: rect.minX, y: rect.minY)
          // Simply Animation the rect will add the geometry effect we needed
            //.animation(.snappy(duration: 0.35, extraBounce: 0), value: rect)
            .animation(.easeIn(duration: 0.35), value: rect)
        }
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView()
  }
}

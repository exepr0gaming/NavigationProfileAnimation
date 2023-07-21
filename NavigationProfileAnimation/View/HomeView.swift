//
//  HomeView.swift
//  NavigationProfileAnimation
//
//  Created by Andrew Kurdin on 21.07.2023.
//

import SwiftUI

/*
 Actually, how we're going to build the custom matched geometry effect is with the
 help of the anchor preference API in SwiftUI. In simple terms, first we will know the
 source view anchor frame, and when the detail view is pushed, we will add an overlay to
 the NavigationStack that will start from the source view and move to the destination
 view with the destination view anchor frame. Thus looking like a hero effect.
 
 На самом деле, как мы собираемся создать настраиваемый эффект совпадающей геометрии, так это с помощью
 помощь API предпочтения привязки в SwiftUI. Проще говоря, сначала мы узнаем
 кадр привязки исходного вида, и когда детальный вид будет нажат, мы добавим наложение к
 NavigationStack, который будет начинаться с исходного представления и перемещаться к месту назначения
 вид с целевым фреймом привязки вида. Таким образом, похоже на эффект героя.
 */
struct HomeView: View {
  // View properties
  @Binding var selectedProfile: Profile?
  @Binding var pushView: Bool
  
  var body: some View {
    List {
      ForEach (profiles) { profile in
        Button {
          selectedProfile = profile
          pushView.toggle()
        } label: {
          HStack(spacing: 15) {
            Color.clear
              .frame(width: 60, height: 60)
            // READ ME
              .anchorPreference(key: MAnchorKey.self, value: .bounds) { anchor in
                return [profile.id: anchor]
              }
            
            VStack(alignment: .leading, spacing: 2, content: {
              Text(profile.userName)
                .fontWeight(.semibold)
              Text(profile.lastMsg)
                .font(.callout)
              //.textScale(.secondary)
                .foregroundStyle(.gray)
            })
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(profile.lastActive)
              .font(.caption)
              .foregroundStyle(.gray)
          }
          .contentShape(Rectangle())
        }
        
      }
    }
    .overlayPreferenceValue(MAnchorKey.self) { value in
      GeometryReader { geometry in
        ForEach(profiles) { profile in
          // Fetching Each Profile Image View using the Profile ID
          // Hiding the Currently tapped view
          /*
           As you can see, we need to disable the default back action in order to get the matched geometry effect, so we need to implement the custom close button in order to pop the view (which will do later in the video).
           Как видите, нам нужно отключить обратное действие по умолчанию. чтобы получить эффект согласованной геометрии, нам нужно реализовать пользовательскую кнопку закрытия, чтобы открыть представление (что будет делать дальше в видео).
           */
          if let anchor = value[profile.id], selectedProfile?.id != profile.id {
            let rect = geometry[anchor]
            ImageView(profile: profile, size: rect.size)
              .offset(x: rect.minX, y: rect.minY)
              .allowsHitTesting(false) // NEEDED TODO
          }
        }
      }
    }
    /*
     As you can see here, I've fetched the source view anchor frame and
     added all the views as an overlay to the List view. Thus making no
     difference as it looks like it's inside the list view. You can skip this way
     and directly put the view inside the list view, but I picked this method.
     Как вы можете видеть здесь, я извлек рамку привязки исходного кода и
     добавил все представления в качестве наложения на представление списка. Тем самым не делая
     разница, как это выглядит внутри представления списка. Вы можете пропустить этот путь
     и напрямую поместить представление в представление списка, но я выбрал этот метод.
     */
  }
}

struct DetailView: View {
  @Binding var selectedProfile: Profile?
  @Binding var pushView: Bool
  @Binding var hideView: (Bool, Bool)
  
  var body: some View {
    if let selectedProfile {
      VStack {
        GeometryReader { proxy in
          let size = proxy.size
          //ImageView(profile: profile, size: size)
          
          VStack {
            if hideView.0 {
              ImageView(profile: selectedProfile, size: size)
              // Custom close button
                .overlay(alignment: .top) {
                  ZStack {
                    Button {
                      //Closing the View with animation
                      hideView.0 = false
                      hideView.1 = false
                      pushView = false
                      //  Average Navigation Pop takes 0.35s that's the reason i set the animation duration as 0.35s, after the view is popped out, making selectedProfile to nil
                      
                      DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                        self.selectedProfile = nil
                      }
                    } label: {
                      Image(systemName: "xmark")
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.black, in: Circle())
                        .contentShape(Circle())
                    }
                    .padding(15)
                    .padding(.top, 40)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                    
                    Text(selectedProfile.userName)
                      .font(.title.bold())
                      .foregroundStyle(.black)
                      .padding(15)
                      .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomLeading)
                  }
                  .opacity(hideView.1 ? 1 : 0)
                  .animation(.easeOut, value: hideView.1)//.animation(.snappy, value: hideView.1)
                }
                .onAppear {
                  DispatchQueue.main.asyncAfter(deadline: .now()) {
                    hideView.1 = true
                  }
                }
            } else {
              Color.clear
            }
          }
          // Destination View Anchor
          .anchorPreference(key: MAnchorKey.self, value: .bounds) { anchor in
            return [selectedProfile.id: anchor]
          }
        }
        .frame(height: 400)
        .ignoresSafeArea()
        
        Spacer(minLength: 0)
      }
      .toolbar(hideView.0 ? .hidden: .visible, for: .navigationBar)
      .onAppear {
        // Removing the animated view one the animation is Finished
        /*
         As you noticed, since I've used an animation duration of 0.35s and it's a spring-based animation, it may take some more time to finish than its actual timing, so use the appropriate value as per your animation duration. And to mention, the reason I used 0.35s is that the navigation view takes around 0.35s to -popup, so it will be more natural if we use the same amount for the hero animation too.
         Как вы заметили, поскольку я использовал продолжительность анимации 0,35 с, и это анимация на основе пружины, для ее завершения может потребоваться больше времени, чем ее фактическое время, поэтому используйте соответствующее значение в соответствии с продолжительностью вашей анимации. И, кстати, причина, по которой я использовал 0,35 с, заключается в том, что представление навигации занимает около 0,35 с для всплывающего окна, поэтому будет более естественно, если мы используем такое же время для анимации героя.
         */
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
          hideView.0 = true
        }
      }
    }
  }
  /*
   As I said earlier, when the detail view is pushed, we will read the destination
   view anchor frame and animate from the source view to the destination view,
   thus giving the same id for both source view and destination view, which will
   result in a single view but with differing size aspects. By simply animating the
   size and position, we will get the exact hero animation effect we needed.
   
   Как я уже говорил ранее, при нажатии на подробное представление мы будем читать пункт назначения.
   просмотреть кадр привязки и анимировать от исходного вида к целевому виду,
   таким образом давая один и тот же идентификатор как для исходного представления, так и для целевого представления, что будет
   приводит к одному виду, но с разными аспектами размера. Просто анимируя
   размер и положение, мы получим именно тот эффект анимации героя, который нам нужен.
   */
}

struct ImageView: View {
  var profile: Profile
  var size: CGSize
  
  var body: some View {
    Image (profile.profilePicture)
      .resizable()
      .aspectRatio (contentMode: .fill)
      .frame (width: size.width, height: size.height)
    //Linear gradient at bottom
      .overlay(content: {
        LinearGradient(colors: [.clear, .clear, .clear, .white.opacity(0.1), .white.opacity(0.5), .white.opacity(0.9), .white], startPoint: .top, endPoint: .bottom)
          .opacity(size.width > 60 ? 1 : 0)
      })
      .clipShape(RoundedRectangle(cornerRadius: size.width > 60 ? 0 : 30))
    //.clipShape(.rect(cornerRadius: size.width > 60 ? 0 : 30))
    /*
     As we know, the source view height and width are 60, so with the help
     of this, we can make the image view circle or rectangle based on the
     view we are in, i.e., If we're in sour6ce view, then it will be a circle shape.
     If we're in destination view, then it will be a rectangle shape.
     Как мы знаем, высота и ширина исходного вида равны 60, поэтому с помощью
     из этого мы можем сделать круг или прямоугольник просмотра изображения на основе
     представление, в котором мы находимся, т. е. если мы находимся в исходном представлении, то оно будет иметь форму круга.
     Если мы находимся в представлении назначения, то это будет прямоугольная форма.
     */
  }
}

struct HomeView_Previews: PreviewProvider {
  static var previews: some View {
    //HomeView(selectedProfile: .constant(profiles[0]), pushView: .constant(false))
    ContentView()
  }
}

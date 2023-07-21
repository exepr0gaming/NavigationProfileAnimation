//
//  Profile.swift
//  NavigationProfileAnimation
//
//  Created by Andrew Kurdin on 21.07.2023.
//

import SwiftUI

struct Profile: Identifiable {
  var id = UUID().uuidString
  var userName: String
  var profilePicture: String
  var lastMsg: String
  var lastActive: String
}

var profiles = [
  Profile(userName: "iJustine", profilePicture: "profile", lastMsg: "Hi Kavsoft !!!", lastActive: "10:25 PM"),
  Profile(userName: "Jenna Ezarik", profilePicture: "profile", lastMsg: "Nothing!", lastActive: "06:25 AM"),
  Profile(userName: "Emily", profilePicture: "profile", lastMsg: "Binge Watching...", lastActive: "10:25 PM"),
  Profile(userName: "Julie", profilePicture: "profile", lastMsg: "404 Page not Found!", lastActive: "10:25 PM"),
  Profile(userName: "Kaviya", profilePicture: "profile", lastMsg: "Do not Disturb.", lastActive: "10:25 PM"),
]

//
//  AppWrapper.swift
//  iosApp
//
//  Created by Plentina on 12/31/22.
//  Copyright © 2022 orgName. All rights reserved.
//

import Foundation
import UIKit

@main
struct AppWrapper {
  static func main() {
    if #available(iOS 14.0, *) {
      iOSApp.main()
    }
    else {
      UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, NSStringFromClass(SceneDelegate.self))
    }
  }
}

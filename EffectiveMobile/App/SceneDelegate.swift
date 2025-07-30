//
//  SceneDelegate.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

	var window: UIWindow?

	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

		guard let scene = (scene as? UIWindowScene) else { return }

		let todoListRouter = TodoListRouter.start()
		guard let viewController = todoListRouter.entry else { return }
		let window = UIWindow(windowScene: scene)
		window.rootViewController = UINavigationController(rootViewController: viewController)
		self.window = window
		self.window?.makeKeyAndVisible()
	}

	func sceneDidDisconnect(_ scene: UIScene) {
	}

	func sceneDidBecomeActive(_ scene: UIScene) {
	}

	func sceneWillResignActive(_ scene: UIScene) {
	}

	func sceneWillEnterForeground(_ scene: UIScene) {
	}

	func sceneDidEnterBackground(_ scene: UIScene) {
	}

}

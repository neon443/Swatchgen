//
//  SwatchgenApp.swift
//  Swatchgen
//
//  Created by Nihaal Sharma on 03/12/2024.
//

import SwiftUI

@main
struct SwatchgenApp: App {
	@State private var savedPalettes: [[Color]] = []
	@State private var showOpacity: Bool = false

	var body: some Scene {
		WindowGroup {
			ContentView()
		}
	}
}

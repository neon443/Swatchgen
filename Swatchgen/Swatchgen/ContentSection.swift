//
//  ContentSection.swift
//  Swatchgen
//
//  Created by Nihaal Sharma on 06/12/2024.
//

import SwiftUI

struct ContentSection: View {
	@Binding var colors: [Color]
	@Binding var showOpacity: Bool
	
	var body: some View {
		Group {
			if colors.isEmpty {
				InstructionsView()
			} else {
				GeneratedColorPaletteView(
					colors: $colors,
					showOpacity: $showOpacity
				)
			}
		}
	}
}

struct ContentSection_Previews: PreviewProvider {
	@State static private var colors: [Color] = [Color.red]
	@State static private var showOpacity: Bool = false

	static var previews: some View {
		ContentSection(colors: $colors, showOpacity: $showOpacity)
	}
}

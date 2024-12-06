//
//  ContentView.swift
//  Swatchgen
//
//  Created by Nihaal Sharma on 03/12/2024.
//

import SwiftUI

struct ContentView: View {
	@State private var colors: [Color] = []
	@State private var colorCount = 5.0
	@State private var showOpacity = false
	@State private var savedPalettes: [[Color]] = []
	@State private var showMax = false
	@State private var isGenerating = false
	
	var body: some View {
		NavigationView {
			VStack {
				ContentSection(
					colors: $colors,
					showOpacity: $showOpacity
				)
				
				ColorCountSliderView(
					colorCount: $colorCount,
					showMax: showMax
				)
				
				ToggleSection(
					showMax: $showMax,
					showOpacity: $showOpacity
				)
				
				ActionButtonsView(
					colors: $colors,
					savedPalettes: $savedPalettes,
					showOpacity: $showOpacity,
					isGenerating: $isGenerating,
					colorCount: colorCount
				)
			}
			.navigationTitle("Swatchgen")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .topBarLeading) { ClearButton(colors: $colors) }
				ToolbarItem(placement: .topBarTrailing) { ColorCountText(colors: colors) }
				ToolbarItem(placement: .bottomBar) {
					NavigationLink(
						destination: SavedPalettesView(
							savedPalettes: $savedPalettes,
							showOpacity: $showOpacity
						)
					) {
						Image(systemName: "paintpalette")
					}
				}
			}
		}
	}
}

struct GeneratedColorPaletteView: View {
	@Binding var colors: [Color]
	@Binding var showOpacity: Bool
	
	var body: some View {
		// Display the color palette
		ScrollView(.vertical) {
			VStack(spacing: 0) {
				ForEach(colors, id: \.self) { color in
					ZStack {
						if showOpacity {
							Rectangle()
								.fill(color)
								.frame(height: 50) // Full width of the parent
								.frame(maxWidth: .infinity)
						} else {
							Rectangle()
								.fill(color.opacity(100)) // Max out opacity
								.frame(height: 50) // Full width of the parent
								.frame(maxWidth: .infinity)
						}
						Text(color.description.dropLast(showOpacity ? 0 : 2))
							.shadow(color: .black, radius: 5)
					}
				}
				.frame(height: 50) // Set consistent height
			}
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
		.padding(.horizontal)
	}
}

struct SavedPalettesView: View {
	@Binding var savedPalettes: [[Color]]
	@Binding var showOpacity: Bool
	var body: some View {
		ForEach(savedPalettes.indices, id: \.self) { index in
			HStack(spacing: 0) {
				ForEach(savedPalettes[index], id: \.self) { color in
					if showOpacity {
						Rectangle()
							.fill(color)
							.frame(height: 50)
					} else {
						Rectangle()
							.fill(color.opacity(100)) // Max out opacity
							.frame(height: 50)
					}
				}
			}
			.frame(maxWidth: .infinity)
			.clipShape(RoundedRectangle(cornerRadius: 10))
		}
	}
}

struct InstructionsView: View {
	var body: some View {
		List {
			Section("How to use") {
				Text("1. Select a number of colours.")
				Text("2. Choose if you would like to view opacity.")
				Text("3. Tap Generate!")
			}
			Section("Save for later") {
				Text("Use Save Palette to keep a record of palettes.")
				Text("To view these, tap View Saved Palettes.")
			}
		}
	}
}

struct ColorCountText: View {
	var colors: [Color]
	
	var body: some View {
		Group {
			if !colors.isEmpty {
				Text("\(colors.count)")
					.font(.headline)
			}
		}
	}
}

struct ColorCountSliderView: View {
	@Binding var colorCount: Double
	var showMax: Bool
	
	var body: some View {
		HStack {
			Text(String(Int(colorCount)))
				.fontWeight(.heavy)
			Slider(
				value: $colorCount.animation(),
				in: 1...(showMax ? 10000 : 200),
				step: 1
			) {
				Text("Color Count")
			}
		}
		.padding(.horizontal)
	}
}

struct ToggleSection: View {
	@Binding var showMax: Bool
	@Binding var showOpacity: Bool
	
	var body: some View {
		HStack {
			Toggle(isOn: $showMax) { Text("max") }
			Toggle(isOn: $showOpacity) { Text("Show Opacity") }
		}
		.padding(.bottom)
		.padding(.horizontal)
	}
}

struct ActionButtonsView: View {
	@Binding var colors: [Color]
	@Binding var savedPalettes: [[Color]]
	@Binding var showOpacity: Bool
	@Binding var isGenerating: Bool
	var colorCount: Double
	
	var body: some View {
		VStack {
			HStack {
				SaveAndViewPaletteButtons(
					colors: $colors,
					savedPalettes: $savedPalettes,
					showOpacity: $showOpacity
				)
			}
			.frame(height: 50)
			
			HStack {
				GenerateButton(
					colors: $colors,
					isGenerating: $isGenerating,
					colorCount: colorCount
				)
			}
			.frame(maxHeight: 50)
			.padding(.horizontal)
			.padding(.bottom)
		}
	}
}

struct SaveAndViewPaletteButtons: View {
	@Binding var colors: [Color]
	@Binding var savedPalettes: [[Color]]
	@Binding var showOpacity: Bool
	
	var body: some View {
		Group {
			Button(action: savePalette) {
				Text("Save Palette")
					.foregroundColor(.white)
					.padding()
					.background(colors.isEmpty ? Color.gray : Color.blue)
					.cornerRadius(8)
			}
			.padding(.leading)
			
			NavigationLink(
				destination: SavedPalettesView(
					savedPalettes: $savedPalettes,
					showOpacity: $showOpacity
				)
			) {
				Text("View Saved")
					.foregroundColor(.white)
					.padding()
					.background(.indigo)
					.cornerRadius(8)
			}
			.padding(.trailing)
		}
	}
	
	private func savePalette() {
		guard !colors.isEmpty else { return }
		savedPalettes.append(colors)
	}
}

struct GenerateButton: View {
	@Binding var colors: [Color]
	@Binding var isGenerating: Bool
	var colorCount: Double
	
	var body: some View {
		Button(action: generatePalette) {
			if !isGenerating {
				Text("Generate New Palette")
					.buttonStyle(.orange)
			} else {
				Gauge(
					value: Double(colors.count)/colorCount,
					in: 0...1
				) { Text("Progress...") }
				.generateProgressStyle()
			}
		}
		.disabled(isGenerating)
	}
	
	private func generatePalette() {
		isGenerating = true
		Task {
			let newColors = await generateColors(count: Int(colorCount))
			DispatchQueue.main.async {
				colors = newColors  // Update the colors state directly
			}
			isGenerating = false
		}
	}

}

struct ClearButton: View {
	@Binding var colors: [Color]
	
	var body: some View {
		Button {
			colors = []
		} label: {
			Image(systemName: "trash")
		}
	}
}

extension View {
	func buttonStyle(_ color: Color) -> some View {
		self
			.font(.headline)
			.frame(maxWidth: .infinity, maxHeight: .infinity)
			.background(color.opacity(0.75))
			.foregroundColor(.white)
			.cornerRadius(10)
	}
	
	func generateProgressStyle() -> some View {
		self
			.frame(maxWidth: .infinity)
			.foregroundStyle(Color.green.opacity(0.75))
			.background(Color.green.opacity(0.25))
			.clipShape(RoundedRectangle(cornerRadius: 10))
			.animation(.spring, value: true)
	}
}

func generateColor() async -> Color {
	let red = Double.random(in: 0...1)
	let green = Double.random(in: 0...1)
	let blue = Double.random(in: 0...1)
	let opa = Double.random(in: 0...1)
	return Color(red: red, green: green, blue: blue, opacity: opa)
}

func generateColors(count: Int) async -> [Color] {
	var result: [Color] = []
	for _ in 0..<count {
		let red = Double.random(in: 0...1)
		let green = Double.random(in: 0...1)
		let blue = Double.random(in: 0...1)
		let opa = Double.random(in: 0...1)
		result.append(Color (red: red, green: green, blue: blue, opacity: opa))
	}
	return result
}

#Preview {
	ContentView()
}

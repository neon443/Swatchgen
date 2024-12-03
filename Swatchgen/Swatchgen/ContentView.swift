//
//  ContentView.swift
//  Swatchgen
//
//  Created by Nihaal Sharma on 03/12/2024.
//

import SwiftUI

struct ContentView: View {
	@State private var colorsRGB: [String] = []
	@State private var colors: [Color] = []
	@State private var colorCount: Double = 5 // Default number of colors
	@State private var showOpacity = false
	@State private var savedPalettes: [[Color]] = []
	
	var body: some View {
		NavigationView {
			VStack {
				if colors.isEmpty {
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
				} else {
				// Display the color palette
					ScrollView(.vertical) {
						VStack(spacing: 0) {
							ForEach(colors, id: \.self) { color in
								GeometryReader { geometry in
									ZStack {
										if showOpacity {
											Rectangle()
												.fill(color)
												.frame(width: geometry.size.width, height: 50) // Full width of the parent
										} else {
											Rectangle()
												.fill(color.opacity(100)) // Max out opacity
												.frame(width: geometry.size.width, height: 50) // Full width of the parent
										}
										Text(color.description.dropLast(showOpacity ? 0 : 2))
											.shadow(color: .black, radius: 5)
									}
								}
								.frame(height: 50) // Set consistent height
							}
						}
						.clipShape(RoundedRectangle(cornerRadius: 10))
					}
					.padding()
				}
				
				// Slider to select color count
				Text("Number of Colors: \(Int(colorCount))")
					.font(.headline)
					.frame(alignment: .leading)
				
				Slider(value: $colorCount.animation(), in: 1...20, step: 1) {
					Text("Color Count")
				}
				.padding(.horizontal)
				.padding(.bottom)
				
				Toggle(isOn: $showOpacity) {
					Text("Show Opacity")
				}
				.padding(.horizontal)
				.padding(.bottom)
				
				HStack {
					// Save Palette button
					Button(action: {
						if !colors.isEmpty {
							savedPalettes.append(colors)
						}
					}) {
						Text("Save Palette")
							.font(.headline)
							.padding()
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.background(colors.isEmpty ? Color.gray : Color.blue.opacity(0.75))
							.background(savedPalettes.contains(colors) ? Color.gray : Color.blue.opacity(0.75))
							.foregroundColor(.white)
							.cornerRadius(10)
							.padding(.leading)
					}
					// Navigation to Saved Palettes
					NavigationLink(destination: SavedPalettesView(savedPalettes: $savedPalettes, showOpacity: $showOpacity)) {
						Text("View Saved Palettes")
							.font(.headline)
							.padding()
							.frame(maxWidth: .infinity, maxHeight: .infinity)
							.background(Color.indigo.opacity(0.75))
							.foregroundColor(.white)
							.cornerRadius(10)
							.padding(.trailing)
					}
				}
				.frame(height: 50)
				.padding(.bottom)
				
				// Generate button
				Button(action: {
					colorsRGB = generateRGB(count: Int(colorCount))
					colors = RGBtoColor(rgb: colorsRGB)
				}) {
					Text("Generate New Palette")
						.font(.headline)
						.padding()
						.frame(maxWidth: .infinity)
						.background(Color.orange.opacity(0.75))
						.foregroundColor(.white)
						.cornerRadius(10)
						.padding(.horizontal)
						.padding(.bottom)
				}
			}
			.navigationTitle("Swatchgen")
		}
	}
}

struct SavedPalettesView: View {
	@Binding var savedPalettes: [[Color]]
	@Binding var showOpacity: Bool
	
	var body: some View {
		Toggle(isOn: $showOpacity) {
			Text("Show Opacity")
		}
		.padding(.top)
		.padding(.horizontal)
		
		VStack {
			if savedPalettes.isEmpty {
				Text("No saved palettes yet!")
					.foregroundColor(.gray)
					.padding()
			} else {
				List {
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
					.onDelete(perform: deletePalette)
					.frame(maxWidth: .infinity)
				}
			}
		}
		.frame(maxHeight: .infinity)
		.navigationTitle("Saved Palettes")
		.toolbar {
			EditButton() // Adds an Edit button for enabling swipe-to-delete
		}
	}
	
	private func deletePalette(at offsets: IndexSet) {
		savedPalettes.remove(atOffsets: offsets)
	}
}

struct colorDetailView: View {
	var body: some View {
		Text("text")
	}
}

func generateRGB(count: Int) -> [String] {
	var result: [String] = []
	for _ in 0..<count {
		var append = ""
		for _ in 0...3 {
			append.append(String(Double.random(in: 0...1)) + ":")
		}
		result.append(append + ";")
	}
	return result
}
func RGBtoColor(rgb: [String]) -> [Color] {
	var result: [Color] = []
	for rgbval in rgb {
		let components = rgbval.trimmingCharacters(in: .punctuationCharacters).split(separator: ":")
		if components.count == 4 {
			// Cobvert components to double and create Color
			if let red = Double(components[0]),
				let green = Double(components[1]),
				let blue = Double(components[2]),
				let opa = Double(components[3]) {
				result.append(Color(red: red, green: green, blue: blue, opacity: opa))
			}
		}
	}
	return result
}

#Preview {
	ContentView()
}

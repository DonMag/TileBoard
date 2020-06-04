//
//  ViewController.swift
//  TileBoard
//
//  Created by Don Mag on 6/4/20.
//  Copyright © 2020 DonMag. All rights reserved.
//

import UIKit

class ViewController: UIViewController, TileBoardViewDelegate {
	
	let boardView = TileBoardView()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let resetButton = UIButton(type: .system)
		resetButton.setTitle("Reset", for: [])
		resetButton.translatesAutoresizingMaskIntoConstraints = false
		resetButton.setContentHuggingPriority(.required, for: .vertical)
		view.addSubview(resetButton)
		
		boardView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(boardView)
		
		let g = view.safeAreaLayoutGuide
		
		// the following constraints will make the board view
		//	as wide and tall as possible
		//	keeping it square
		//	and centered
		//		vertically between reset button bottom to bottom of view
		//		horizontally between the sides
		
		let myGuide = UILayoutGuide()
		view.addLayoutGuide(myGuide)
		
		let cWidth = boardView.widthAnchor.constraint(equalTo: myGuide.widthAnchor)
		cWidth.priority = .defaultHigh
		let cHeight = boardView.heightAnchor.constraint(equalTo: myGuide.heightAnchor)
		cHeight.priority = .defaultHigh
		
		NSLayoutConstraint.activate([
			
			resetButton.topAnchor.constraint(equalTo: g.topAnchor, constant: 20.0),
			resetButton.centerXAnchor.constraint(equalTo: g.centerXAnchor),
			
			myGuide.topAnchor.constraint(equalTo: resetButton.bottomAnchor, constant: 20.0),
			myGuide.leadingAnchor.constraint(equalTo: g.leadingAnchor, constant: 20.0),
			myGuide.trailingAnchor.constraint(equalTo: g.trailingAnchor, constant: -20.0),
			myGuide.bottomAnchor.constraint(equalTo: g.bottomAnchor, constant: -20.0),
			
			boardView.topAnchor.constraint(greaterThanOrEqualTo: myGuide.topAnchor, constant: 0.0),
			boardView.leadingAnchor.constraint(greaterThanOrEqualTo: myGuide.leadingAnchor, constant: 0.0),
			boardView.trailingAnchor.constraint(lessThanOrEqualTo: myGuide.trailingAnchor, constant: 0.0),
			boardView.bottomAnchor.constraint(lessThanOrEqualTo: myGuide.bottomAnchor, constant: 0.0),
			
			boardView.centerXAnchor.constraint(equalTo: myGuide.centerXAnchor),
			boardView.centerYAnchor.constraint(equalTo: myGuide.centerYAnchor),
			
			boardView.heightAnchor.constraint(equalTo: boardView.widthAnchor),
			
			cWidth,
			cHeight,
			
		])
		
		//64 character string = "1234567890123456789012345678901234567890123456789012345678901234"
		let testChars: String = "This string must have exactly 64 characters to fill the 64 tiles"
		
		// set the tile labels
		boardView.labels = testChars
		
		// set tile font
		boardView.font = UIFont.systemFont(ofSize: 12, weight: .regular)
		
		// use 1-pt spacing between tiles
		boardView.spacing = 1
		
		// use 8-pt "padding" for all 4 sides of the grid
		boardView.padding = 8
		
		// we can also set the tile
		//	"normal" background color - default is blue
		//	"selected" background color - default is red
		//	text color - default is white
		//	border color - default is yellow
		//	border width - default is 0 (no border)
		//boardView.normalBackgroundColor = .yellow
		//boardView.selectedBackgroundColor = .green
		//boardView.textColor = .black
		//boardView.borderColor = .blue
		//boardView.borderWidth = 1
		

		// sets background color for the tile board view itself
		boardView.backgroundColor = UIColor(red: 1.0, green: 212.0 / 255.0, blue: 121.0 / 255.0, alpha: 1.0)

		// set delegate to self
		boardView.delegate = self

		resetButton.addTarget(self, action: #selector(self.reset(_:)), for: .touchUpInside)
		
	}
	
	@objc
	func reset(_ sender: Any) -> Void {
		boardView.reset(nil)
	}
	
	// MARK: TileBoardViewDelegate funcs
	func didSelectTile(_ theTile: MyTileLabel) {
		print("Tile selected - Row: \(theTile.row) Col: \(theTile.col) Label: \(theTile.text!)")
	}
	func didFinishSelectingTiles(_ theTiles: [MyTileLabel]) {
		print()
		print("Finished selecting tiles:")
		theTiles.forEach { t in
			print("Tile - Row: \(t.row) Col: \(t.col) Label: \(t.text!)")
		}
		print()
	}
	
}

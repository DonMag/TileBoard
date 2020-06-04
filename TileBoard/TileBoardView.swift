//
//  TileBoardView.swift
//  TileBoard
//
//  Created by Don Mag on 6/4/20.
//  Copyright © 2020 DonMag. All rights reserved.
//

import UIKit

class MyTileLabel: UILabel {
	
	var selectedBackgroundColor: UIColor = .red
	
	var selected: Bool = false {
		didSet {
			backgroundColor = selected ? selectedBackgroundColor : normalBackgroundColor
		}
	}
	var normalBackgroundColor: UIColor = .blue {
		didSet {
			backgroundColor = normalBackgroundColor
		}
	}
	
	var row: Int = -1
	var col: Int = -1
	
}

protocol TileBoardViewDelegate: AnyObject {
	func didSelectTile(_ theTile: MyTileLabel)
	func didFinishSelectingTiles(_ theTiles: [MyTileLabel])
}
extension TileBoardViewDelegate {
	func didSelectTile(_ theTile: MyTileLabel) {}
	func didFinishSelectingTiles(_ theTiles: [MyTileLabel]) {}
}

class TileBoardView: UIView {
	
	weak var delegate: TileBoardViewDelegate?
	
	var selectedBackgroundColor: UIColor = .red {
		didSet {
			tilesArray.forEach { $0.selectedBackgroundColor = selectedBackgroundColor }
		}
	}
	var normalBackgroundColor: UIColor = .blue {
		didSet {
			tilesArray.forEach { $0.normalBackgroundColor = normalBackgroundColor }
		}
	}
	var textColor: UIColor = .white {
		didSet {
			tilesArray.forEach { $0.textColor = textColor }
		}
	}
	var font: UIFont = UIFont.systemFont(ofSize: 10, weight: .light) {
		didSet {
			tilesArray.forEach { $0.font = font }
		}
	}
	var borderColor: UIColor = .yellow {
		didSet {
			tilesArray.forEach { $0.layer.borderColor = borderColor.cgColor }
		}
	}
	var borderWidth: CGFloat = 0.0 {
		didSet {
			tilesArray.forEach { $0.layer.borderWidth = borderWidth }
		}
	}
	var spacing: CGFloat = 0.0 {
		didSet {
			if let mainSV = subviews.first as? UIStackView {
				mainSV.spacing = spacing
				mainSV.arrangedSubviews.forEach {
					if let sv = $0 as? UIStackView {
						sv.spacing = spacing
					}
				}
			}
		}
	}
	var padding: CGFloat = 0.0 {
		didSet {
			msTopConstraint.constant = padding
			msLeadingConstraint.constant = padding
			msTrailingConstraint.constant = -padding
			msBottomConstraint.constant = -padding
		}
	}
	var labels: String = "" {
		didSet {
			if labels.count != 64 {
				print("Must have 64 characters for tile labels!")
			} else {
				for (tile, label) in zip(tilesArray, labels.map { String($0) }) {
					tile.text = label
				}
			}
		}
	}
	
	var tilesArray: [MyTileLabel] = [MyTileLabel]()
	var selectableTilesArray: [MyTileLabel] = [MyTileLabel]()
	var selectedTilesArray: [MyTileLabel] = [MyTileLabel]()
	var nextSelectableTile: MyTileLabel?
	
	var msTopConstraint: NSLayoutConstraint!
	var msLeadingConstraint: NSLayoutConstraint!
	var msTrailingConstraint: NSLayoutConstraint!
	var msBottomConstraint: NSLayoutConstraint!

	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	required init?(coder: NSCoder) {
		super.init(coder: coder)
		commonInit()
	}

	let mainStack = UIStackView()

	func commonInit() -> Void {
		
		mainStack.axis = .vertical
		mainStack.distribution = .fillEqually
		
		for row in 0..<8 {
			
			let rowStack = UIStackView()
			rowStack.axis = .horizontal
			rowStack.distribution = .fillEqually
			
			for col in 0..<8 {
				let v = MyTileLabel()
				v.normalBackgroundColor = normalBackgroundColor
				v.selectedBackgroundColor = selectedBackgroundColor
				v.textColor = textColor
				v.font = font
				v.textAlignment = .center
				v.layer.borderColor = borderColor.cgColor
				v.layer.borderWidth = borderWidth
				v.selected = false
				v.row = row
				v.col = col
				v.text = "\(row)-\(col)"
				rowStack.addArrangedSubview(v)
				tilesArray.append(v)
			}
			mainStack.addArrangedSubview(rowStack)
		}
		
		mainStack.translatesAutoresizingMaskIntoConstraints = false
		addSubview(mainStack)

		msTopConstraint = mainStack.topAnchor.constraint(equalTo: topAnchor, constant: padding)
		msLeadingConstraint = mainStack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding)
		msTrailingConstraint = mainStack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
		msBottomConstraint = mainStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)

		NSLayoutConstraint.activate([
			msTopConstraint,
			msLeadingConstraint,
			msTrailingConstraint,
			msBottomConstraint,
		])
		
	}
	
	func reset(_ sender: Any?) -> Void {
		tilesArray.forEach {
			$0.selected = false
		}
		selectedTilesArray.removeAll()
	}
	
	override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		super.touchesBegan(touches, with: event)
		
		// we don't want to allow a second "start"
		//	so only process if there are no tiles already selected
		if selectedTilesArray.isEmpty {
			
			if let t = touches.first {
				//let loc = t.location(in: self)
				let loc = t.location(in: mainStack)

				var tempTile: MyTileLabel?
				
				for v in tilesArray {
					if let f = v.superview?.convert(v.frame, to: mainStack) {
						if f.contains(loc) {
							v.selected = true
							tempTile = v
							break
						}
					}
				}
				
				guard let thisTile = tempTile else {
					return
				}
				
				// here we know first touch was on a tile
				let thisRow: Int = thisTile.row
				let thisCol: Int = thisTile.col
				
				// set the array of "selected" tiles with this tile
				selectedTilesArray = [thisTile]
				
				// make sure the array of "selectable" tiles is empty
				selectableTilesArray.removeAll()
				
				// build array of tiles that can be selected next
				
				// row above and columns left / above / right
				if let tile = tilesArray.first(where: {($0.row == thisRow - 1) && ($0.col == thisCol - 1)}) {
					selectableTilesArray.append(tile)
				}
				if let tile = tilesArray.first(where: {($0.row == thisRow - 1) && ($0.col == thisCol - 0)}) {
					selectableTilesArray.append(tile)
				}
				if let tile = tilesArray.first(where: {($0.row == thisRow - 1) && ($0.col == thisCol + 1)}) {
					selectableTilesArray.append(tile)
				}
				
				// current row and columns left / right
				if let tile = tilesArray.first(where: {($0.row == thisRow - 0) && ($0.col == thisCol - 1)}) {
					selectableTilesArray.append(tile)
				}
				if let tile = tilesArray.first(where: {($0.row == thisRow - 0) && ($0.col == thisCol + 1)}) {
					selectableTilesArray.append(tile)
				}
				
				// row below and columns left / above / right
				if let tile = tilesArray.first(where: {($0.row == thisRow + 1) && ($0.col == thisCol - 1)}) {
					selectableTilesArray.append(tile)
				}
				if let tile = tilesArray.first(where: {($0.row == thisRow + 1) && ($0.col == thisCol - 0)}) {
					selectableTilesArray.append(tile)
				}
				if let tile = tilesArray.first(where: {($0.row == thisRow + 1) && ($0.col == thisCol + 1)}) {
					selectableTilesArray.append(tile)
				}
				
				delegate?.didSelectTile(thisTile)
			}
			
		}
		
	}
	
	override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
		
		super.touchesMoved(touches, with: event)
		
		if let t = touches.first {
//			let loc = t.location(in: self)
			let loc = t.location(in: mainStack)

			var tempTile: MyTileLabel?
			
			for v in tilesArray {
				if let f = v.superview?.convert(v.frame, to: mainStack) {
					if f.contains(loc) {
						if !v.selected {
							tempTile = v
						}
						break
					}
				}
			}
			
			guard let thisTile = tempTile else {
				return
			}
			
			// here we know touch moved onto an unselected tile
			
			// if thisTile is NOT in array of selectable tiles,
			//	AND thisTile is NOT the next selectable tile,
			//	return
			if !selectableTilesArray.contains(thisTile) && (thisTile != nextSelectableTile) {
				return
			}
			
			// here we know touch moved onto an unselected AND selectable tile
			
			thisTile.selected = true
			
			// it is very difficult to move diagonally without first crossing an
			//	adjacent tile, so allow a different "second tile" to be selected
			
			// get the last selected tile
			if let pt = selectedTilesArray.last {
				// if the last selected tile is in the original selectable tiles array,
				//	AND it is NOT the next selectable tile
				//	un-select it and remove it from the selected tiles array
				if selectableTilesArray.contains(pt) && thisTile != nextSelectableTile {
					pt.selected = false
					selectedTilesArray.removeLast()
				}
			}
			
			// get the previous tile
			guard let prevTile = selectedTilesArray.last else {
				// we should only ever get here if there is already at least one selected tile, so
				fatalError("This should never happen!")
			}
			
			// if this tile is the next selectable tile,
			//	clear the selectable tiles array
			if let nextTile = nextSelectableTile {
				if thisTile == nextTile {
					selectableTilesArray.removeAll()
				}
			}
			
			// add this tile to array of selected tiles
			selectedTilesArray.append(thisTile)
			
			// verbose for clarity... we could skip these local variables
			let prevRow: Int = prevTile.row
			let prevCol: Int = prevTile.col
			
			let thisRow: Int = thisTile.row
			let thisCol: Int = thisTile.col
			
			// there will be only ONE tile that can be selected next,
			//	so find it
			
			// if prev row and prev col are both not equal to this row and this col,
			//	we're moving on a diagnal
			if prevRow != thisRow && prevCol != thisCol {
				
				let nextRow = thisRow > prevRow ? thisRow + 1 : thisRow - 1
				let nextCol = thisCol > prevCol ? thisCol + 1 : thisCol - 1
				if let tile = tilesArray.first(where: {($0.row == nextRow) && ($0.col == nextCol)}) {
					nextSelectableTile = tile
				}
				
			} else if prevRow == thisRow {
				
				// here we know we're moving horizontally
				let nextRow = thisRow
				let nextCol = thisCol > prevCol ? thisCol + 1 : thisCol - 1
				if let tile = tilesArray.first(where: {($0.row == nextRow) && ($0.col == nextCol)}) {
					nextSelectableTile = tile
				}
				
			} else {
				
				// here we know we're moving vertically
				let nextRow = thisRow > prevRow ? thisRow + 1 : thisRow - 1
				let nextCol = thisCol
				if let tile = tilesArray.first(where: {($0.row == nextRow) && ($0.col == nextCol)}) {
					nextSelectableTile = tile
				}
				
			}
			
			delegate?.didSelectTile(thisTile)
		}
		
	}
	
	override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesEnded(touches, with: event)
		selectableTilesArray.removeAll()
		nextSelectableTile = nil
		delegate?.didFinishSelectingTiles(selectedTilesArray)
	}
	
	override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
		super.touchesCancelled(touches, with: event)
		selectableTilesArray.removeAll()
		nextSelectableTile = nil
	}
	
}

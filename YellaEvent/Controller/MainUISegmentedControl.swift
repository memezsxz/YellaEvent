//
//  MainUISegmentedControl.swift
//  YellaEvent
//
//  Created by Admin User on 05/12/2024.
//

import UIKit

class MainUISegmentedControl: UISegmentedControl {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    var fontSize: CGFloat {
        if K.HSizeclass == .regular && K.VSizeclass == .regular{
           return 23
        } else {
            return 14
        }
    }
    
    var height : CGFloat {
        if K.HSizeclass == .regular && K.VSizeclass == .regular {
            return 500
            } else {
               return 32
            }
    }
        
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor(named: K.BrandColors.purple)?.withAlphaComponent(0.3)
        
        selectedSegmentIndex = 0
        selectedSegmentTintColor =  UIColor(named: K.BrandColors.purple)
        
            tintColor = .white
        
        updateSegment()
    }

    @IBAction func changeSegment(_ sender: Any) {
        updateSegment()
    }
    
    var verticalPadding: CGFloat {
        return (K.HSizeclass == .regular && K.VSizeclass == .regular) ? 10 : 5
    }


    func updateSegment(){
        let textAttributesNormal: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.brandDarkPurple, // Non-selected text color
            .font: UIFont.systemFont(ofSize: fontSize) // Customize font size
        ]
        
        let textAttributesSelected: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.white, // Selected text color
            .font: UIFont.boldSystemFont(ofSize: fontSize) // Customize font size for selected
        ]
        
        // loop over the segment items
        for i in 0..<numberOfSegments{
            
            //if the tab selected the text could should be white
            if selectedSegmentIndex == i {
                setTitleTextAttributes(textAttributesSelected, for: .selected)
            }
            //if the tab not selected the text must be brandDarkPurple (defind color in the assets)
            else{
                setTitleTextAttributes(textAttributesNormal, for: .normal)
            }
        }
        
    }
}

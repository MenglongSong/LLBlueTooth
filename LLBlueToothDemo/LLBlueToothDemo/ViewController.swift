//
//  ViewController.swift
//  LLBlueToothDemo
//
//  Created by SongMenglong on 2018/12/17.
//  Copyright © 2018 SongMengLong. All rights reserved.
//

import UIKit
import LLBlueTooth

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let string = "15817998727".md5().uppercased()
        debugPrint(string)
        

        let subIndex = string.index(string.startIndex, offsetBy: 16)
        let subStr = string.prefix(upTo: subIndex)
        debugPrint(subStr)
        
    }


}


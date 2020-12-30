//
//  main.swift
//  
//
//  Created by Fabrio-Leon on 2020/12/29.
//

import Foundation
import AppIconGeneratorCore

let tool = AppIconGenerator()

do {
    try tool.run()
    print("sucessfully!")
} catch {
    print("Whoops! An error occurred: \(error)")
}

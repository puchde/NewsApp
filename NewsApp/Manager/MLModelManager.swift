//
//  MLModelManager.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2022/11/27.
//

import Foundation
import CoreML
import Vision

class MLModelManager {
    static let shared = MLModelManager()
    private var modelName: String = ""
    private var model: MLModel?
    
    func getModelName() -> String { modelName }
    
    func getVNCoreModel() -> VNCoreMLModel? {
        do {
            return try VNCoreMLModel(for: model!)
        }catch{
            print("getVNCoreModel: \(error)")
            return nil
        }
    }
    
    func changeModelName(name: String){
        self.modelName = name
    }
    
    func changeModel(name: String, model: MLModel) {
        self.modelName = name
        self.model = model
    }
}

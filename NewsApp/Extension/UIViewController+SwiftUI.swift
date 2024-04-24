//
//  UIViewController+SwiftUI.swift
//  ColorBarTesting
//
//  Created by Willy on 2024/1/30.
//

import Foundation
import SwiftUI
import Kingfisher

extension UIViewController {
    func getGuideViewSwiftUI() -> UIViewController {
        let vc = UIHostingController(rootView: GuideView(dismissAction: {
            self.dismiss(animated: true)
            newsSettingManager.updateHasVisitedGuide(true)
        }))
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
    
    struct GuideView: View {
        var guideTitle: [String] = [R.string.localizable.headlines(),
                                    R.string.localizable.search(),
                                    R.string.localizable.markList()]
        var guideDesc: [String] = [ R.string.localizable.guideStep1(),
                                    R.string.localizable.guideStep2(),
                                    R.string.localizable.guideStep3()]
        var gifsName: [String] = ["guideStep1", "guideStep2", "guideStep3"]
        var dismissAction: (() -> Void)
        @State var isHide = false
     
        var body: some View {
            GeometryReader { geo in
            VStack {
                    TabView() {
                        ForEach(0 ..< 3) { index in
                            VStack() {
                                Text(guideTitle[index])
                                    .font(.title3)
                                    .fontWeight(.medium)
                                    .padding()
                                Text(guideDesc[index])
                                    .fontWeight(.light)
                                    .lineSpacing(8)
                                    .padding(.horizontal)
                                Spacer()
                                Divider()
                                KFAnimatedImage(getGifUrl(fileName: gifsName[index]))
                                    .scaledToFit()
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: geo.size.height * 0.6)
                                    .background(.black)
                                    .cornerRadius(20)
                                    .padding()
                                    .tabItem {
                                        Text(guideDesc[index])
                                    }
                                Spacer()
                                    .frame(maxHeight: geo.size.height * 0.05)
                            }
                            .background(Color(uiColor: .white))
                            .clipShape(RoundedRectangle(cornerSize: CGSize(width: 20, height: 20)), style: FillStyle())
                            .frame(alignment: .top)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle())
                    .onAppear {
                        colorSetting()
                    }
                
                    Button(action: dismissAction, label: {
                        HStack {
                            Image(systemName: "checkmark.square")
                                .foregroundColor(Color.black)
                            Text(R.string.localizable.oK())
                                .foregroundColor(Color.black)
                        }
                        .frame(width: 130, height: 40)
                        .background(Color(uiColor: .white))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color(uiColor: .systemGray5), lineWidth: 1.5)
                        })
                        .padding()
                    })
                }
            .background(Color(uiColor: .systemGray6))
            }
        }
        
        func colorSetting() {
            UIPageControl.appearance().currentPageIndicatorTintColor = .orange.withAlphaComponent(0.3)
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.1)
        }
        
        func getGifUrl(fileName: String) -> URL {
            guard let bundleUrl = Bundle.main.url(forResource: "GuideStepGif", withExtension: "bundle"),
                  let bundle = Bundle(url: bundleUrl),
                  let filePath = bundle.path(forResource: fileName, ofType: "gif") else { return .cachesDirectory }
            let fileUrl = URL(fileURLWithPath: filePath)
            return fileUrl
        }
    }
    
}

#Preview(body: {
    UIViewController.GuideView {
        
    }
})

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
    func getGuildViewSwiftUI() -> UIViewController {
        return UIHostingController(rootView: GuildView(dismissAction: {
            self.dismiss(animated: true)
        }))
    }
    
    struct GuildView: View {
        var guildDesc: [String] = [ "👻", "", ""]
        var gifsName: [String] = ["guildStep1", "guildStep2", "guildStep3"]
        var dismissAction: (() -> Void)
        @State var isHide = false
     
        var body: some View {
            GeometryReader { geo in
            VStack {
                    TabView() {
                        ForEach(0 ..< guildDesc.count) { index in
                            VStack() {
                                Text(guildDesc[index])
                                Spacer()
                                Divider()
                                KFAnimatedImage(getGifUrl(fileName: gifsName[index]))
                                    .scaledToFit()
                                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: geo.size.height * 0.6)
                                    .background(.black)
                                    .cornerRadius(20)
                                    .padding()
                                    .tabItem {
                                        Text(guildDesc[index])
                                    }
                                Spacer()
                                    .frame(maxHeight: geo.size.height * 0.05)
                            }
                            .frame(alignment: .top)
                            .padding()
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
                            Text("got it")
                                .foregroundColor(Color.black)
                        }
                        .frame(width: 130, height: 40)
                        .background(.orange.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .overlay(content: {
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.orange.opacity(0.3), lineWidth: 1.5)
                        })
                        .padding()
                    })
                }
            }
        }
        
        func colorSetting() {
            UIPageControl.appearance().currentPageIndicatorTintColor = .orange.withAlphaComponent(0.3)
            UIPageControl.appearance().pageIndicatorTintColor = UIColor.black.withAlphaComponent(0.1)
        }
        
        func getGifUrl(fileName: String) -> URL {
            guard let filePath = Bundle.main.path(forResource: fileName, ofType: "gif") else { return URL(string: "") ?? .cachesDirectory}
            let fileUrl = URL(fileURLWithPath: filePath)
            return fileUrl
        }
    }
    
}

#Preview(body: {
    UIViewController.GuildView {
        
    }
})

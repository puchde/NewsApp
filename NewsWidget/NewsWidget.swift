//
//  NewsWidget.swift
//  NewsWidget
//
//  Created by Willy on 2024/1/16.
//

import WidgetKit
import SwiftUI
import rswift
import Kingfisher
import Network
import AppIntents


struct NewsWidget: Widget {
    let kind: String = "NewsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                NewsWidgetEntryView(entry: entry)
                    .containerBackground(Color("WidgetBackground").tertiary, for: .widget)
            } else {
                NewsWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName(R.string.localizable.widgetDefaultDisplayName())
        .description(R.string.localizable.widgetDefaultDesc())
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

//MARK: Widget / View - V
struct NewsWidgetEntryView : View {
    var entry: NewsEntry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            WidgetSmallView(entry: entry)
        case .systemMedium:
            WidgetMediumView(entry: entry)
        case .systemLarge:
            WidgetLargeView(entry: entry)
        default:
            VStack {
                Text("")
            }
        }
    }
}

struct WidgetSmallView: View {
    var entry: NewsEntry
    var body: some View {
        
        VStack(alignment: .leading) {
            
        }
    }
}

struct WidgetMediumView: View {
    var entry: NewsEntry
    var body: some View {
        
        VStack(alignment: .leading) {
            WidgetNewsView(entry: entry)
            
            WidgetButtonView()
        }
    }
}

struct WidgetLargeView: View {
    var entry: NewsEntry
    
    var body: some View {
        
        VStack(alignment: .leading) {
            VStack {
                WidgetNewsView(entry: entry, isLargeWidget: true)
                Divider()
                    .background(Color("WidgetBackground"))
                    .padding(.bottom, 6)
                WidgetNewsView(entry: entry, isLargeWidget: true, nextNum: 1)
                Divider()
                    .background(Color("WidgetBackground"))
                    .padding(.bottom, 6)
                WidgetNewsView(entry: entry, isLargeWidget: true, nextNum: 2)
            }
            WidgetButtonView(isLargeWidge: true)
        }
    }
}

//MARK: 共用View
//MARK: 共用Widget News
/// Medium, Large顯示模式相同
/// 根據isLargeWidget, nextNum顯示Large資料

struct WidgetNewsView: View {
    var entry: NewsEntry
    var isLargeWidget = false
    var nextNum: Int = 0
    var index: Int {
        if isLargeWidget {
            (entry.newsNum * 3) + nextNum
        } else {
            entry.newsNum + nextNum
        }
    }
    var hasNews: Bool {
        index > entry.news.count - 1 ? false : true
    }

    var body: some View {
        if hasNews {
            VStack {
                HStack(alignment: .top) {
                    Link(destination: URL(string: "\(LinkUrlEnum.testOpenNews(url: entry.news[index].url).urlStr)")!) {
                        VStack {
                            Spacer()
                            KFImage(URL(string: entry.news[index].urlToImage ?? ""))
                                .placeholder { _ in
                                    Image("noPhoto")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 90, alignment: .center)
                                }
                                .resizable()
                                .scaledToFit()
                                .frame(width: 90, alignment: .center)
                            Spacer()
                            Text(entry.news[index].publishedAt)
                                .font(.caption2)
                                .tint(.primary)
                                .frame(maxWidth: .infinity)
                                .background(Color(uiColor: .systemBackground).opacity(0.8))
                                .clipShape(RoundedRectangle(cornerSize: CGSize(width: 5, height: 5)))
                            
                        }
                        .frame(maxWidth: 90)
                        .padding(.trailing, 8)
                    }
                    VStack(alignment: .center) {
                        VStack(alignment: .center) {
                            Link(destination: URL(string: "\(LinkUrlEnum.testOpenNews(url: entry.news[index].url).urlStr)")!) {
                                HStack(alignment: .center) {
                                    Text(entry.news[index].author ?? "News")
                                        .font(.system(size: 10))
                                        .tint(.primary)
                                        .padding(.top, 5)
                                        .frame(alignment: .center)
                                }
                                Divider()
                                HStack {
                                    Spacer()
                                    Text(entry.news[index].title)
                                        .font(.caption)
                                        .tint(.primary)
                                        .lineSpacing(3)
                                        .frame(alignment: .leading)
                                    Spacer()
                                }
                            }
                        }
                        Spacer()
                    }
                    .frame(width: .infinity)
                    .background(Color(uiColor: .systemBackground))
                    .clipShape(RoundedRectangle(cornerSize: CGSize(width: 10, height: 10)))
                }
            }
        } else {
            Spacer()
                .frame(maxHeight: .infinity)
        }
    }
}

//MARK: 共用Widget Button
struct WidgetButtonView: View {
    var isLargeWidge: Bool = false
    
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .bottom, content: {
                if isLargeWidge {
                    Button(intent: PreviousNewsIntentLarge()) {
                        Image(systemName: "arrowshape.backward.fill")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.orange.secondary)
                    }
                    .tint(Color.white.opacity(0.9))
                    .buttonStyle(.borderedProminent)
                    
                    Button(intent: NextNewsIntentLarge()) {
                        Image(systemName: "arrowshape.forward.fill")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.orange.secondary)
                    }
                    .tint(Color.white.opacity(0.9))
                    .buttonStyle(.borderedProminent)
                } else {
                    Button(intent: PreviousNewsIntent()) {
                        Image(systemName: "arrowshape.backward.fill")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.orange.secondary)
                    }
                    .tint(Color.white.opacity(0.9))
                    .buttonStyle(.borderedProminent)
                    
                    Button(intent: NextNewsIntent()) {
                        Image(systemName: "arrowshape.forward.fill")
                            .frame(maxWidth: .infinity)
                            .foregroundStyle(Color.orange.secondary)
                    }
                    .tint(Color.white.opacity(0.9))
                    .buttonStyle(.borderedProminent)
                }
            })
        }
    }
}

#Preview(as: .systemLarge) {
    NewsWidget()
} timeline: {
    NewsEntry.testEntry()
}

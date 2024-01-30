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
                    .containerBackground(.fill.tertiary, for: .widget)
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
        .background(Color.red)
    }
}

struct WidgetMediumView: View {
    var entry: NewsEntry
    var body: some View {
        
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                Link(destination: URL(string: "cbtesting://open-news?url=\(entry.news[entry.newsNum].url)")!) {
                    VStack {
                        KFImage(URL(string: entry.news[entry.newsNum].urlToImage ?? ""))
                            .placeholder { _ in
                                Image("noPhoto")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 90, height: 80, alignment: .center)
                            }
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 80, alignment: .center)
                        Text(entry.news[entry.newsNum].publishedAt)
                            .font(.caption2)
                    }
                    .frame(maxWidth: 90)
                    .padding(.trailing, 8)
                }
                VStack(alignment: .leading) {
                    Spacer()
                    Link(destination: URL(string: "cbtesting://open-news?url=\(entry.news[entry.newsNum].url)")!) {
                        HStack(alignment: .top) {
                            Text(entry.news[entry.newsNum].author ?? "News")
                                .font(.caption2)
                                .padding(.bottom, 5)
                                .frame(alignment: .center)
                        }
                        
                        Text(entry.news[entry.newsNum].title)
                            .font(.caption)
                            .lineSpacing(5)
                            .frame(alignment: .leading)
                        
                    }
                    Spacer()
                }
            }
            VStack(alignment: .trailing) {
                HStack(alignment: .bottom, content: {
                    Button(intent: PreviousNewsIntent()) {
                        Image(systemName: "arrow.backward")
                            .frame(maxWidth: .infinity)

                    }
                    Button(intent: NextNewsIntent()) {
                        Image(systemName: "arrow.forward")
                            .frame(maxWidth: .infinity)
                    }
                })
            }
        }
    }
}

struct WidgetLargeView: View {
    var entry: NewsEntry
    var body: some View {
        
        VStack(alignment: .leading) {
        }
        .background(Color.red)
    }
}


#Preview(as: .systemMedium) {
    NewsWidget()
} timeline: {
    NewsEntry.testEntry()
}

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


//MARK: Widget / View - V
struct NewsWidgetEntryView : View {
    var entry: NewsEntry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            Text("Time:")
        case .systemMedium:
            VStack(alignment: .leading) {
                HStack(alignment: .top) {
                    VStack {
                        Image("noPhoto")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 90, height: 80, alignment: .center)
                        VStack(alignment: .center) {
                            Text(entry.news[entry.newsNum].author ?? "News")
                                .font(.caption2)
                                .padding(.bottom, 5)
                                .frame(alignment: .center)
                                .background(Color.yellow)
                        }
                        Text(entry.news[entry.newsNum].publishedAt)
                            .font(.caption2)
                            .background()
                    }
                    .frame(maxWidth: 90)
                    .padding(.trailing, 8)
                    VStack(alignment: .leading) {
                        Text(entry.news[entry.newsNum].title)
                            .font(.caption)
                            .frame(alignment: .leading)
                            .background(Color.green)
                        
                        Spacer()
                        VStack(alignment: .trailing) {
                            HStack(alignment: .bottom, content: {
                                Spacer()
                                Button(intent: PreviousNewsIntent()) {
                                    Image(systemName: "arrow.backward")
                                }
                                Spacer()
                                Button(intent: NextNewsIntent()) {
                                    Image(systemName: "arrow.forward")
                                }
                                Spacer()
                            })
                        }
                        .background(Color.gray)
                    }
                }
            }
            .background(Color.red)
        case .systemLarge:
            Text("Time:")
        case .systemExtraLarge:
            Text("Time:")
        default:
            VStack {
                Text("")
            }
        }
    }
}

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
        .configurationDisplayName("NewsTip")
        .description("zz.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge, .systemExtraLarge])
    }
}

#Preview(as: .systemMedium) {
    NewsWidget()
} timeline: {
    NewsEntry.testEntry()
}

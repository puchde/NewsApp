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
            VStack {
                HStack {
                    VStack {
                        Image("noPhoto")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                        //                        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/, /*@START_MENU_TOKEN@*/10/*@END_MENU_TOKEN@*/)
                        Text(entry.news[entry.newsNum].publishedAt)
                            .font(.footnote)
                    }
                    VStack {
                        Text(entry.news[entry.newsNum].author ?? "News")
                            .font(.caption)
                            .padding(.top, 5)
                            .frame(maxHeight: 0)
                        Text(entry.news[entry.newsNum].title)
                            .font(.title3)
//                        .padding(.top, 5)
//                            .frame(height: .infinity)
                        
                        Spacer()
                        HStack {
                            Spacer()
                            Button(intent: PreviousNewsIntent()) {
                                Image(systemName: "arrow.backward")
//                                    .frame(width: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
                            }
                            Spacer()
                            Button(intent: NextNewsIntent()) {
                                Image(systemName: "arrow.forward")
                            }
                            Spacer()
                        }
                    }
//                    Spacer()
                }
                
            }
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

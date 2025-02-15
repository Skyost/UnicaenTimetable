//
//  TodayWidget.swift
//  TodayWidget
//
//  Created by Skyost on 15/02/2025.
//

import WidgetKit
import SwiftUI

private let widgetGroupId = "group.fr.skyost.timetable"
private let widgetId = "TodayWidget"
private let defaultLesson = Lesson(
    name: "TD Algèbre linéaire 3",
    start: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    end: Calendar.current.date(bySettingHour: 12, minute: 15, second: 0, of: Date())!,
    location: "S2 322"
)

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> LessonEntry {
        return LessonEntry(lessons: [defaultLesson])
    }
    
    func getSnapshot(in context: Context, completion: @escaping (LessonEntry) -> ()) {
        var entry = LessonEntry(lessons: [])
        if context.isPreview {
            entry.lessons.append(defaultLesson)
        }
        else {
            do {
                let lessonsFile = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!.appendingPathComponent("lessons.json")
                let jsonData = try String(contentsOf: fileURL, encoding: .utf8)
                let jsonLessons: [String: JsonLesson] = try! JSONDecoder().decode([String: JsonLesson].self, from: jsonData)
                let allLessons: [Date: [JsonLesson]] = [:]
                for jsonDate in jsonLessons.keys {
                    let lessonsOfDate: [Lesson] = []
                    for jsonLesson in jsonLessons[jsonDate] {
                        lessonsOfDate.append(Lesson(
                            name: jsonLesson.name,
                            start: NSDate(timeIntervalSince1970: jsonLesson.start),
                            end: NSDate(timeIntervalSince1970: jsonLesson.end),
                            location: jsonLesson.location
                        ))
                    }
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "yyyy'-'MM'-'dd'"
                    allLessons[dateFormatter.dateFromString(jsonDate)] = lessonsOfDate
                }
                let lessons: [Lesson] = (lessons?[Date()] as? [Lesson]) ?? []
                for lesson in lessons {
                    entry.lessons.append(Lesson(name: lesson))
                }
            }
            catch {
                entry.error = "Failed to load your timetable."
            }
        }
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            let timeline = Timeline(entries: [entry], policy: .atEnd)
            completion(timeline)
        }
    }
}

struct JsonLesson: Decodable {
    let name: String
    let description: String
    let start: Number
    let end: Number
    let location: String
}

struct LessonEntry: TimelineEntry {
    let date: Date = tomorrowMidnight()
    var error: String?
    var lessons: [Lesson]
    
    func buildLessonsString() -> String {
        if error {
            return error
        }
        var result = ""
        for lesson in lessons {
            result = result + lesson.buildLessonString() + "\n\n"
        }
        return result
    }
    
    static func tomorrowMidnight () -> Date {
        return Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: Calendar.autoupdatingCurrent.startOfDay(for: Date()))!
    }
}

struct Lesson {
    // let id = UUID()
    let name: String
    let start: Date
    let end: Date
    let location: String

    func buildLessonString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return "**\(name)**\n\n\(dateFormatter.string(start)) - \(dateFormatter.string(end))\n\n_\(location)_"
    }
}

struct TodayWidgetEntryView : View {
    static let backgroundColor = Color(red: 44 / 255, green: 62 / 255, blue: 80 / 255)
    static let textColor = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName: widgetGroupId)

    let date = Date()
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "dd/MM/yyyy"
    let formattedDate = dateFormatter.string(from: date)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(date, style: .date)
                .font(.system(size: 16))
                .foregroundColor(TodayWidgetEntryView.textColor)
                .bold()
                .truncationMode(.tail)
            Divider()
                .background(TodayWidgetEntryView.textColor)
                .padding(EdgeInsets.init(top: 5, leading: 0, bottom: 10, trailing: 0))
            if (entry.lessons.isEmpty) {
                Text("Nothing for this day. If you think there should be something, please refresh your timetable.")
                    .font(.system(size: 14))
                    .foregroundColor(TodayWidgetEntryView.textColor)
                    .italic()
            }
            else {
                Text(AttributedString(entry.buildLessonsString()))
                    .font(.system(size: 14))
                    .foregroundColor(TodayWidgetEntryView.textColor)
            }
            Spacer()
        }
        .widgetURL(URL(string: "todayWidget://lessons?date=\(formattedDate)&homeWidget"))
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(EdgeInsets.init(top: 10, leading: 15, bottom: 10, trailing: 15))
        .background(TodayWidgetEntryView.backgroundColor)
    }
}

@main
struct TodayWidget: Widget {
    let kind: String = "TodayWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TodayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Today")
        .description("Display today's timetable.")
    }
}

struct TodayWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayWidgetEntryView(entry: LessonEntry(lessons: [defaultLesson]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
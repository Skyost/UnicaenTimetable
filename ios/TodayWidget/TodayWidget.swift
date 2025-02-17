//
//  TodayWidget.swift
//  TodayWidget
//
//  Created by Skyost on 15/02/2025.
//

import WidgetKit
import SwiftUI
import AppIntents

private let widgetGroupId = "group.fr.skyost.timetable"
private let widgetId = "TodayWidget"
private let defaultLesson = Lesson(
    name: "TD Algèbre linéaire 3",
    start: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    end: Calendar.current.date(bySettingHour: 12, minute: 15, second: 0, of: Date())!,
    location: "S2 322"
)

class TodayWidgetDateManager {
    static var relativeDay: Int = 0
    
    static func plusRelativeDay() {
        relativeDay += 1
    }
    
    static func minusRelativeDay() {
        relativeDay -= 1
    }
    
    static var absoluteDay: Date {
        get {
            var today = Date()
            today.addTimeInterval(TimeInterval(86400 * relativeDay))
            return today
        }
    }
}

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
                let lessonsFile = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.fr.skyost.timetable")!.appendingPathComponent("lessons.json")
                if FileManager.default.fileExists(atPath: lessonsFile.path) {
                    let jsonData = try String(contentsOf: lessonsFile, encoding: .utf8).data(using: .utf8)!
                    let jsonLessons: [String: [JsonLesson]] = try! JSONDecoder().decode([String: [JsonLesson]].self, from: jsonData)
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    let now = Date()
                    let targetKey = dateFormatter.string(from: now)
                    for jsonDate in jsonLessons.keys {
                        if jsonDate != targetKey {
                            continue
                        }
                        for jsonLesson in jsonLessons[jsonDate]! {
                            let lesson = Lesson(
                                name: jsonLesson.name,
                                start: NSDate(timeIntervalSince1970: TimeInterval(jsonLesson.start)) as Date,
                                end: NSDate(timeIntervalSince1970: TimeInterval(jsonLesson.end)) as Date,
                                location: jsonLesson.location
                            )
                            if (now <= lesson.end) {
                                entry.lessons.append(lesson)
                            }
                        }
                    }
                }
            }
            catch {
                entry.error = "Failed to load your timetable : \(error)."
            }
        }
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LessonEntry>) -> ()) {
        getSnapshot(in: context) { (entry) in
            var updateDate: Date
            if (entry.lessons.isEmpty) {
                updateDate = Date()
                updateDate = updateDate.addingTimeInterval(86400)
            } else {
                updateDate = entry.lessons.first!.end
            }
            let timeline = Timeline(entries: [entry], policy: .after(updateDate))
            completion(timeline)
        }
    }
}

struct JsonLesson: Decodable {
    let name: String
    let description: String
    let start: Int
    let end: Int
    let location: String
}

struct LessonEntry: TimelineEntry {
    let date: Date = tomorrowMidnight()
    var error: String?
    var lessons: [Lesson]
    
    func buildLessonsString() -> String {
        var result = ""
        for lesson in lessons {
            result = result + lesson.buildLessonString() + "\n\n"
        }
        return String(String(result.dropLast()).dropLast())
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
        return "**\(name)**\n\n\(dateFormatter.string(from: start)) - \(dateFormatter.string(from: end))\n\n_\(location)_"
    }
}

struct TodayWidgetEntryView : View {
    static let backgroundColor = Color(red: 44 / 255, green: 62 / 255, blue: 80 / 255)
    static let textColor = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    
    var entry: Provider.Entry
    let data = UserDefaults.init(suiteName: widgetGroupId)
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack() {
                Text(TodayWidgetDateManager.absoluteDay, style: .date)
                    .font(.system(size: 16))
                    .foregroundColor(TodayWidgetEntryView.textColor)
                    .bold()
                    .truncationMode(.tail)
                Spacer()
                if #available(iOS 17.0, *) {
                    HStack() {
                        if (TodayWidgetDateManager.relativeDay > 0) {
                            Button(intent: PreviousDay()) {
                                Image(systemName: "arrow.left")
                            }
                        }
                        Button(intent: NextDay()) {
                            Image(systemName: "arrow.right")
                        }
                    }
                        .tint(TodayWidgetEntryView.textColor)
                }
            }
            Divider()
                .background(TodayWidgetEntryView.textColor)
                .padding(EdgeInsets.init(top: 5, leading: 0, bottom: 10, trailing: 0))
            if (entry.error != nil) {
                Text(entry.error!)
                    .font(.system(size: 14))
                    .foregroundColor(TodayWidgetEntryView.textColor)
                    .italic()
            }
            else if (entry.lessons.isEmpty) {
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
        .widgetURL(URL(string: "todayWidget://lessons?date=\(formatDate(TodayWidgetDateManager.absoluteDay))"))
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .padding(EdgeInsets.init(top: 10, leading: 15, bottom: 10, trailing: 15))
        .background(TodayWidgetEntryView.backgroundColor)
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
}

@available(iOS 16.0, *)
struct PreviousDay: AppIntent {
    static var title: LocalizedStringResource = "Previous day"
    static var description = IntentDescription("Displays the previous day's timetable.")
    
    func perform() async throws -> some IntentResult {
        TodayWidgetDateManager.minusRelativeDay()
        return .result()
    }
}

@available(iOS 16.0, *)
struct NextDay: AppIntent {
    static var title: LocalizedStringResource = "Next day"
    static var description = IntentDescription("Displays the next day's timetable.")
    
    func perform() async throws -> some IntentResult {
        TodayWidgetDateManager.plusRelativeDay()
        return .result()
    }
}

@main
struct TodayWidget: Widget {
    let kind: String = "TodayWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOSApplicationExtension 17.0, *) {
                TodayWidgetEntryView(entry: entry)
                    .containerBackground(TodayWidgetEntryView.backgroundColor, for: .widget)
            } else {
                TodayWidgetEntryView(entry: entry)
            }
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

//
//  TodayWidget.swift
//  TodayWidget
//
//  Created by Skyost on 15/02/2025.
//

import AppIntents
import SwiftUI
import WidgetKit

private let widgetGroupId = "group.fr.skyost.timetable"
private let widgetId = "TodayWidget"
private let defaultLesson = Lesson(
    id: "preview-0",
    name: "TD Algèbre linéaire 3",
    start: Calendar.current.date(bySettingHour: 9, minute: 30, second: 0, of: Date())!,
    end: Calendar.current.date(bySettingHour: 12, minute: 15, second: 0, of: Date())!,
    location: "S2 322"
)

enum TodayWidgetDateManager {
    static var relativeDay: Int = 0
    
    static func plusRelativeDay() {
        relativeDay += 1
    }
    
    static func minusRelativeDay() {
        relativeDay -= 1
    }
    
    static var absoluteDay: Date {
        var today = Date()
        today.addTimeInterval(TimeInterval(86400 * relativeDay))
        return today
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
                    let targetKey = dateFormatter.string(from: TodayWidgetDateManager.absoluteDay)
                    for jsonDate in jsonLessons.keys {
                        if jsonDate != targetKey {
                            continue
                        }
                        let lessons = jsonLessons[jsonDate]!
                        var hasSkippedLessons = false
                        for i in 0 ... lessons.count - 1 {
                            let jsonLesson = lessons[i]
                            let lesson = Lesson(
                                id: "\(jsonDate)-\(i)",
                                name: jsonLesson.name,
                                start: NSDate(timeIntervalSince1970: TimeInterval(jsonLesson.start)) as Date,
                                end: NSDate(timeIntervalSince1970: TimeInterval(jsonLesson.end)) as Date,
                                location: jsonLesson.location
                            )
                            if now <= lesson.end {
                                entry.lessons.append(lesson)
                            }
                            else {
                                hasSkippedLessons = true
                            }
                        }
                        if hasSkippedLessons {
                            entry.hasNoMoreLesson = entry.lessons.isEmpty
                        }
                        break
                    }
                }
            }
            catch {
                entry.error = "\(error)"
            }
        }
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<LessonEntry>) -> ()) {
        getSnapshot(in: context) { entry in
            var updateDate: Date
            if entry.lessons.isEmpty {
                updateDate = Date()
                updateDate = updateDate.addingTimeInterval(86400)
            }
            else {
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
    var hasNoMoreLesson: Bool = false
    
    static func tomorrowMidnight() -> Date {
        return Calendar.autoupdatingCurrent.date(byAdding: .day, value: 1, to: Calendar.autoupdatingCurrent.startOfDay(for: Date()))!
    }
}

struct Lesson: Identifiable {
    let id: String
    let name: String
    let start: Date
    let end: Date
    let location: String
}

struct TodayWidgetEntryView: View {
    static let backgroundColor = Color(red: 44 / 255, green: 62 / 255, blue: 80 / 255)
    static var textColor: Color {
        if #available(iOSApplicationExtension 17.0, *) {
            return Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
        }
        else {
            return Color(red: 0 / 255, green: 0 / 255, blue: 0 / 255)
        }
    }

    var maxVisibleLessons: Int {
        if family == .systemLarge {
            return 4
        }
        return 1
    }
    
    var entry: Provider.Entry
    let data = UserDefaults(suiteName: widgetGroupId)
    
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .center) {
                Text(TodayWidgetDateManager.absoluteDay, style: .date)
                    .font(.system(size: 16))
                    .foregroundColor(TodayWidgetEntryView.textColor)
                    .bold()
                    .truncationMode(.tail)
                    .lineLimit(1)
                Spacer()
                if family == .systemMedium || family == .systemLarge {
                    if #available(iOS 17.0, *) {
                        buildButtons(.regular)
                    }
                }
            }
            if family == .systemSmall {
                if #available(iOS 17.0, *) {
                    buildButtons(.mini)
                        .padding(EdgeInsets(top: 5, leading: 0, bottom: 5, trailing: 0))
                }
            }
            Divider()
                .background(TodayWidgetEntryView.textColor)
                .padding(EdgeInsets(top: 5, leading: 0, bottom: 10, trailing: 0))
            if entry.error != nil {
                Text(entry.error!)
                    .font(.system(size: 14))
                    .foregroundColor(TodayWidgetEntryView.textColor)
                    .italic()
            }
            else if entry.lessons.isEmpty {
                if entry.hasNoMoreLesson {
                    Text("noMoreLesson")
                        .font(.system(size: 14))
                        .foregroundColor(TodayWidgetEntryView.textColor)
                        .italic()
                }
                else {
                    Text("nothing")
                        .font(.system(size: 14))
                        .foregroundColor(TodayWidgetEntryView.textColor)
                        .italic()
                }
            }
            else {
                ForEach(entry.lessons.prefix(maxVisibleLessons)) { (lesson: Lesson) in
                    Text(lesson.name)
                        .font(.system(size: 14))
                        .foregroundColor(TodayWidgetEntryView.textColor)
                        .bold()
                        .lineLimit(1)
                    Text(buildLessonTime(lesson))
                        .font(.system(size: 14))
                        .foregroundColor(TodayWidgetEntryView.textColor)
                        .lineLimit(1)
                    if family == .systemMedium || family == .systemLarge {
                        Text(lesson.location)
                            .font(.system(size: 14))
                            .foregroundColor(TodayWidgetEntryView.textColor)
                            .italic()
                            .lineLimit(1)
                    }
                    Spacer()
                        .frame(height: 5)
                }
                if entry.lessons.count > maxVisibleLessons {
                    Spacer()
                    Text("andMore \(entry.lessons.count - maxVisibleLessons)")
                        .font(.system(size: family == .systemMedium || family == .systemLarge ? 14 : 10))
                        .foregroundColor(TodayWidgetEntryView.textColor)
                        .italic()
                }
            }
            Spacer()
        }
        .widgetURL(URL(string: "todayWidget://timetable?date=\(formatDate(TodayWidgetDateManager.absoluteDay))"))
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
        .background(TodayWidgetEntryView.backgroundColor)
    }
    
    @available(iOS 17.0, *)
    func buildButtons(_ controlSize: ControlSize) -> some View {
        HStack {
            if TodayWidgetDateManager.relativeDay > 0 {
                Button(intent: PreviousDay()) {
                    Image(systemName: "arrow.left")
                }.controlSize(controlSize)
            }
            Button(intent: NextDay()) {
                Image(systemName: "arrow.right")
            }.controlSize(controlSize)
        }
        .tint(TodayWidgetEntryView.textColor)
    }
    
    func buildLessonTime(_ lesson: Lesson) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        return "\(dateFormatter.string(from: lesson.start)) - \(dateFormatter.string(from: lesson.end))"
    }
    
    func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter.string(from: date)
    }
}

@available(iOS 16.0, *)
struct PreviousDay: AppIntent {
    static var title: LocalizedStringResource = "previousDayTitle"
    static var description = IntentDescription("previousDayDescription")
    
    func perform() async throws -> some IntentResult {
        TodayWidgetDateManager.minusRelativeDay()
        return .result()
    }
}

@available(iOS 16.0, *)
struct NextDay: AppIntent {
    static var title: LocalizedStringResource = "nextDayTitle"
    static var description = IntentDescription("nextDayDescription")
    
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
            }
            else {
                TodayWidgetEntryView(entry: entry)
                    .padding(EdgeInsets(top: 10, leading: 15, bottom: 10, trailing: 15))
            }
        }
        .configurationDisplayName("title")
        .description("description")
    }
}

struct TodayWidget_Previews: PreviewProvider {
    static var previews: some View {
        TodayWidgetEntryView(entry: LessonEntry(lessons: [defaultLesson]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}

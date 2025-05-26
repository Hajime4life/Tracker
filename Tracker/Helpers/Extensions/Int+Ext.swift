import Foundation

extension Int {
    /// Возвращает строку с числом и правильной формой слова "день", "дня" или "дней".
    /// Например: 1.daysDeclension() -> "1 день", 2.daysDeclension() -> "2 дня", 5.daysDeclension() -> "5 дней".
    func daysDeclension() -> String {
        let lastDigit = self % 10
        let lastTwoDigits = self % 100
        
        if lastDigit == 1 && lastTwoDigits != 11 {
            return "\(self) день"
        } else if (2...4).contains(lastDigit) && !(12...14).contains(lastTwoDigits) {
            return "\(self) дня"
        } else {
            return "\(self) дней"
        }
    }
}

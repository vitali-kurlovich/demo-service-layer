import DataLayer
import Testing

struct SymbolTest {
    @Test func compare() {
        #expect(Symbol("ABC") < Symbol("ABD"))
    }
}

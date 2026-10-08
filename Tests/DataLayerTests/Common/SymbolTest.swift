import DataLayer
import Testing

struct SymbolTest {
    @Test("ExpressibleByStringLiteral")
    func stringLiteral() {
        let symbol: Symbol = "ABC"

        #expect(symbol == Symbol("ABC"))
    }

    @Test("LosslessStringConvertible")
    func stringConvertible() {
        let symbol = Symbol("ABC")
        #expect(symbol.description == "ABC")
    }

    @Test func identifiable() {
        let symbol = Symbol("ABC")
        #expect(symbol.id == "ABC")
    }

    @Test func compare() {
        #expect(Symbol("ABC") < Symbol("ABD"))
    }
}

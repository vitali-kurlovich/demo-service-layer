import Testing
import DataLayer



struct SymbolTest {

    @Test func compare()   {
        #expect(  Symbol("ABC") <  Symbol("ABD") )
       
    }
    
}

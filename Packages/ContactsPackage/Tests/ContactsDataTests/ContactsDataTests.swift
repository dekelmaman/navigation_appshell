import ContactsContracts
import Testing

@testable import ContactsData

@Suite struct LiveContactsDataProviderTests {
  private let provider = LiveContactsDataProvider()

  @Test func getAllItemsReturnsFullCatalog() async {
    let items = await provider.getAllItems()
    #expect(items.count == 4)
  }

  @Test func getItemReturnsKnownContact() async {
    let item = await provider.getItem(id: "c-3")
    #expect(item?.name == "Grace Hopper")
  }

  @Test func getItemReturnsNilForUnknownID() async {
    let item = await provider.getItem(id: "does-not-exist")
    #expect(item == nil)
  }
}

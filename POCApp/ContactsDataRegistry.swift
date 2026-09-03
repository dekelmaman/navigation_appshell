import Contacts
import ContactsContracts

/// The app shell's Data registry. Holds the resolved contacts data provider,
/// built from the Contacts facade's live provider. This is the counterpart to
/// `NavigationRegistry`: the single place the shell resolves the external
/// `ContactsDataProviding` contract to a concrete implementation.
struct ContactsDataRegistry {
  let provider: any ContactsDataProviding

  init(provider: any ContactsDataProviding = Contacts.Data.live()) {
    self.provider = provider
  }
}

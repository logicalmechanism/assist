//// This module includes code to help with creating wallet and script addresses.
////
//// Empty keys are assumed to be on purpose.

use aiken/bytearray
use aiken/hash.{Blake2b_224, Hash}
use aiken/transaction/credential.{
  Address, Inline, Script, ScriptCredential, VerificationKey,
  VerificationKeyCredential,
}

/// Creates a enterprise or base address from the public key hash and stake
/// credential. An empty sc means enterpise address by default.
///
/// ```aiken
/// addresses.create_address(#"acab", #"")
/// addresses.create_address(datum.wallet.pkh, datum.wallet.sc)
/// ```
pub fn create_address(
  pkh: Hash<Blake2b_224, VerificationKey>,
  sc: Hash<Blake2b_224, VerificationKey>,
) -> Address {
  // empty bytearrays means dont add the sc to the pkh
  if bytearray.is_empty(sc) {
    credential.from_verification_key(pkh)
  } else {
    credential.from_verification_key(pkh)
      |> credential.with_delegation_key(sc)
  }
}

test enterprise_wallet() {
  let addr =
    Address {
      payment_credential: VerificationKeyCredential(#"acab"),
      stake_credential: None,
    }
  create_address(#"acab", #"") == addr
}

test base_wallet() {
  let addr =
    Address {
      payment_credential: VerificationKeyCredential(#"acab"),
      stake_credential: Some(Inline(VerificationKeyCredential(#"face"))),
    }
  create_address(#"acab", #"face") == addr
}

/// Creates an address for a smart contract. The type does not mix address
/// types. Staked smart contracts are contracts as well. An empty sc is
/// assumed to be not staked.
///
/// ```aiken
/// addresses.create_script_address(#"acab", #"")
/// addresses.create_script_address(ref_datum.sale_script.pkh, ref_datum.sale_script.sc)
/// ```
pub fn create_script_address(
  pkh: Hash<Blake2b_224, Script>,
  sc: Hash<Blake2b_224, Script>,
) -> Address {
  // empty bytearrays means dont add the sc to the pkh
  if bytearray.is_empty(sc) {
    credential.from_script(pkh)
  } else {
    credential.from_script(pkh)
      |> credential.with_delegation_script(sc)
  }
}

test enterprise_script() {
  let script_addr =
    Address {
      payment_credential: ScriptCredential(#"acab"),
      stake_credential: None,
    }
  create_script_address(#"acab", #"") == script_addr
}

test base_script() {
  let script_addr =
    Address {
      payment_credential: ScriptCredential(#"acab"),
      stake_credential: Some(Inline(ScriptCredential(#"face"))),
    }
  create_script_address(#"acab", #"face") == script_addr
}
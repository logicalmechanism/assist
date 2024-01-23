//// Experimental

use aiken/builtin
use assist/types/hashes.{PublicKeyHash}

/// A data type to prive a signature but also a method of bringing in signed 
/// data into a contract.
pub type SignedData {
  verification_key: PublicKeyHash,
  message: ByteArray,
  signature: ByteArray,
}

pub fn ed25519(sd: SignedData) -> Bool {
  builtin.verify_ed25519_signature(
    sd.verification_key,
    sd.message,
    sd.signature,
  )
}

pub fn convert_ed25519(sd: SignedData) -> Data {
  expect data_structure: Data = builtin.b_data(sd.message)
  if ed25519(sd) {
    data_structure
  } else {
    fail @"Invalid Ed25519 Signature"
  }
}

pub fn ecdsa(sd: SignedData) -> Bool {
  builtin.verify_ecdsa_secp256k1_signature(
    sd.verification_key,
    sd.message,
    sd.signature,
  )
}

pub fn convert_ecdsa(sd: SignedData) -> Data {
  expect data_structure: Data = builtin.b_data(sd.message)
  if ecdsa(sd) {
    data_structure
  } else {
    fail @"Invalid ECDSA Signature"
  }
}

pub fn schnorr(sd: SignedData) -> Bool {
  builtin.verify_schnorr_secp256k1_signature(
    sd.verification_key,
    sd.message,
    sd.signature,
  )
}

pub fn convert_schnorr(sd: SignedData) -> Data {
  expect data_structure: Data = builtin.b_data(sd.message)
  if schnorr(sd) {
    data_structure
  } else {
    fail @"Invalid Schnorr Signature"
  }
}

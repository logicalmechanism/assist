use aiken/builtin
use aiken/bytearray
use aiken/hash
use assist/maths

pub fn fiat_shamir_transform(
  gb: ByteArray,
  grb: ByteArray,
  ub: ByteArray,
  // 2 ^ (bits * 8)
  bits: Int,
) -> Int {
  builtin.bytearray_to_integer(
    True,
    gb
      |> bytearray.concat(grb)
      |> bytearray.concat(ub)
      |> hash.sha3_256()
      |> bytearray.take(bits),
  )
}

test simple_transform1() {
  fiat_shamir_transform(#"", #"", #"", 4) == 2818557688
}

test simple_transform2() {
  fiat_shamir_transform(#"", #"", #"", 16) == 223309146619842080235228848104153405026
}

test simple_transform3() {
  fiat_shamir_transform(#"", #"", #"", 32) == 75988164966894747974200307809782762084705920897667750218208675113520516842314
}

pub fn d_log(
  gb: ByteArray,
  zb: ByteArray,
  grb: ByteArray,
  ub: ByteArray,
  bits: Int,
) -> Bool {
  let g: Int = builtin.bytearray_to_integer(True, gb)
  let z: Int = builtin.bytearray_to_integer(True, zb)
  let gr: Int = builtin.bytearray_to_integer(True, grb)
  let u: Int = builtin.bytearray_to_integer(True, ub)
  let c: Int = fiat_shamir_transform(gb, grb, ub, bits)
  let q: Int = maths.large_prime
  maths.powmod(g, z, q) == gr * maths.powmod(u, c, q) % q
}

test discrete_logrithm_2() {
  let q: Int = maths.large_prime
  let bits: Int = 32
  // basic stuff
  let g: Int = 2
  let x: Int = 812747178128235235812747178128235235
  let r: Int = 745734823523523522812747178128235235
  let gb: ByteArray = builtin.integer_to_bytearray(True, 0, g)
  let ub: ByteArray =
    builtin.integer_to_bytearray(True, 0, maths.powmod(g, x, q))
  let grb: ByteArray =
    builtin.integer_to_bytearray(True, 0, maths.powmod(g, r, q))
  // fiat shamir the c
  let c: Int = fiat_shamir_transform(gb, grb, ub, bits)
  // the z
  let z: Int = r + c * x
  let zb: ByteArray = builtin.integer_to_bytearray(True, 0, z)

  d_log(gb, zb, grb, ub, bits)
}

test test_to_int1() {
  let gb: ByteArray =
    #"d2f532e36e758fde1e54f9d8e5e4b7b5b44b5f3a6d6abd40c95c4bdd369e2acb"
  let g1: Int = maths.to_int(gb)
  g1 == 95418926952214592968774173699945756730782106871062434860776122044635538139851
}

test test_to_int2() {
  let gb: ByteArray =
    #"d2f532e36e758fde1e54f9d8e5e4b7b5b44b5f3a6d6abd40c95c4bdd369e2acb"
  let g2: Int = builtin.bytearray_to_integer(True, gb)
  g2 == 95418926952214592968774173699945756730782106871062434860776122044635538139851
}

test test_from_int1() {
  let g: Int =
    95418926952214592968774173699945756730782106871062434860776122044635538139851
  let g1: ByteArray = maths.from_int(g)
  g1 == #"d2f532e36e758fde1e54f9d8e5e4b7b5b44b5f3a6d6abd40c95c4bdd369e2acb"
}

test test_from_int2() {
  let g: Int =
    95418926952214592968774173699945756730782106871062434860776122044635538139851
  let g2: ByteArray = builtin.integer_to_bytearray(True, 0, g)
  g2 == #"d2f532e36e758fde1e54f9d8e5e4b7b5b44b5f3a6d6abd40c95c4bdd369e2acb"
}

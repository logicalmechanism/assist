//// This module incorporates code for various field operations.
////

/// This represents a finite field with a prime characteristic.
pub type FiniteField {
  field_prime: Int,
}

/// Extract the prime characteristic from a finite field.
///
/// ```aiken
/// field.field_prime(finite_field)
/// ```
pub fn field_prime(ff: FiniteField) -> Int {
  ff.field_prime
}

test simple_field_prime() {
  let ff = FiniteField { field_prime: 2 }
  field_prime(ff) == 2
}

/// This represents the individual elements of the finite field.
pub type Field =
  Int

test simple_field1() {
  let f: Field = 2
  f == 2
}

test simple_field2() {
  let f: Field = 2
  let g: Int = f
  g == 2
}

test simple_field3() {
  let f: Field = 2
  let g: Field = f
  f * g == 4
}

test simple_field4() {
  let f: Field = 2
  let g: Field = -f
  -f == g
}

/// Convert an integer into a field element inside a finite field.
///
/// ```aiken
/// field.to_field_element(123, finite_field)
/// ```
pub fn to_field_element(u: Int, ff: FiniteField) -> Field {
  u % field_prime(ff)
}

test simple_to_field() {
  let ff = FiniteField { field_prime: 2 }
  let u = 7
  let f: Field = 1
  to_field_element(u, ff) == f
}

/// Convert a field element into an integer from a finite field.
///
/// ```aiken
/// field.from_field_element(f, finite_field)
/// ```
pub fn from_field_element(f: Field, ff: FiniteField) -> Int {
  f % field_prime(ff)
}

test simple_from_field() {
  let ff = FiniteField { field_prime: 2 }
  let f: Field = 7
  let u = 1
  from_field_element(f, ff) == u
}

/// The zero field element.
pub const zero: Field = 0

/// The one field element.
pub const one: Field = 1

/// The empty finite field that acts as the identity element. The field
/// prime is the one field element.
///
/// This will change into a const at a later time.
///
/// ```aiken
/// field.empty()
/// ```
pub fn empty() -> FiniteField {
  FiniteField { field_prime: 1 }
}

test is_empty_one() {
  field_prime(empty()) == one
}

/// Adds two field elements together in a finite field. The implementation in 
/// Haskell is shown below.
///
/// (+) (F u) (F v) = F $ modulo (u + v) (fieldPrime (mempty :: c))
///
/// ```aiken
/// field.add(f, g, finite_field)
/// ```
pub fn add(f: Field, g: Field, ff: FiniteField) -> Field {
  ( f + g ) % field_prime(ff)
}

test simple_add1() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123, ff)
  let g = to_field_element(321, ff)
  let o = to_field_element(444, ff)
  add(f, g, ff) == o
}

test simple_add2() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123456, ff)
  let g = to_field_element(654321, ff)
  let o = to_field_element(26326, ff)
  add(f, g, ff) == o
}

/// Subtracts two field elements from each other in a finite field. 
/// The implementation in Haskell is shown below.
///
/// (-) (F u) (F v) = F $ modulo (u - v) (fieldPrime (mempty :: c))
///
/// ```aiken
/// field.sub(f, g, finite_field)
/// ```
pub fn sub(f: Field, g: Field, ff: FiniteField) -> Field {
  ( f - g ) % field_prime(ff)
}

test simple_sub1() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123, ff)
  let g = to_field_element(321, ff)
  let o = to_field_element(44005, ff)
  sub(f, g, ff) == o
}

test simple_sub2() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123456, ff)
  let g = to_field_element(654321, ff)
  let o = to_field_element(43774, ff)
  sub(f, g, ff) == o
}

/// Checks for equality of two field elements in a finite field. 
/// The implementation in Haskell is shown below.
///
/// (==) (F u) (F v) = modulo (u - v) (fieldPrime (mempty :: c)) == 0
///
/// ```aiken
/// field.eq(f, g, finite_field)
/// ```
pub fn eq(f: Field, g: Field, ff: FiniteField) -> Bool {
  sub(f, g, ff) == 0
}

test simple_eq() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123, ff)
  eq(f, f, ff)
}

/// Multiply two field elements together in a finite field. The implementation
/// in Haskell is shown below.
///
/// (*) (F u) (F v) = F $ modulo (u * v) (fieldPrime (mempty :: c))
///
/// ```aiken
/// field.mul(f, g, finite_field)
/// ```
pub fn mul(f: Field, g: Field, ff: FiniteField) -> Field {
  f * g % field_prime(ff)
}

test simple_mul1() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123, ff)
  let g = to_field_element(321, ff)
  let o = to_field_element(39483, ff)
  mul(f, g, ff) == o
}

test simple_mul2() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123456, ff)
  let g = to_field_element(654321, ff)
  let o = to_field_element(20154, ff)
  mul(f, g, ff) == o
}

/// Checks if a field element is less than or equal to another field element
/// in a finite field.
///
/// The implementation in Haskell is shown below.
///
/// (<=) (F a) (F b) = modulo a (fieldPrime (mempty :: c)) <= modulo b (fieldPrime (mempty :: c))
///
/// ```aiken
/// field.leq(f, g, finite_field)
/// ```
pub fn leq(f: Field, g: Field, ff: FiniteField) -> Bool {
  let l = f % field_prime(ff)
  let r = g % field_prime(ff)
  l <= r
}

test simple_leq1() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123, ff)
  let g = to_field_element(321, ff)
  leq(f, g, ff) == True
}

test simple_leq2() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123456, ff)
  let g = to_field_element(654321, ff)
  leq(f, g, ff) == True
}

/// Exponentiation of a field element by some integer in a finite field. 
///
/// ```aiken
/// field.exp(f, n, finite_field)
/// ```
pub fn exp(f: Field, n: Int, ff: FiniteField) -> Field {
  if n < 0 {
    exp(f, -n, ff)
  } else if n % 2 == 0 {
    exp(mul(f, f, ff), n / 2, ff)
  } else {
    when n is {
      0 -> one
      1 -> f
      _ -> {
        let r = exp(mul(f, f, ff), n / 2, ff)
        mul(f, r, ff)
      }
    }
  }
}

test simple_exp1() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123, ff)
  let g = 321
  let o = to_field_element(7494, ff)
  exp(f, g, ff) == o
}

test simple_exp2() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123456, ff)
  let g = 654321
  let o = to_field_element(43174, ff)
  exp(f, g, ff) == o
}

// inv (F u) = F (
//   modulo 
//     (snd $ f (u, 1) (fieldPrime (mempty :: c), 0))
//     (fieldPrime (mempty :: c))
//     )
pub fn inv(f: Field, ff: FiniteField) -> Field {
  let (_, snd) = do_inv((f, 1), (field_prime(ff), 0))
  snd % field_prime(ff)
}

fn do_inv(l: (Int, Int), r: (Int, Int)) -> (Int, Int) {
  let (x, y) = l
  let (xp, yp) = r
  if xp == zero {
    l
  } else {
    let q = x / xp
    do_inv((xp, yp), (x - q * xp, y - q * yp))
  }
}

test simple_inv1() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123, ff)
  let o = to_field_element(2875, ff)
  inv(f, ff) == o
}

test simple_inv2() {
  let ff = FiniteField { field_prime: 44203 }
  let f = to_field_element(123456, ff)
  let o = to_field_element(13725, ff)
  inv(f, ff) == o
}
/// This function computes x^y mod p.
// pub fn pow(f: Field, n: Int, ff: FiniteField)

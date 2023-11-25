//// This module incorporates code for various field operations.
////

use assist/field.{Field, FiniteField}

/// A general point along a curve in a field. It is reprensented as a 2-tuple of fields.
pub type Point =
  (Field, Field)

test simple_point() {
  let origin: Point = (field.zero, field.zero)
  origin == origin
}

pub type Curve {
  a_curve_coef: Field,
  b_curve_coef: Field,
  gen: Point,
}

/// The BLS12381 finite field.
///
/// This will be turned into a constant at a later time.
pub fn bls12381Field() -> FiniteField {
  FiniteField {
    field_prime: 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab,
  }
}

/// The BLS12381 curve.
///
/// This will be turned into a constant at a later time.
pub fn bls12381Curve() -> Curve {
  let p: Point =
    (
      field.to_field_element(
        0x17f1d3a73197d7942695638c4fa9ac0fc3688c4f9774b905a14e3a3f171bac586c55e83ff97a1aeffb3af00adb22c6bb,
        bls12381Field(),
      ),
      field.to_field_element(
        0x8b3f481e3aaa0f1a09e30ed741d8ae4fcf5e095d5d00af600db18cb2c04b3edd03cc744a2888ae40caa232946c5e7e1,
        bls12381Field(),
      ),
    )
  Curve {
    a_curve_coef: field.zero,
    b_curve_coef: field.to_field_element(4, bls12381Field()),
    gen: p,
  }
}

/// This function adds two points on an elliptic curve together inside a finite
/// field. The result is another point along the curve.
///
/// ```aiken
/// curve.add(a, b, curve, finite_field)
/// ```
pub fn add(a: Point, b: Point, c: Curve, ff: FiniteField) -> Point {
  let (x1, y1) = a
  let (x2, y2) = b
  if and {
    field.eq(x1, x2, ff),
    field.eq(y1, y2, ff),
  } {
    point_double(a, c, ff)
  } else {
    point_add(a, b, ff)
  }
}

test add_origin_on_curve() {
  let a: Point = (field.zero, field.zero)
  let b: Point = (field.zero, field.zero)
  let c = bls12381Curve()
  let ff = bls12381Field()
  add(a, b, c, ff) == a
}

test add_zero_and_one_on_curve() {
  let a: Point = (field.zero, field.zero)
  let b: Point = (field.one, field.one)
  let c = bls12381Curve()
  let ff = bls12381Field()
  add(a, b, c, ff) == b
}

test add_one_on_curve() {
  let a: Point = (field.one, field.one)
  let b: Point = (field.one, field.one)
  let c = bls12381Curve()
  let ff = bls12381Field()
  let outcome: Point =
    (
      field.to_field_element(7, ff),
      field.to_field_element(
        0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaa98,
        ff,
      ),
    )
  add(a, b, c, ff) == outcome
}

test add_random_points_on_curve() {
  let c = bls12381Curve()
  let ff = bls12381Field()
  let a: Point =
    (field.to_field_element(123, ff), field.to_field_element(321, ff))
  let b: Point =
    (field.to_field_element(44203, ff), field.to_field_element(43948, ff))
  let outcome: Point =
    (
      field.to_field_element(
        0x10ddf4b7f6a4afaefdb7c9f595db3cdee121e8fbd897f2535aa5cf4875a68dbd3b2797b034725f07fdc5b0d2421ff110,
        ff,
      ),
      field.to_field_element(
        0x157143fb0e321a20f8fc3a655bef9e780e5551036b3cfb2161d25b40048888c5c82f2cfe4e776a2dd5923d0a74758ea2,
        ff,
      ),
    )
  add(a, b, c, ff) == outcome
}

/// This function doubles a point on an elliptic curve inside a finite field.
/// It is used when adding two points together when both points equal.
fn point_double(a: Point, c: Curve, ff: FiniteField) -> Point {
  let (x, y) = a
  let origin: Point = (field.zero, field.zero)
  if (x, y) == origin {
    origin
  } else {
    // method for point doubling
    // xx = x * x
    // s  = (xx + xx + xx + aCurveCoef) * inv (y + y)
    // x3 = s * s - x - x
    // y3 = s * (x - x3) - y
    let xx = field.mul(x, x, ff)
    let yy = field.mul(y, y, ff)
    let s =
      field.add(xx, xx, ff)
        |> field.add(xx, ff)
        |> field.add(c.a_curve_coef, ff)
        |> field.mul(field.inv(yy, ff), ff)
    let x3 = field.mul(s, s, ff) |> field.sub(x, ff) |> field.sub(x, ff)
    let y3 = field.mul(s, field.sub(x, x3, ff), ff) |> field.sub(y, ff)
    (x3, y3)
  }
}

/// This function adds two distinct points on an elliptic curve inside a finite
/// field. The result is another point along the curve.
fn point_add(a: Point, b: Point, ff: FiniteField) -> Point {
  let origin: Point = (field.zero, field.zero)
  if a == origin {
    b
  } else if b == origin {
    a
  } else {
    let (x1, y1) = a
    let (x2, y2) = b
    if field.eq(x1, x2, ff) {
      origin
    } else {
      // the method for point adding
      // s = (y1 - y2) * inv (x1 - x2)
      // x3 = s * s - x1 - x2
      // y3 = s * (x1 - x3) - y1
      let s =
        field.mul(
          field.sub(y1, y2, ff),
          field.inv(field.sub(x1, x2, ff), ff),
          ff,
        )
      let x3 = field.mul(s, s, ff) |> field.sub(x1, ff) |> field.sub(x2, ff)
      let y3 = field.mul(s, field.sub(x1, x3, ff), ff) |> field.sub(y1, ff)
      (x3, y3)
    }
  }
}

/// This function multiplies two points together on a elliptic curve in a 
/// finite field. The result is another point along the curve.
///
/// ```aiken
/// curve.mul(a, number, curve, finite_field)
/// ```
pub fn mul(a: Point, n: Int, c: Curve, ff: FiniteField) -> Point {
  let (x, y) = a
  if n < 0 {
    mul((x, -y), -n, c, ff)
  } else if n % 2 == 0 {
    mul(point_double(a, c, ff), n / 2, c, ff)
  } else {
    when n is {
      1 -> a
      _ -> {
        let b = mul(point_double(a, c, ff), n / 2, c, ff)
        point_add(a, b, ff)
      }
    }
  }
}

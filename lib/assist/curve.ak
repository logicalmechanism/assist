//// This module incorporates code for various field operations.
////

use assist/field.{Field, FiniteField}

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
pub fn bls12381Field() -> FiniteField {
  FiniteField {
    field_prime: 0x1a0111ea397fe69a4b1ba7b6434bacd764774b84f38512bf6730d2a0f6b0f6241eabfffeb153ffffb9feffffffffaaab,
  }
}

/// The BLS12381 curve.
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

// This function adds two points on an elliptic curve.
// addPoints :: Curve c => Point c -> Point c -> Point c
pub fn add_points(a: Point, b: Point, c: Curve, ff: FiniteField) -> Point {
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

// This function doubles a point on an elliptic curve.
// pointDouble :: Curve c => Point c -> Point c
fn point_double(a: Point, c: Curve, ff: FiniteField) -> Point {
  let (x, y) = a
  let origin: Point = (field.zero, field.zero)
  if (x, y) == origin {
    origin
  } else {
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

// This function adds two distinct points on an elliptic curve.
// pointAdd :: Curve c => Point c -> Point c -> Point c
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

// pointMul :: Curve c => Point c -> Integer -> Point c
pub fn point_mul(a: Point, n: Int, c: Curve, ff: FiniteField) -> Point {
  let (x, y) = a
  if n < 0 {
    point_mul((x, -y), -n, c, ff)
  } else if n % 2 == 0 {
    point_mul(point_double(a, c, ff), n / 2, c, ff)
  } else {
    when n is {
      1 -> a
      _ -> {
        let b = point_mul(point_double(a, c, ff), n / 2, c, ff)
        point_add(a, b, ff)
      }
    }
  }
}

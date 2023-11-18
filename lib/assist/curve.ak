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

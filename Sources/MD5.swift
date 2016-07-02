/*
 * A JavaScript implementation of the RSA Data Security, Inc. MD5 Message
 * Digest Algorithm, as defined in RFC 1321.
 * Version 2.2 Copyright (C) Paul Johnston 1999 - 2009
 * Other contributors: Greg Holt, Andrew Kepert, Ydnar, Lostinet
 * Distributed under the BSD License
 * See http://pajhome.org.uk/crypt/md5 for more info.
 */

//
//  MD5.swift
//  SwiftHash 
//
//  Created by Khoa Pham
//  Copyright © 2016 Fantageek. All rights reserved.
//

import Foundation

public func hex_md5(input: String) -> String {
  return rstr2hex(rstr_md5(str2rstr_utf8(input)))
}

func str2rstr_utf8(input: String) -> [CUnsignedChar] {
  return Array(input.utf8)
}

func rstr2tr(input: [CUnsignedChar]) -> String {
  var output: String = ""

  input.forEach {
    output.append(UnicodeScalar($0))
  }

  return output
}

/*
 * Convert a raw string to a hex string
 */
func rstr2hex(input: [CUnsignedChar]) -> String {
  let hexTab: [Character] = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"]
  var output: [Character] = []

  for i in 0..<input.count {
    let x = input[i]
    let value1 = hexTab[Int((x >> 4) & 0x0F)]
    let value2 = hexTab[Int(Int32(x) & 0x0F)]

    output.append(value1)
    output.append(value2)
  }

  return String(output)
}

/*
 * Convert a raw string to an array of little-endian words
 * Characters >255 have their high-byte silently ignored.
 */
func rstr2binl(input: [CUnsignedChar]) -> [Int32] {
  var output: [Int: Int32] = [:]

  for i in 0.stride(to: input.count * 8, by: 8) {
    let value: Int32 = (Int32(input[i/8]) & 0xFF) << (Int32(i) % 32)

    output[i >> 5] = (output[i >> 5] ?? 0) | value
  }

  return output.map { $1 }
}

/*
 * Convert an array of little-endian words to a string
 */
func binl2rstr(input: [Int32]) -> [CUnsignedChar] {
  var output: [CUnsignedChar] = []

  for i in 0.stride(to: input.count * 32, by: 8) {
    // [i>>5] >>>
    let value: Int32 = zeroFillRightShift(input[i>>5], Int32(i % 32)) & 0xFF
    output.append(CUnsignedChar(value))
  }

  return output
}

/*
 * Calculate the MD5 of a raw string
 */
func rstr_md5(input: [CUnsignedChar]) -> [CUnsignedChar] {
  return binl2rstr(binl_md5(rstr2binl(input), input.count * 8))
}

/*
 * Add integers, wrapping at 2^32. This uses 16-bit operations internally
 * to work around bugs in some JS interpreters.
 */
func safe_add(x: Int32, _ y: Int32) -> Int32 {
  let lsw = (x & 0xFFFF) + (y & 0xFFFF)
  let msw = (x >> 16) + (y >> 16) + (lsw >> 16)
  return (msw << 16) | (lsw & 0xFFFF)
}

/*
 * Bitwise rotate a 32-bit number to the left.
 */
func bit_rol(num: Int32, _ cnt: Int32) -> Int32 {
  // num >>>
  return (num << cnt) | zeroFillRightShift(num, (32 - cnt))
}


/*
 * These funcs implement the four basic operations the algorithm uses.
 */
func md5_cmn(q: Int32, _ a: Int32, _ b: Int32, _ x: Int32, _ s: Int32, _ t: Int32) -> Int32 {
  return safe_add(bit_rol(safe_add(safe_add(a, q), safe_add(x, t)), s), b)
}

func md5_ff(a: Int32, _ b: Int32, _ c: Int32, _ d: Int32, _ x: Int32, _ s: Int32, _ t: Int32) -> Int32 {
  return md5_cmn((b & c) | ((~b) & d), a, b, x, s, t)
}

func md5_gg(a: Int32, _ b: Int32, _ c: Int32, _ d: Int32, _ x: Int32, _ s: Int32, _ t: Int32) -> Int32 {
  return md5_cmn((b & d) | (c & (~d)), a, b, x, s, t)
}

func md5_hh(a: Int32, _ b: Int32, _ c: Int32, _ d: Int32, _ x: Int32, _ s: Int32, _ t: Int32) -> Int32 {
  return md5_cmn(b ^ c ^ d, a, b, x, s, t)
}

func md5_ii(a: Int32, _ b: Int32, _ c: Int32, _ d: Int32, _ x: Int32, _ s: Int32, _ t: Int32) -> Int32 {
  return md5_cmn(c ^ (b | (~d)), a, b, x, s, t)
}


/*
 * Calculate the MD5 of an array of little-endian words, and a bit length.
 */
func binl_md5(input: [Int32], _ len: Int) -> [Int32] {
  /* append padding */

  var x: [Int: Int32] = [:]
  for (index, value) in input.enumerate() {
    x[index] = value
  }

  let value: Int32 = 0x80 << Int32((len) % 32)
  x[len >> 5] = (x[len >> 5] ?? 0) | value

  // >>> 9
  let index = (((len + 64) >> 9) << 4) + 14
  x[index] = (x[index] ?? 0) | Int32(len)

  var a: Int32 =  1732584193
  var b: Int32 = -271733879
  var c: Int32 = -1732584194
  var d: Int32 =  271733878

  for i in 0.stride(to: length(x), by: 16) {
    let olda: Int32 = a
    let oldb: Int32 = b
    let oldc: Int32 = c
    let oldd: Int32 = d

    a = md5_ff(a, b, c, d, x[i + 0] ?? 0, 7 , -680876936)
    d = md5_ff(d, a, b, c, x[i + 1] ?? 0, 12, -389564586)
    c = md5_ff(c, d, a, b, x[i + 2] ?? 0, 17,  606105819)
    b = md5_ff(b, c, d, a, x[i + 3] ?? 0, 22, -1044525330)
    a = md5_ff(a, b, c, d, x[i + 4] ?? 0, 7 , -176418897)
    d = md5_ff(d, a, b, c, x[i + 5] ?? 0, 12,  1200080426)
    c = md5_ff(c, d, a, b, x[i + 6] ?? 0, 17, -1473231341)
    b = md5_ff(b, c, d, a, x[i + 7] ?? 0, 22, -45705983)
    a = md5_ff(a, b, c, d, x[i + 8] ?? 0, 7 ,  1770035416)
    d = md5_ff(d, a, b, c, x[i + 9] ?? 0, 12, -1958414417)
    c = md5_ff(c, d, a, b, x[i + 10] ?? 0, 17, -42063)
    b = md5_ff(b, c, d, a, x[i + 11] ?? 0, 22, -1990404162)
    a = md5_ff(a, b, c, d, x[i + 12] ?? 0, 7 ,  1804603682)
    d = md5_ff(d, a, b, c, x[i + 13] ?? 0, 12, -40341101)
    c = md5_ff(c, d, a, b, x[i + 14] ?? 0, 17, -1502002290)
    b = md5_ff(b, c, d, a, x[i + 15] ?? 0, 22,  1236535329)

    a = md5_gg(a, b, c, d, x[i + 1] ?? 0, 5 , -165796510)
    d = md5_gg(d, a, b, c, x[i + 6] ?? 0, 9 , -1069501632)
    c = md5_gg(c, d, a, b, x[i + 11] ?? 0, 14,  643717713)
    b = md5_gg(b, c, d, a, x[i + 0] ?? 0, 20, -373897302)
    a = md5_gg(a, b, c, d, x[i + 5] ?? 0, 5 , -701558691)
    d = md5_gg(d, a, b, c, x[i + 10] ?? 0, 9 ,  38016083)
    c = md5_gg(c, d, a, b, x[i + 15] ?? 0, 14, -660478335)
    b = md5_gg(b, c, d, a, x[i + 4] ?? 0, 20, -405537848)
    a = md5_gg(a, b, c, d, x[i + 9] ?? 0, 5 ,  568446438)
    d = md5_gg(d, a, b, c, x[i + 14] ?? 0, 9 , -1019803690)
    c = md5_gg(c, d, a, b, x[i + 3] ?? 0, 14, -187363961)
    b = md5_gg(b, c, d, a, x[i + 8] ?? 0, 20,  1163531501)
    a = md5_gg(a, b, c, d, x[i + 13] ?? 0, 5 , -1444681467)
    d = md5_gg(d, a, b, c, x[i + 2] ?? 0, 9 , -51403784)
    c = md5_gg(c, d, a, b, x[i + 7] ?? 0, 14,  1735328473)
    b = md5_gg(b, c, d, a, x[i + 12] ?? 0, 20, -1926607734)

    a = md5_hh(a, b, c, d, x[i + 5] ?? 0, 4 , -378558)
    d = md5_hh(d, a, b, c, x[i + 8] ?? 0, 11, -2022574463)
    c = md5_hh(c, d, a, b, x[i + 11] ?? 0, 16,  1839030562)
    b = md5_hh(b, c, d, a, x[i + 14] ?? 0, 23, -35309556)
    a = md5_hh(a, b, c, d, x[i + 1] ?? 0, 4 , -1530992060)
    d = md5_hh(d, a, b, c, x[i + 4] ?? 0, 11,  1272893353)
    c = md5_hh(c, d, a, b, x[i + 7] ?? 0, 16, -155497632)
    b = md5_hh(b, c, d, a, x[i + 10] ?? 0, 23, -1094730640)
    a = md5_hh(a, b, c, d, x[i + 13] ?? 0, 4 ,  681279174)
    d = md5_hh(d, a, b, c, x[i + 0] ?? 0, 11, -358537222)
    c = md5_hh(c, d, a, b, x[i + 3] ?? 0, 16, -722521979)
    b = md5_hh(b, c, d, a, x[i + 6] ?? 0, 23,  76029189)
    a = md5_hh(a, b, c, d, x[i + 9] ?? 0, 4 , -640364487)
    d = md5_hh(d, a, b, c, x[i + 12] ?? 0, 11, -421815835)
    c = md5_hh(c, d, a, b, x[i + 15] ?? 0, 16,  530742520)
    b = md5_hh(b, c, d, a, x[i + 2] ?? 0, 23, -995338651)

    a = md5_ii(a, b, c, d, x[i + 0] ?? 0, 6 , -198630844)
    d = md5_ii(d, a, b, c, x[i + 7] ?? 0, 10,  1126891415)
    c = md5_ii(c, d, a, b, x[i + 14] ?? 0, 15, -1416354905)
    b = md5_ii(b, c, d, a, x[i + 5] ?? 0, 21, -57434055)
    a = md5_ii(a, b, c, d, x[i + 12] ?? 0, 6 ,  1700485571)
    d = md5_ii(d, a, b, c, x[i + 3] ?? 0, 10, -1894986606)
    c = md5_ii(c, d, a, b, x[i + 10] ?? 0, 15, -1051523)
    b = md5_ii(b, c, d, a, x[i + 1] ?? 0, 21, -2054922799)
    a = md5_ii(a, b, c, d, x[i + 8] ?? 0, 6 ,  1873313359)
    d = md5_ii(d, a, b, c, x[i + 15] ?? 0, 10, -30611744)
    c = md5_ii(c, d, a, b, x[i + 6] ?? 0, 15, -1560198380)
    b = md5_ii(b, c, d, a, x[i + 13] ?? 0, 21,  1309151649)
    a = md5_ii(a, b, c, d, x[i + 4] ?? 0, 6 , -145523070)
    d = md5_ii(d, a, b, c, x[i + 11] ?? 0, 10, -1120210379)
    c = md5_ii(c, d, a, b, x[i + 2] ?? 0, 15,  718787259)
    b = md5_ii(b, c, d, a, x[i + 9] ?? 0, 21, -343485551)

    a = safe_add(a, olda)
    b = safe_add(b, oldb)
    c = safe_add(c, oldc)
    d = safe_add(d, oldd)
  }

  return [a, b, c, d]
}

// MARK: - Helper
func length(dictionary: [Int: Int32]) -> Int {
  return (dictionary.keys.maxElement() ?? 0) + 1
}

func zeroFillRightShift(num: Int32, _ count: Int32) -> Int32 {
  let value = UInt32(bitPattern: num) >> UInt32(bitPattern: count)
  return Int32(bitPattern: value)
}
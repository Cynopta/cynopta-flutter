//
//  TrustNative.h
//  CynoptaKit
//
//  Created by Max O on 02/11/2026.
//  Copyright © 2026 Anagog Ltd. All rights reserved.
//

#ifndef CynoptaKit_TrustNative_h
#define CynoptaKit_TrustNative_h

#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

// The C side of CynoptaMetricsKit's trust checks: the hook checks (TrustHooks), and zlib for the attestation payload
// (TrustAttestation). Swift can't strip a pointer's authentication code (ptrauth_strip is a Clang builtin), which arm64e
// needs before dladdr or a read of the code, and Apple's Compression framework writes raw deflate, not zlib's format.
// Not API. It lives here, public like TelephonySafeBridge, because Swift sees C only through a framework's umbrella
// header and CynoptaMetricsKit has none.

/// How many functions the hook checks look at: open, stat, sysctl, dlsym, ptrace and _dyld_get_image_name, in this
/// order.
int CynoptaTrustHookTargetCount(void);

/// The function's C name, e.g. "open". NULL for an index out of range.
const char * _Nullable CynoptaTrustHookTargetName(int index);

/// Copies up to `capacity` instruction words from the start of the function dlsym finds, after dladdr has placed it
/// inside a loaded image, and returns how many it copied. 0 when it can't be found or read, and always on anything
/// but arm64.
int CynoptaTrustHookTargetPrologue(int index, uint32_t * _Nonnull words, int capacity);

/// The image dladdr names for the function dlsym finds, or NULL when it's in no image. False for an index out of range
/// or a function dlsym can't find.
bool CynoptaTrustHookTargetImage(int index, const char * _Nullable * _Nonnull path);

/// The most `CynoptaTrustZlibCompress` can write for `length` bytes.
size_t CynoptaTrustZlibBound(size_t length);

/// zlib's format at its best compression, as Java's Deflater(BEST_COMPRESSION) writes it: header 78 DA, deflate,
/// Adler-32. Returns the compressed length, or 0 when `capacity` is too small or zlib fails.
size_t CynoptaTrustZlibCompress(const uint8_t * _Nonnull source, size_t length, uint8_t * _Nonnull destination, size_t capacity);

// MARK: Sealed channel (Android's nativeSealPacket and cf0, cynopta-anti-debug.c)

/// Seals one evaluation for the Flutter channel the way Android's SDK does, bit for bit, so the plugin's Dart opens it
/// with the same code: score, realness and bot risk as units (0-10000, 0xFFFF for -1), Android's class code (0-10), the
/// caller's nonce and a SipHash-2-4 tag, keyed with this launch's random key and the 16-byte app salt. Writes 24 bytes,
/// c0, c1 and the tag, little-endian. As on Android, an attached debugger or a hook on this function's or cf0's first
/// instructions vetoes the values (score 0, bot risk 1), and a hook also spoils the key, so cf0 rejects the packet.
void CynoptaTrustSealPacket(uint64_t nonce, const uint8_t * _Nonnull salt, int scoreUnits, int realnessUnits,
                          int botUnits, int classCode, uint8_t * _Nonnull packet);

/// Android's cf0, under its name: the Flutter plugin's Dart finds it with DynamicLibrary.process(). Opens a packet for
/// `nonce` with the salt's two halves (s0, s1, little-endian); 0 when the tag, the nonce or the marker don't match, or
/// either function is hooked. Otherwise the units and class code (bits 0-55) with bit 62 set.
uint64_t cf0(uint64_t nonce, uint64_t c0, uint64_t c1, uint64_t tag, uint64_t s0, uint64_t s1);

/// Android's inline-hook test on a function's first instruction words (the hooking checks' rule, one copy for the
/// Swift checks and the seal): past a landing pad (PACIBSP or BTI c), a B, a BR Xn, or LDR X16/X17, #8 followed by BR
/// or BLR through it (Frida, Substrate, Dobby). Android's ADRP + ADD + BR form isn't matched.
bool CynoptaTrustIsInlineHook(const uint32_t * _Nullable words, int count);

/// Whether the seal or cf0 starts with an inline hook (the hooking checks' rule). Always false off arm64.
bool CynoptaTrustSealHooked(void);

#endif

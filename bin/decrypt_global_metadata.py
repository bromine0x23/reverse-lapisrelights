#!/usr/bin/env python3
# decrypt_global_metadata.py - 从 `game.dat` 恢复 IL2CPP 的 `global-metadata.dat`
#
# 等效于 toolkit-java 的 xyz.bromine0x23.lapisrelights.DecryptGlobalMetadata
# （算法见 xyz.bromine0x23.lapisrelights.support.LapisGlobalMetadata）。
#
# 用法: python decrypt_global_metadata.py <game.dat> [global-metadata.dat]
#
# 第二个参数省略时，输出到 `game.dat` 同目录下的 `global-metadata.dat`。
#
# 解密分两步（与 Java 版本一致）:
# 1. 按 game.dat 自身的头部定位并 RC4 解密整个元数据；
# 2. 还原 `string` 区段的逐字节差分编码。

import argparse
import os
import sys

# IL2CPP `global-metadata.dat` 文件头 signature
GLOBAL_METADATA_SIGNATURE = 0xFAB11BAF

# 用于定位大小字段和密钥字段的标记值
SIZE_FLAG = 0xBCFAF088
STEP_FLAG = 0x567FE814

# 标记位置之后到数据区之间的固定头部长度
HEADER_SIZE = 0x10

# global-metadata.dat 头部中 `string` 区段的偏移和长度（Il2CppGlobalMetadataHeader）
STRING_OFFSET_POSITION = 0x18
STRING_COUNT_POSITION = 0x1C

MAX_UNSIGNED_INT32 = 0xFFFFFFFF


def read_sint32(data, position):
    """读取小端有符号 32 位整数，越界时抛出异常（与 Java 的数组访问一致）。"""
    if position < 0 or position + 4 > len(data):
        raise ValueError(f'read out of range: position = {position}, size = {len(data)}')
    value = int.from_bytes(data[position:position + 4], 'little', signed=True)
    return value


def read_uint32(data, position):
    """读取小端无符号 32 位整数。"""
    return read_sint32(data, position) & MAX_UNSIGNED_INT32


def find_position(data, flag):
    """按记录链（标记 + step 字段）遍历，查找标记所在的偏移，找不到返回 -1。"""
    position = 0
    step = 0
    while position < len(data):
        current = read_uint32(data, position)
        if current == flag:
            return position
        step = read_sint32(data, position + 4)
        if step < 0:
            raise ValueError(f'negative record step at position {position}: {step}')
        position = position + step + HEADER_SIZE
    return -1


def rc4_keystream_xor(key, data):
    """RC4 加解密（与 BouncyCastle RC4Engine 等价）。"""
    state = list(range(256))
    j = 0
    for i in range(256):
        j = (j + state[i] + key[i % len(key)]) & 0xFF
        state[i], state[j] = state[j], state[i]

    output = bytearray(len(data))
    i = 0
    j = 0
    for index, byte in enumerate(data):
        i = (i + 1) & 0xFF
        j = (j + state[i]) & 0xFF
        state[i], state[j] = state[j], state[i]
        output[index] = byte ^ state[(state[i] + state[j]) & 0xFF]
    return bytes(output)


def decrypt_global_metadata(ciphertext, verbose=False):
    """第一步: 用 game.dat 自身的头部定位并 RC4 解密，得到未还原字符串的元数据。"""
    size_position = find_position(ciphertext, SIZE_FLAG)
    if size_position < 0:
        raise ValueError(f'size flag not found: 0x{SIZE_FLAG:08X}')
    size = read_sint32(ciphertext, size_position + 4)
    if size < 0:
        raise ValueError(f'invalid size: {size}')
    if verbose:
        print(f'game.dat size = {size:8x}')

    step_position = find_position(ciphertext, STEP_FLAG)
    if step_position < 0:
        raise ValueError(f'step flag not found: 0x{STEP_FLAG:08X}')
    step = read_sint32(ciphertext, step_position + 4)
    if step <= 0:
        raise ValueError(f'invalid step: {step}')
    if verbose:
        print(f'game.dat step = {step:8x}')

    key = bytes(ciphertext[step_position + HEADER_SIZE + i % step] for i in range(step))

    data = ciphertext[size_position + HEADER_SIZE:]
    if len(data) > size:
        # Java 版本在等长的输出缓冲区上调用 RC4Engine.processBytes 会抛
        # ArrayIndexOutOfBoundsException，这里按 size 截断。
        data = data[:size]

    plaintext = rc4_keystream_xor(key, data)
    if len(plaintext) < size:
        # 未覆盖的部分保持为零（与 Java 版本预分配的 byte[] 一致）
        plaintext += bytes(size - len(plaintext))
    return plaintext


def decrypt_strings(metadata):
    """第二步: 还原 `string` 区段的逐字节差分编码（与 Java 的 decryptStrings 一致）。

    字符串以 0 结尾依次排列: 每个字符与上一个已还原字符异或，
    字符串首字符则与 `区段内偏移 % 255` 异或。原地修改 `metadata`。
    """
    string_offset = read_sint32(metadata, STRING_OFFSET_POSITION)
    string_count = read_sint32(metadata, STRING_COUNT_POSITION)  # 区段字节长度
    if string_offset < 0 or string_count < 0:
        raise ValueError(f'invalid string section: offset = {string_offset}, count = {string_count}')
    end = string_offset + string_count
    if end > len(metadata):
        raise ValueError(f'string section out of range: end = {end}, size = {len(metadata)}')

    string_index = 0
    while string_index < string_count:
        pointer = string_offset + string_index
        value = string_index % 255
        while True:
            value ^= metadata[pointer]
            metadata[pointer] = value
            pointer += 1
            if value == 0:
                break
            if pointer >= end:
                raise ValueError(f'unterminated string at index {string_index}')
        string_index = pointer - string_offset


def decrypt(ciphertext, verbose=False):
    """从 game.dat 恢复为 global-metadata.dat。"""
    metadata = bytearray(decrypt_global_metadata(ciphertext, verbose))
    decrypt_strings(metadata)
    return bytes(metadata)


def main(argv=None):
    parser = argparse.ArgumentParser(
        description='将 game.dat 中的 global-metadata.dat 解密出来')
    parser.add_argument('input', metavar='game.dat',
        help='加密的 game.dat')
    parser.add_argument('output', metavar='global-metadata.dat', nargs='?',
        help='输出路径（默认: game.dat 同目录下的 global-metadata.dat）')
    parser.add_argument('-v', '--verbose', action='store_true',
        help='显示解析到的 size 和 step')
    parser.add_argument('--no-decode-strings', action='store_true',
        help='只做 RC4 解密，不还原 string 区段（调试用）')
    arguments = parser.parse_args(argv)

    input_path = arguments.input
    if arguments.output is not None:
        output_path = arguments.output
    else:
        output_path = os.path.join(os.path.dirname(os.path.abspath(input_path)),
            'global-metadata.dat')

    if not os.path.isfile(input_path):
        print(f'Input file does not exist: {os.path.abspath(input_path)}', file=sys.stderr)
        return 1

    with open(input_path, 'rb') as streamfile:
        ciphertext = streamfile.read()

    try:
        if arguments.no_decode_strings:
            plaintext = decrypt_global_metadata(ciphertext, arguments.verbose)
        else:
            plaintext = decrypt(ciphertext, arguments.verbose)
    except ValueError as error:
        print(f'Failed to decrypt {os.path.abspath(input_path)}: {error}', file=sys.stderr)
        return 1

    signature = int.from_bytes(plaintext[:4], 'little', signed=False)
    if len(plaintext) < 4 or signature != GLOBAL_METADATA_SIGNATURE:
        print(f'Decrypted data is not a valid global-metadata.dat '
            f'(signature = 0x{signature:08X})', file=sys.stderr)
        return 1

    parent = os.path.dirname(os.path.abspath(output_path))
    if parent:
        os.makedirs(parent, exist_ok=True)
    with open(output_path, 'wb') as streamfile:
        streamfile.write(plaintext)

    print(f'Decrypted {os.path.abspath(input_path)} -> {os.path.abspath(output_path)} '
        f'({len(plaintext):,} bytes)')
    return 0


if __name__ == '__main__':
    sys.exit(main())

// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LCGStream
//  来源：Il2CppDumper 元数据 + 反汇编（0x1331770 起）
// =============================================================================

using System;
using System.IO;

/// <summary>对底层流做 3 路 LCG 异或加密的只读流。</summary>
public class LCGStream : Stream
{
    private Stream input;
    private uint key1;
    private uint key2;
    private uint key3;

    public LCGStream(Stream input, uint key1, uint key2, uint key3)
    {
        this.input = input;
        this.key1 = key1;
        this.key2 = key2;
        this.key3 = key3;
    }

    public override long Position
    {
        get { return input.Position; }
        set { throw new NotSupportedException(); }
    }

    public override long Length
    {
        get { return input.Length; }
    }

    public override bool CanWrite
    {
        get { return false; }
    }

    public override bool CanSeek
    {
        get { return false; }
    }

    public override bool CanRead
    {
        get { return input.CanRead; }
    }

    public override void Flush()
    {
        throw new NotSupportedException();
    }

    public override int Read(byte[] buffer, int offset, int count)
    {
        int read = input.Read(buffer, offset, count);
        int length = read + offset;

        for (int i = 0; i < length; i++)
        {
            buffer[i] ^= (byte)((key1 ^ key2 ^ key3) >> 24);
            key1 = key1 * 0x343FD + 0x269EC3;
            key2 = key2 * 0x343FD + 0x269EC3;
            key3 = key3 * 0x343FD + 0x269EC3;
        }

        return read;
    }

    public override long Seek(long offset, SeekOrigin origin)
    {
        throw new NotSupportedException();
    }

    public override void SetLength(long value)
    {
        throw new NotSupportedException();
    }

    public override void Write(byte[] buffer, int offset, int count)
    {
        throw new NotSupportedException();
    }
}

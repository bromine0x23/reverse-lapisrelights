// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.Version
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;

namespace Jackpot
{
    public class Version
    {
        private readonly Tuple<int, int, int, int> versionTuple;
        private readonly string versionString;

        public int Major { get { return versionTuple.Item1; } }
        public int Minor { get { return versionTuple.Item2; } }
        public int Revision { get { return versionTuple.Item3; } }
        public int Build { get { return versionTuple.Item4; } }

        // RVA: 0x16BDB20
        public static Version Of(string versionString)
        {
            string[] array = versionString.Split(new string[] { ".", ":" }, StringSplitOptions.None);
            int major = 0;
            if (array.Length >= 1)
            {
                int.TryParse(array[0], out major);
            }

            if (array.Length < 2)
            {
                return new Version(major);
            }

            int minor = 0;
            int.TryParse(array[1], out minor);
            if (array.Length < 3)
            {
                return new Version(major, minor);
            }

            int revision = 0;
            int.TryParse(array[2], out revision);
            if (array.Length < 4)
            {
                return new Version(major, minor, revision);
            }

            int build = 0;
            int.TryParse(array[3], out build);
            return new Version(major, minor, revision, build);
        }

        // RVA: 0x16BE178
        public override bool Equals(object obj)
        {
            if (obj == null)
            {
                return false;
            }

            if (obj is Version)
            {
                return versionTuple.Equals(((Version)obj).versionTuple);
            }

            if (obj.GetType() == typeof(string))
            {
                Version version = Of((string)obj);
                if (version != null)
                {
                    return versionTuple.Equals(version.versionTuple);
                }
            }

            return false;
        }

        // RVA: 0x16BE2F4
        public static bool op_LessThan(Version left, Version right)
        {
            return left.versionTuple.CompareTo(right.versionTuple) < 0;
        }

        // RVA: 0x16BE3C8
        public static bool op_LessThanOrEqual(Version left, Version right)
        {
            return left.versionTuple.CompareTo(right.versionTuple) <= 0;
        }

        // RVA: 0x16BE4A0
        public static bool op_GreaterThan(Version left, Version right)
        {
            return left.versionTuple.CompareTo(right.versionTuple) > 0;
        }

        // RVA: 0x16BE578
        public static bool op_GreaterThanOrEqual(Version left, Version right)
        {
            return left.versionTuple.CompareTo(right.versionTuple) >= 0;
        }

        // RVA: 0x16BE2D8
        public static bool op_Equality(Version left, Version right)
        {
            return left.Equals(right);
        }

        // RVA: 0x16BE650
        public static bool op_Inequality(Version left, Version right)
        {
            return !left.Equals(right);
        }

        // RVA: 0x16BE67C
        public override int GetHashCode()
        {
            return ToString().GetHashCode();
        }

        // RVA: 0x16BE6A8
        public override string ToString()
        {
            return versionString;
        }

        // RVA: 0x16BDD60
        protected Version(int major)
            : this(major, 0, 0, 0, string.Format("{0}", major))
        {
        }

        // RVA: 0x16BDDFC
        protected Version(int major, int minor)
            : this(major, minor, 0, 0, string.Format("{0}.{1}", major, minor))
        {
        }

        // RVA: 0x16BDEBC
        protected Version(int major, int minor, int revision)
            : this(major, minor, revision, 0, string.Format("{0}.{1}.{2}", major, minor, revision))
        {
        }

        // RVA: 0x16BDFA8
        protected Version(int major, int minor, int revision, int build)
            : this(major, minor, revision, build, string.Format("{0}.{1}.{2}.{3}", major, minor, revision, build))
        {
        }

        // RVA: 0x16BE6B0
        private Version(int major, int minor, int revision, int build, string versionString)
        {
            versionTuple = Tuple.Create(major, minor, revision, build);
            this.versionString = versionString;
        }
    }
}

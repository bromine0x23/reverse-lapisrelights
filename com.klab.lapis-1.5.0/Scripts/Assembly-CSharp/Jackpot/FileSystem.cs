// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.FileSystem
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections;
using System.Collections.Generic;
using LuaInterface;
using UnityEngine;
using UnityEngine.Events;
using UnityEngine.EventSystems;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace Jackpot
{
    public class FileSystem
    {
        private const string FileSystemPoolKey = "Jackpot.FileSystemPool";
        private const string DefaultFileSystemId = "defaultfs";
        private static readonly object LifecycleLock;
        private static readonly Dictionary<string, FileSystem> pool;
        public static readonly string DefaultTag;
        private static readonly ILogger Logger;
        private static readonly string TocFileName;
        private static readonly string backupFileName;
        private readonly string id;
        private readonly string basePath;
        private readonly string tocFilePath;
        private readonly string backupFilePath;
        private readonly ReaderWriterLockSlim slim;
        private bool disposed;
        private FileSystemToc toc;
        private StreamWriter streamWriter;
        public static FileSystem Default { get { return Create(DefaultFileSystemId); } }
        public string Id { get { return id; } }
        public string BasePath { get { return basePath; } }
        public string TocFilePath { get { return tocFilePath; } }
        // RVA: 0x19E9BAC
        public static FileSystem Create(string id)
        {
                        lock (LifecycleLock)
                        {
                            if (!pool.ContainsKey(id) || pool[id] == null)
                            {
                                pool.Add(id, new FileSystem(id));
                            }

                            return pool[id];
                        }
        }

        // RVA: 0x19E9F94
        public static void DeleteOnPool(string id)
        {
                        lock (LifecycleLock)
                        {
                            if (pool.ContainsKey(id))
                            {
                                pool.Remove(id);
                            }
                        }
        }

        // RVA: 0x19EA0F8
        public string get_Id()
        {
            return id;
        }

        // RVA: 0x19EA100
        public string get_BasePath()
        {
            return basePath;
        }

        // RVA: 0x19EA108
        public string get_TocFilePath()
        {
            return tocFilePath;
        }

        // RVA: 0x19E9DD0
        public FileSystem(string id)
        {
                        this.id = id;
                        basePath = Platform.GetPersistentDirectoryPath(id);
                        tocFilePath = FullPathCore(TocFileName);
                        backupFilePath = FullPathCore(backupFileName);
                        slim = new ReaderWriterLockSlim();
                        disposed = false;
                        RefreshToc();
                        bool flag = File.Exists(tocFilePath);
                        streamWriter = new StreamWriter(tocFilePath, append: true);
                        if (!flag)
                        {
                            AppendText(string.Format("{0},{1}", FileSystemEntry.CurrentFormat, FileSystemEntry.CurrentFormatColumn));
                        }
        }

        // RVA: 0x19EA810
        ~FileSystem()
        {
                        Dispose(false);
        }

        // RVA: 0x19EA884
        public void Dispose()
        {
                        Dispose(true);
                        GC.SuppressFinalize(this);
        }

        // RVA: 0x19EA900
        public int Version(string path)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            if (toc.Contains(path))
                            {
                                return toc[path].Version;
                            }

                            Logger.Error("[{0}] Cannot find entry. path: {1}", new object[2] { id, path });
                            return -1;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EADCC
        public string VersionString(string path)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            if (toc.Contains(path))
                            {
                                return toc[path].VersionString;
                            }

                            Logger.Error("[{0}] Cannot find entry. path: {1}", new object[2] { id, path });
                            return null;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EB054
        public string Tag(string path)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            if (toc.Contains(path))
                            {
                                return toc[path].Tag;
                            }

                            Logger.Error("[{0}] Cannot find entry. path: {1}", new object[2] { id, path });
                            return null;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EB2DC
        public string FullPath(string path)
        {
                        return FullPath(path, true);
        }

        // RVA: 0x19EB2E4
        public string FullPath(string path, bool strictly)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            if (!strictly || toc.Contains(path))
                            {
                                return FullPathCore(path);
                            }

                            Logger.Error("[{0}] Cannot find entry. path: {1}", new object[2] { id, path });
                            return null;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EB554
        public long UsedSize(string path)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            if (toc.Contains(path))
                            {
                                FileSystemEntry fileSystemEntry = toc[path];
                                string text = FullPathCore(fileSystemEntry.Path);
                                if (new FileInfo(text).Exists)
                                {
                                    return new FileInfo(text).Length;
                                }

                                Logger.Error("[{0}]{1} Cannot find file. FullPath: {2}", new object[3] { id, fileSystemEntry, text });
                                return 0L;
                            }

                            Logger.Error("[{0}] Cannot find entry. path: {1}", new object[2] { id, path });
                            return 0L;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EB9D4
        public ICollection<FileSystemEntry> Entries(string tag)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            List<FileSystemEntry> list = new List<FileSystemEntry>();
                            foreach (FileSystemEntry item in toc.Where((FileSystemEntry entry) => entry.Tag == tag))
                            {
                                list.Add(item);
                            }

                            return list;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EBDF0
        public long UsedSizeByTag(string tag)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            long num = 0L;
                            foreach (FileSystemEntry item in toc.Where((FileSystemEntry entry) => entry.Tag == tag))
                            {
                                string text = FullPathCore(item.Path);
                                FileInfo fileInfo = new FileInfo(text);
                                if (fileInfo.Exists)
                                {
                                    num += fileInfo.Length;
                                }
                                else
                                {
                                    Logger.Error("[{0}]{1} Cannot find file. FullPath: {2}", new object[3] { id, item, text });
                                }
                            }

                            return num;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EC3F0
        public long UsedSizeByTags(ICollection<string> tags)
        {
                        ValidateDisposed();
                        if (tags == null || tags.Count < 1)
                        {
                            return 0L;
                        }

                        slim.EnterReadLock();
                        try
                        {
                            long num = 0L;
                            foreach (FileSystemEntry item in toc.Where((FileSystemEntry entry) => tags.Contains(entry.Tag)))
                            {
                                string text = FullPathCore(item.Path);
                                FileInfo fileInfo = new FileInfo(text);
                                if (fileInfo.Exists)
                                {
                                    num += fileInfo.Length;
                                }
                                else
                                {
                                    Logger.Error("[{0}]{1} Cannot find file. FullPath: {2}", new object[3] { id, item, text });
                                }
                            }

                            return num;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19ECA70
        public long UsedSizeAll()
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            long num = 0L;
                            foreach (FileSystemEntry item in toc)
                            {
                                string text = FullPathCore(item.Path);
                                FileInfo fileInfo = new FileInfo(text);
                                if (fileInfo.Exists)
                                {
                                    num += fileInfo.Length;
                                }
                                else
                                {
                                    Logger.Error("[{0}]{1} Cannot find file. FullPath: {2}", new object[3] { id, item, text });
                                }
                            }

                            return num;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19ED054
        public Nullable<DateTime> LastAccessTime(string path)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            // 二进制为 path.Contains(path)，对非空路径恒为真
                            if (path.Contains(path))
                            {
                                FileSystemEntry fileSystemEntry = toc[path];
                                string text = FullPathCore(fileSystemEntry.Path);
                                FileInfo fileInfo = new FileInfo(text);
                                if (fileInfo.Exists)
                                {
                                    return new DateTime?(fileInfo.LastAccessTimeUtc);
                                }

                                Logger.Error("[{0}]{1} Cannot find file. FullPath: {2}", new object[3] { id, fileSystemEntry, text });
                                return null;
                            }

                            Logger.Error("[{0}] Cannot find entry. path: {1}", new object[2] { id, path });
                            return null;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19ED508
        public ICollection<LastAccessTimePathSet> LastAccessTimeByTag(string tag)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            List<LastAccessTimePathSet> list = new List<LastAccessTimePathSet>();
                            foreach (FileSystemEntry item in toc.Where((FileSystemEntry entry) => entry.Tag == tag))
                            {
                                string text = FullPathCore(item.Path);
                                FileInfo fileInfo = new FileInfo(text);
                                if (fileInfo.Exists)
                                {
                                    list.Add(new LastAccessTimePathSet(item.Path, fileInfo.LastAccessTimeUtc));
                                }
                                else
                                {
                                    Logger.Error("[{0}]{1} Cannot find file. FullPath: {2}", new object[3] { id, item, text });
                                }
                            }

                            return list;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EDBAC
        public ICollection<LastAccessTimePathSet> LastAccessTimeByTags(ICollection<string> tags)
        {
                        ValidateDisposed();
                        List<LastAccessTimePathSet> list = new List<LastAccessTimePathSet>();
                        if (tags == null || tags.Count < 1)
                        {
                            return list;
                        }

                        slim.EnterReadLock();
                        try
                        {
                            foreach (FileSystemEntry item in toc.Where((FileSystemEntry entry) => tags.Contains(entry.Tag)))
                            {
                                string text = FullPathCore(item.Path);
                                FileInfo fileInfo = new FileInfo(text);
                                if (fileInfo.Exists)
                                {
                                    list.Add(new LastAccessTimePathSet
                                    {
                                        Path = item.Path,
                                        LastAccessTime = fileInfo.LastAccessTimeUtc
                                    });
                                }
                                else
                                {
                                    Logger.Error("[{0}]{1} Cannot find file. FullPath: {2}", new object[3] { id, item, text });
                                }
                            }

                            return list;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EE294
        public ICollection<LastAccessTimePathSet> LastAccessTimeAll()
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            List<LastAccessTimePathSet> list = new List<LastAccessTimePathSet>();
                            foreach (FileSystemEntry item in toc)
                            {
                                string text = FullPathCore(item.Path);
                                FileInfo fileInfo = new FileInfo(text);
                                if (fileInfo.Exists)
                                {
                                    list.Add(new LastAccessTimePathSet
                                    {
                                        Path = item.Path,
                                        LastAccessTime = fileInfo.LastAccessTimeUtc
                                    });
                                }
                                else
                                {
                                    Logger.Error("[{0}]{1} Cannot find file. FullPath: {2}", new object[3] { id, item, text });
                                }
                            }

                            return list;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EE828
        public int Count()
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            return toc.Count;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EE91C
        public int CountByTag(string tag)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            return toc.Count((FileSystemEntry entry) => entry.Tag == tag);
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EEA50
        public int CountByTags(ICollection<string> tags)
        {
                        ValidateDisposed();
                        if (tags == null || tags.Count < 1)
                        {
                            return 0;
                        }

                        slim.EnterReadLock();
                        try
                        {
                            return toc.Count((FileSystemEntry entry) => tags.Contains(entry.Tag));
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EEC00
        public bool Contains(string path)
        {
                        return Contains(path, false);
        }

        // RVA: 0x19EEC08
        public bool Contains(string path, bool strictly)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            bool flag = toc.Contains(path);
                            if (flag && strictly)
                            {
                                flag = File.Exists(FullPathCore(toc[path].Path));
                            }

                            return flag;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EECFC
        public bool VerifyNeedUpdate(string path, int version)
        {
                        return VerifyNeedUpdate(path, version.ToString());
        }

        // RVA: 0x19EED48
        public bool VerifyNeedUpdate(string path, string version)
        {
                        ValidateDisposed();
                        slim.EnterReadLock();
                        try
                        {
                            if (toc.Contains(path))
                            {
                                return toc[path].VersionString != version;
                            }

                            return true;
                        }
                        finally
                        {
                            slim.ExitReadLock();
                        }
        }

        // RVA: 0x19EEE38
        public bool Modify(string path, int version)
        {
                        return Modify(path, DefaultTag, version.ToString());
        }

        // RVA: 0x19EF190
        public bool Modify(string path, string version)
        {
                        return Modify(path, DefaultTag, version);
        }

        // RVA: 0x19EF218
        public bool Modify(string path, string tag, int version)
        {
                        return Modify(path, tag, version.ToString());
        }

        // RVA: 0x19EEED8
        public bool Modify(string path, string tag, string version)
        {
                        ValidateDisposed();
                        ValidateComma(path);
                        ValidateComma(tag);
                        slim.EnterWriteLock();
                        try
                        {
                            string text = FullPathCore(path);
                            if (File.Exists(text))
                            {
                                FileSystemEntry entry = new FileSystemEntry(path, tag, version);
                                toc.Modify(entry);
                                AppendText(entry.ToCsvString());
                                return true;
                            }

                            Logger.Error("[{0}] Cannot find file. fullPath: {1}", new object[2] { id, text });
                            return false;
                        }
                        finally
                        {
                            slim.ExitWriteLock();
                        }
        }

        // RVA: 0x19EF5B0
        public bool Remove(string path)
        {
                        ValidateDisposed();
                        slim.EnterWriteLock();
                        try
                        {
                            bool result = false;
                            if (toc.Contains(path))
                            {
                                FileSystemEntry fileSystemEntry = toc[path];
                                result = toc.Remove(fileSystemEntry.Path);
                                AppendText(fileSystemEntry.ToRemoveCsvString());
                            }

                            string text = FullPathCore(path);
                            if (File.Exists(text))
                            {
                                File.Delete(text);
                            }

                            return result;
                        }
                        finally
                        {
                            slim.ExitWriteLock();
                        }
        }

        // RVA: 0x19EF7E4
        public ICollection<string> RemoveByTag(string tag)
        {
                        ValidateDisposed();
                        slim.EnterWriteLock();
                        try
                        {
                            List<string> list = new List<string>();
                            foreach (FileSystemEntry item in toc.Where((FileSystemEntry entry) => entry.Tag == tag).ToList())
                            {
                                if (toc.Remove(item.Path))
                                {
                                    list.Add(item.Path);
                                    AppendText(item.ToRemoveCsvString());
                                }

                                string text = FullPathCore(item.Path);
                                if (File.Exists(text))
                                {
                                    File.Delete(text);
                                }
                            }

                            return list;
                        }
                        finally
                        {
                            slim.ExitWriteLock();
                        }
        }

        // RVA: 0x19EFAE4
        public ICollection<TaggedPathSet> RemoveByTags(ICollection<string> tags)
        {
                        ValidateDisposed();
                        List<TaggedPathSet> list = new List<TaggedPathSet>();
                        if (tags == null || tags.Count < 1)
                        {
                            return list;
                        }

                        slim.EnterWriteLock();
                        try
                        {
                            foreach (FileSystemEntry item in toc.Where((FileSystemEntry entry) => tags.Contains(entry.Tag)).ToList())
                            {
                                if (toc.Remove(item.Path))
                                {
                                    list.Add(new TaggedPathSet(item.Tag, item.Path));
                                    AppendText(item.ToRemoveCsvString());
                                }

                                string text = FullPathCore(item.Path);
                                if (File.Exists(text))
                                {
                                    File.Delete(text);
                                }
                            }

                            return list;
                        }
                        finally
                        {
                            slim.ExitWriteLock();
                        }
        }

        // RVA: 0x19EFE88
        public ICollection<string> RemoveNotExistFiles()
        {
                        ValidateDisposed();
                        slim.EnterWriteLock();
                        try
                        {
                            return RemoveNotExistFilesCore();
                        }
                        finally
                        {
                            slim.ExitWriteLock();
                        }
        }

        // RVA: 0x19F00DC
        public void Clear()
        {
                        ValidateDisposed();
                        slim.EnterWriteLock();
                        try
                        {
                            foreach (FileSystemEntry item in toc)
                            {
                                AppendText(item.ToRemoveCsvString());
                                string text = FullPathCore(item.Path);
                                if (File.Exists(text))
                                {
                                    File.Delete(text);
                                }
                            }

                            toc.Clear();
                        }
                        finally
                        {
                            slim.ExitWriteLock();
                        }
        }

        // RVA: 0x19F0450
        public bool Flush()
        {
                        return true;
        }

        // RVA: 0x19F0458
        protected virtual void Dispose(bool disposing)
        {
                        if (disposed)
                        {
                            return;
                        }

                        slim.EnterWriteLock();
                        try
                        {
                            if (disposing && streamWriter != null)
                            {
                                streamWriter.Dispose();
                                streamWriter = null;
                            }

                            DeleteOnPool(id);
                            toc = null;
                            disposed = true;
                        }
                        finally
                        {
                            slim.ExitWriteLock();
                        }
        }

        // RVA: 0x19EAB94
        private void ValidateDisposed()
        {
                        if (!disposed)
                        {
                            return;
                        }

                        throw new ObjectDisposedException("FileSystem");
        }

        // RVA: 0x19EFF18
        private ICollection<string> RemoveNotExistFilesCore()
        {
                        List<string> list = new List<string>();
                        foreach (FileSystemEntry item in toc.ToList())
                        {
                            if (!File.Exists(FullPathCore(item.Path)))
                            {
                                list.Add(item.Path);
                                if (toc.Remove(item.Path))
                                {
                                    AppendText(item.ToRemoveCsvString());
                                }
                            }
                        }

                        return list;
        }

        // RVA: 0x19EA110
        private string FullPathCore(string path)
        {
                        string path2 = basePath;
                        if (!string.IsNullOrEmpty(path))
                        {
                            path2 = Path.Combine(path2, path);
                        }

                        return Path.GetFullPath(path2);
        }

        // RVA: 0x19EA1CC
        private void RefreshToc()
        {
                        slim.EnterWriteLock();
                        try
                        {
                            toc = new FileSystemToc();
                            if (!LoadToc(tocFilePath))
                            {
                                if (File.Exists(tocFilePath))
                                {
                                    File.Delete(tocFilePath);
                                }

                                if (!LoadToc(backupFilePath))
                                {
                                    if (File.Exists(backupFilePath))
                                    {
                                        File.Delete(backupFilePath);
                                    }

                                    return;
                                }
                            }

                            string text = FullPathCore("toc.new");
                            using (FileStream stream = new FileStream(text, FileMode.Create, FileAccess.Write))
                            {
                                using (StreamWriter streamWriter = new StreamWriter(stream))
                                {
                                    streamWriter.WriteLine(string.Format("{0},{1}", FileSystemEntry.CurrentFormat, FileSystemEntry.CurrentFormatColumn));
                                    foreach (FileSystemEntry item in toc)
                                    {
                                        streamWriter.WriteLine(item.ToCsvString());
                                    }
                                }
                            }

                            MoveFile(tocFilePath, backupFilePath);
                            MoveFile(text, tocFilePath);
                        }
                        finally
                        {
                            slim.ExitWriteLock();
                        }
        }

        // RVA: 0x19F05CC
        private bool LoadToc(string tocPath)
        {
                        toc.Clear();
                        if (!File.Exists(tocPath))
                        {
                            return false;
                        }

                        try
                        {
                            using (FileStream stream = new FileStream(tocPath, FileMode.Open, FileAccess.Read))
                            {
                                using (StreamReader streamReader = new StreamReader(stream))
                                {
                                    string text = streamReader.ReadLine();
                                    if (text == null)
                                    {
                                        return false;
                                    }

                                    string[] array = text.Split(new char[1] { ',' });
                                    if (array.Length != 2)
                                    {
                                        return false;
                                    }

                                    int num = int.Parse(array[1]);
                                    while (!streamReader.EndOfStream)
                                    {
                                        string text2 = streamReader.ReadLine();
                                        if (text2 == null)
                                        {
                                            continue;
                                        }

                                        string[] array2 = text2.Split(new char[1] { ',' });
                                        if (num != array2.Length)
                                        {
                                            continue;
                                        }

                                        if (array2[0].Equals(FileSystemEntry.CommandModify))
                                        {
                                            toc.Modify(new FileSystemEntry(array2[1], array2[2], array2[3]));
                                        }
                                        else if (array2[0].Equals(FileSystemEntry.CommandRemove))
                                        {
                                            toc.Remove(array2[1]);
                                        }
                                    }

                                    return true;
                                }
                            }
                        }
                        catch (Exception ex)
                        {
                            Logger.Error("[{0}] Falied to load {1} : {2}", new object[3] { id, tocPath, ex.Message });
                            return false;
                        }
        }

        // RVA: 0x19F0DFC
        private void MoveFile(string sourcefile, string targetFile)
        {
                        if (File.Exists(sourcefile))
                        {
                            if (File.Exists(targetFile))
                            {
                                File.Delete(targetFile);
                            }

                            File.Move(sourcefile, targetFile);
                        }
        }

        // RVA: 0x19EF26C
        private void ValidateComma(string target)
        {
                        if (target != null && target.IndexOf(",", StringComparison.Ordinal) >= 1)
                        {
                            throw new ArgumentException("Commma can not be used.");
                        }
        }

        // RVA: 0x19EA7C8
        private void AppendText(string text)
        {
                        if (streamWriter != null)
                        {
                            streamWriter.WriteLine(text);
                        }

                        if (streamWriter != null)
                        {
                            streamWriter.Flush();
                        }
        }

        // RVA: 0x19F0E60
        static FileSystem()
        {
                        LifecycleLock = new object();
                        pool = new Dictionary<string, FileSystem>();
                        DefaultTag = string.Empty;
                        Logger = Logger.Get<FileSystem>();
                        TocFileName = "toc";
                        backupFileName = "toc.bak";
        }
    }
}

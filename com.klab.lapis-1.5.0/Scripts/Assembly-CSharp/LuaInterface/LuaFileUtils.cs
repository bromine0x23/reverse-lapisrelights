// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaFileUtils
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

namespace LuaInterface
{
    public class LuaFileUtils
    {
        public bool beZip;
        protected List<string> searchPaths;
        protected Dictionary<string, AssetBundle> zipMap;
        protected static LuaFileUtils instance;
        public static LuaFileUtils Instance { get; set; }

        // RVA: 0x2294528
        public static LuaFileUtils get_Instance()
        {
            return instance;
        }

        // RVA: 0x2294590
        protected static void set_Instance(LuaFileUtils value)
        {
            instance = value;
        }

        // RVA: 0x22945FC
        public LuaFileUtils()
        {
                        instance = this;
        }

        // RVA: 0x22946C4
        public virtual void Dispose()
        {
                        --count;

                        if (count > 0)
                        {
                            return;
                        }

                        IsAlive = false;
                        Dispose(true);            
        }

        // RVA: 0x2294848
        public bool AddSearchPath(string path, bool front = False)
        {
                        int index = searchPaths.IndexOf(path);

                        if (index >= 0)
                        {
                            return false;
                        }

                        if (front)
                        {
                            searchPaths.Insert(0, path);
                        }
                        else
                        {
                            searchPaths.Add(path);
                        }

                        return true;
        }

        // RVA: 0x2294904
        public bool RemoveSearchPath(string path)
        {
                        int index = searchPaths.IndexOf(path);

                        if (index >= 0)
                        {
                            searchPaths.RemoveAt(index);
                            return true;
                        }

                        return false;
        }

        // RVA: 0x229499C
        public void AddSearchBundle(string name, AssetBundle bundle)
        {
                        zipMap[name] = bundle;
        }

        // RVA: 0x2294A0C
        public string FindFile(string fileName)
        {
                        if (fileName == string.Empty)
                        {
                            return string.Empty;
                        }

                        if (Path.IsPathRooted(fileName))
                        {
                            if (!fileName.EndsWith(".lua"))
                            {
                                fileName += ".lua";
                            }

                            return fileName;
                        }

                        if (fileName.EndsWith(".lua"))
                        {
                            fileName = fileName.Substring(0, fileName.Length - 4);
                        }

                        string fullPath = null;

                        for (int i = 0; i < searchPaths.Count; i++)
                        {
                            fullPath = searchPaths[i].Replace("?", fileName);

                            if (File.Exists(fullPath))
                            {
                                return fullPath;
                            }
                        }

                        return null;
        }

        // RVA: 0x2294BA8
        public virtual byte[] ReadFile(string fileName)
        {
                        if (!beZip)
                        {
                            string path = FindFile(fileName);
                            byte[] str = null;

                            if (!string.IsNullOrEmpty(path) && File.Exists(path))
                            {
            #if !UNITY_WEBPLAYER
                                str = File.ReadAllBytes(path);
            #else
                                throw new LuaException("can't run in web platform, please switch to other platform");
            #endif
                            }

                            return str;
                        }
                        else
                        {
                            return ReadZipFile(fileName);
                        }
        }

        // RVA: 0x2294F98
        public virtual string FindFileError(string fileName)
        {
                        if (Path.IsPathRooted(fileName))
                        {
                            return fileName;
                        }

                        if (fileName.EndsWith(".lua"))
                        {
                            fileName = fileName.Substring(0, fileName.Length - 4);
                        }

                        using (CString.Block())
                        {
                            CString sb = CString.Alloc(512);

                            for (int i = 0; i < searchPaths.Count; i++)
                            {
                                sb.Append("\n\tno file '").Append(searchPaths[i]).Append('\'');
                            }

                            sb = sb.Replace("?", fileName);

                            if (beZip)
                            {
                                int pos = fileName.LastIndexOf('/');

                                if (pos > 0)
                                {
                                    int tmp = pos + 1;
                                    sb.Append("\n\tno file '").Append(fileName, tmp, fileName.Length - tmp).Append(".lua' in ").Append("lua_");
                                    tmp = sb.Length;
                                    sb.Append(fileName, 0, pos).Replace('/', '_', tmp, pos).Append(".unity3d");
                                }
                                else
                                {
                                    sb.Append("\n\tno file '").Append(fileName).Append(".lua' in ").Append("lua.unity3d");
                                }
                            }

                            return sb.ToString();
                        }
        }

        // RVA: 0x2294C10
        private byte[] ReadZipFile(string fileName)
        {
                        AssetBundle zipFile = null;
                        byte[] buffer = null;
                        string zipName = null;

                        using (CString.Block())
                        {
                            CString sb = CString.Alloc(256);
                            sb.Append("lua");
                            int pos = fileName.LastIndexOf('/');

                            if (pos > 0)
                            {
                                sb.Append("_");
                                sb.Append(fileName, 0, pos).ToLower().Replace('/', '_');
                                fileName = fileName.Substring(pos + 1);
                            }

                            if (!fileName.EndsWith(".lua"))
                            {
                                fileName += ".lua";
                            }

            #if UNITY_5 || UNITY_5_3_OR_NEWER
                            fileName += ".bytes";
            #endif
                            zipName = sb.ToString();
                            zipMap.TryGetValue(zipName, out zipFile);
                        }

                        if (zipFile != null)
                        {
            #if UNITY_4_6 || UNITY_4_7
                            TextAsset luaCode = zipFile.Load(fileName, typeof(TextAsset)) as TextAsset;
            #else
                            TextAsset luaCode = zipFile.LoadAsset<TextAsset>(fileName);
            #endif
                            if (luaCode != null)
                            {
                                buffer = luaCode.bytes;
                                Resources.UnloadAsset(luaCode);
                            }
                        }

                        return buffer;
        }

        // RVA: 0x2295414
        public static string GetOSDir()
        {
                        return LuaConst.osDir;
        }

        // RVA: 0x229547C
        static LuaFileUtils()
        {

        }
    }
}

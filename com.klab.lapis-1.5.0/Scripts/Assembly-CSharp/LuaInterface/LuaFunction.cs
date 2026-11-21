// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  LuaInterface.LuaFunction
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
    public class LuaFunction : LuaBaseRef
    {
        protected int oldTop;
        private int argCount;
        private int stackPos;
        private Stack<LuaFunction.FuncData> stack;

        // RVA: 0x2295480
        public void .ctor(int reference, LuaState state)
        {
            oldTop = -1;
            stackPos = -1;
            stack = new Stack<FuncData>();
            this.reference = reference;
            this.luaState = state;
        }

        // RVA: 0x2295514
        public override void Dispose()
        {
            base.Dispose();
        }

        public T ToDelegate<T>()
        {
                        return DelegateTraits<T>.Create(this) as T;
        }

        // RVA: 0x2295518
        public virtual int BeginPCall()
        {
            if (luaState == null)
            {
                throw new LuaException("LuaFunction has been disposed");
            }

            stack.Push(new FuncData() { oldTop = oldTop, stackPos = stackPos });
            oldTop = luaState.BeginPCall(reference);
            argCount = 0;
            stackPos = -1;
            return oldTop;
        }

        // RVA: 0x2285330
        public void PCall()
        {
            stackPos = oldTop + 1;
            try
            {
                luaState.PCall(argCount, oldTop);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2285424
        public void EndPCall()
        {
            if (oldTop == -1)
            {
                return;
            }

            luaState.EndPCall(oldTop);
            argCount = 0;
            FuncData data = stack.Pop();
            oldTop = data.oldTop;
            stackPos = data.stackPos;
        }

        // RVA: 0x2284C10
        public void Call()
        {
            BeginPCall();
            PCall();
            EndPCall();
        }

        public void Call<T1>(T1 arg1)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PCall();
                        EndPCall();
        }

        public void Call<T1, T2>(T1 arg1, T2 arg2)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PCall();
                        EndPCall();
        }

        public void Call<T1, T2, T3>(T1 arg1, T2 arg2, T3 arg3)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PCall();
                        EndPCall();
        }

        public void Call<T1, T2, T3, T4>(T1 arg1, T2 arg2, T3 arg3, T4 arg4)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PCall();
                        EndPCall();
        }

        public void Call<T1, T2, T3, T4, T5>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PushGeneric(arg5);
                        PCall();
                        EndPCall();
        }

        public void Call<T1, T2, T3, T4, T5, T6>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PushGeneric(arg5);
                        PushGeneric(arg6);
                        PCall();
                        EndPCall();
        }

        public void Call<T1, T2, T3, T4, T5, T6, T7>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PushGeneric(arg5);
                        PushGeneric(arg6);
                        PushGeneric(arg7);
                        PCall();
                        EndPCall();
        }

        public void Call<T1, T2, T3, T4, T5, T6, T7, T8>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PushGeneric(arg5);
                        PushGeneric(arg6);
                        PushGeneric(arg7);
                        PushGeneric(arg8);
                        PCall();
                        EndPCall();
        }

        public void Call<T1, T2, T3, T4, T5, T6, T7, T8, T9>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8, T9 arg9)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PushGeneric(arg5);
                        PushGeneric(arg6);
                        PushGeneric(arg7);
                        PushGeneric(arg8);
                        PushGeneric(arg9);
                        PCall();
                        EndPCall();
        }

        public R1 Invoke<R1>()
        {
                        BeginPCall();
                        PCall();
                        R1 ret1 = CheckValue<R1>();
                        EndPCall();
                        return ret1;
        }

        public R1 Invoke<T1, R1>(T1 arg1)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PCall();
                        R1 ret1 = CheckValue<R1>();
                        EndPCall();
                        return ret1;
        }

        public R1 Invoke<T1, T2, R1>(T1 arg1, T2 arg2)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PCall();
                        R1 ret1 = CheckValue<R1>();
                        EndPCall();
                        return ret1;
        }

        public R1 Invoke<T1, T2, T3, R1>(T1 arg1, T2 arg2, T3 arg3)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PCall();
                        R1 ret1 = CheckValue<R1>();
                        EndPCall();
                        return ret1;
        }

        public R1 Invoke<T1, T2, T3, T4, R1>(T1 arg1, T2 arg2, T3 arg3, T4 arg4)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PCall();
                        R1 ret1 = CheckValue<R1>();
                        EndPCall();
                        return ret1;
        }

        public R1 Invoke<T1, T2, T3, T4, T5, R1>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PushGeneric(arg5);
                        PCall();
                        R1 ret1 = CheckValue<R1>();
                        EndPCall();
                        return ret1;
        }

        public R1 Invoke<T1, T2, T3, T4, T5, T6, R1>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PushGeneric(arg5);
                        PushGeneric(arg6);
                        PCall();
                        R1 ret1 = CheckValue<R1>();
                        EndPCall();
                        return ret1;
        }

        public R1 Invoke<T1, T2, T3, T4, T5, T6, T7, R1>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PushGeneric(arg5);
                        PushGeneric(arg6);
                        PushGeneric(arg7);
                        PCall();
                        R1 ret1 = CheckValue<R1>();
                        EndPCall();
                        return ret1;
        }

        public R1 Invoke<T1, T2, T3, T4, T5, T6, T7, T8, R1>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PushGeneric(arg5);
                        PushGeneric(arg6);
                        PushGeneric(arg7);
                        PushGeneric(arg8);
                        PCall();
                        R1 ret1 = CheckValue<R1>();
                        EndPCall();
                        return ret1;
        }

        public R1 Invoke<T1, T2, T3, T4, T5, T6, T7, T8, T9, R1>(T1 arg1, T2 arg2, T3 arg3, T4 arg4, T5 arg5, T6 arg6, T7 arg7, T8 arg8, T9 arg9)
        {
                        BeginPCall();
                        PushGeneric(arg1);
                        PushGeneric(arg2);
                        PushGeneric(arg3);
                        PushGeneric(arg4);
                        PushGeneric(arg5);
                        PushGeneric(arg6);
                        PushGeneric(arg7);
                        PushGeneric(arg8);
                        PushGeneric(arg9);            
                        PCall();
                        R1 ret1 = CheckValue<R1>();
                        EndPCall();
                        return ret1;
        }

        // RVA: 0x2295620
        [Obsolete]
        public object[] LazyCall(object[] args)
        {
            BeginPCall();
            int nArgs = args == null ? 0 : args.Length + 6;
            if (!luaState.LuaCheckStack(nArgs))
            {
                EndPCall();
                throw new LuaException("stack overflow");
            }

            PushArgs(args);
            PCall();
            object[] ret = luaState.CheckObjects(oldTop);
            EndPCall();
            return ret;
        }

        // RVA: 0x2295760
        public void CheckStack(int args)
        {
            luaState.LuaCheckStack(args);
        }

        // RVA: 0x2295780
        public bool IsBegin()
        {
            return oldTop != -1;
        }

        // RVA: 0x2295790
        public void Push(double num)
        {
            try
            {
                luaState.Push(num);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x22852F4
        public void Push(int n)
        {
            try
            {
                luaState.Push(n);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x22957CC
        public void PushLayerMask(LayerMask n)
        {
            try
            {
                luaState.PushLayerMask(n);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x229580C
        public void Push(uint un)
        {
            try
            {
                luaState.Push(un);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295848
        public void Push(long num)
        {
            try
            {
                luaState.Push(num);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295884
        public void Push(ulong un)
        {
            try
            {
                luaState.Push(un);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x22958C0
        public void Push(bool b)
        {
            try
            {
                luaState.Push(b);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295900
        public void Push(string str)
        {
            try
            {
                luaState.Push(str);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x229593C
        public void Push(IntPtr ptr)
        {
            try
            {
                luaState.Push(ptr);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2288E78
        public void Push(LuaBaseRef lbr)
        {
            try
            {
                luaState.Push(lbr);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295978
        public void Push(object o)
        {
            try
            {
                luaState.PushVariant(o);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x22959B4
        public void Push(Object o)
        {
            try
            {
                luaState.Push(o);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x22959F0
        public void Push(Type t)
        {
            try
            {
                luaState.Push(t);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295A2C
        public void Push(Enum e)
        {
            try
            {
                luaState.Push(e);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295A68
        public void Push(Array array)
        {
            try
            {
                luaState.Push(array);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295AA4
        public void Push(Vector3 v3)
        {
            try
            {
                luaState.Push(v3);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295AE0
        public void Push(Vector2 v2)
        {
            try
            {
                luaState.Push(v2);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295B1C
        public void Push(Vector4 v4)
        {
            try
            {
                luaState.Push(v4);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295B58
        public void Push(Quaternion quat)
        {
            try
            {
                luaState.Push(quat);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295B94
        public void Push(Color clr)
        {
            try
            {
                luaState.Push(clr);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295BD0
        public void Push(Ray ray)
        {
            try
            {
                luaState.Push(ray);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295CF0
        public void Push(Bounds bounds)
        {
            try
            {
                luaState.Push(bounds);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295E10
        public void Push(RaycastHit hit)
        {
            try
            {
                luaState.Push(hit);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2295F30
        public void Push(Touch t)
        {
            try
            {
                luaState.Push(t);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296054
        public void Push(LuaByteBuffer buffer)
        {
            try
            {
                luaState.Push(buffer);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        public void PushValue<T>(T value)
        {
                        try
                        {
                            luaState.PushValue(value);
                            ++argCount;
                        }
                        catch (Exception e)
                        {
                            EndPCall();
                            throw e;
                        }
        }

        // RVA: 0x2296154
        public void PushObject(object o)
        {
            try
            {
                luaState.PushObject(o);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        public void PushSealed<T>(T o)
        {
                        try
                        {
                            luaState.PushSealed(o);
                            ++argCount;
                        }
                        catch (Exception e)
                        {
                            EndPCall();
                            throw e;
                        }
        }

        public void PushGeneric<T>(T t)
        {
                        try
                        {
                            luaState.PushGeneric(t);
                            ++argCount;
                        }
                        catch (Exception e)
                        {
                            EndPCall();
                            throw e;
                        }
        }

        // RVA: 0x2295728
        public void PushArgs(object[] args)
        {
            if (args == null)
            {
                return;
            }

            argCount += args.Length;
            luaState.PushArgs(args);
        }

        // RVA: 0x229624C
        public void PushByteBuffer(byte[] buffer, int len = -1)
        {
            try
            {
                if (len == -1)
                {
                    len = buffer.Length;
                }

                luaState.PushByteBuffer(buffer, len);
                argCount++;
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296364
        public double CheckNumber()
        {
            try
            {
                return luaState.LuaCheckNumber(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296458
        public bool CheckBoolean()
        {
            try
            {
                return luaState.LuaCheckBoolean(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296550
        public string CheckString()
        {
            try
            {
                return luaState.CheckString(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296644
        public Vector3 CheckVector3()
        {
            try
            {
                return luaState.CheckVector3(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296738
        public Quaternion CheckQuaternion()
        {
            try
            {
                return luaState.CheckQuaternion(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x229682C
        public Vector2 CheckVector2()
        {
            try
            {
                return luaState.CheckVector2(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296920
        public Vector4 CheckVector4()
        {
            try
            {
                return luaState.CheckVector4(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296A14
        public Color CheckColor()
        {
            try
            {
                return luaState.CheckColor(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296B08
        public Ray CheckRay()
        {
            try
            {
                return luaState.CheckRay(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296C30
        public Bounds CheckBounds()
        {
            try
            {
                return luaState.CheckBounds(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296D58
        public LayerMask CheckLayerMask()
        {
            try
            {
                return luaState.CheckLayerMask(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296E50
        public long CheckLong()
        {
            try
            {
                return luaState.CheckLong(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2296F44
        public ulong CheckULong()
        {
            try
            {
                return luaState.CheckULong(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2297038
        public Delegate CheckDelegate()
        {
            try
            {
                return luaState.CheckDelegate(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x229712C
        public object CheckVariant()
        {
            return luaState.ToVariant(stackPos++);
        }

        // RVA: 0x2297158
        public char[] CheckCharBuffer()
        {
            try
            {
                return luaState.CheckCharBuffer(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x229724C
        public byte[] CheckByteBuffer()
        {
            try
            {
                return luaState.CheckByteBuffer(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2297340
        public object CheckObject(Type t)
        {
            try
            {
                return luaState.CheckObject(stackPos++, t);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x229743C
        public LuaFunction CheckLuaFunction()
        {
            try
            {
                return luaState.CheckLuaFunction(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2297530
        public LuaTable CheckLuaTable()
        {
            try
            {
                return luaState.CheckLuaTable(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        // RVA: 0x2297624
        public LuaThread CheckLuaThread()
        {
            try
            {
                return luaState.CheckLuaThread(stackPos++);
            }
            catch
            {
                EndPCall();
                throw;
            }
        }

        public T CheckValue<T>()
        {
                        try
                        {
                            return luaState.CheckValue<T>(stackPos++);
                        }
                        catch (Exception e)
                        {
                            EndPCall();
                            throw e;
                        }
        }
    }
}

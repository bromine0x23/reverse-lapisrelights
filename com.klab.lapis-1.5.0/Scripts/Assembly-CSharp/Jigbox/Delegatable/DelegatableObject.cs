// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.Delegatable.DelegatableObject
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（已还原成员）
//  说明：本轮还原 Callback 委托、静态 BindingFlags、Target/MethodName、Clear 与构造；
//        Parameters/ParametersInfo/IsValid、Execute*/SetEvent*/Executes*、
//        ToString*/Equals/GetHashCode/FindCallback 仍待还原。
// =============================================================================

using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

namespace Jigbox.Delegatable
{
    public class DelegatableObject
    {
        public delegate void Callback();

        public static readonly BindingFlags ReflectionBindingFlag; // 0x0

        private Object target;            // 0x10
        private string methodName;        // 0x18
        private ArgumentParameter[] parameters; // 0x20
        private bool isCached;            // 0x28
        private Callback callback;        // 0x30
        private IEventDelegate eventDelegate; // 0x38
        private MethodInfo methodInfo;    // 0x40
        private ParameterInfo[] parametersInfo; // 0x48
        private object[] args;            // 0x50

        public Object Target
        {
            // RVA: 0x1CAB8D4
            get { return target; }
            // RVA: 0x1CAB8DC
            set
            {
                if (target != value)
                {
                    isCached = false;
                    methodName = null;
                    parameters = null;
                    args = null;
                    callback = null;
                    eventDelegate = null;
                    methodInfo = null;
                    parametersInfo = null;
                    target = value;
                }
            }
        }

        public string MethodName
        {
            // RVA: 0x1CAB998
            get { return methodName; }
            // RVA: 0x1CAB9A0
            set
            {
                if (methodName != value)
                {
                    isCached = false;
                    methodName = value;
                    parameters = null;
                    parametersInfo = null;
                    args = null;
                    eventDelegate = null;
                    methodInfo = null;
                    callback = null;
                }
            }
        }

        // RVA: 0x1CA859C
        public DelegatableObject()
        {
        }

        // RVA: 0x1CAC110
        public bool Execute()
        {
            if (!isCached)
            {
                isCached = true;
                FindCallback();
            }

            if (callback != null)
            {
                callback();
                return true;
            }

            if (methodInfo == null)
            {
                return false;
            }

            if (parameters != null && parameters.Length != 0)
            {
                if (args == null)
                {
                    args = new object[parameters.Length];
                }

                for (int i = 0; i < parameters.Length; i++)
                {
                    args[i] = parameters[i].Value;
                }
            }

            if (eventDelegate != null)
            {
                eventDelegate.Invoke(args);
            }
            else
            {
                methodInfo.Invoke(target, args);
            }

            if (parameters != null)
            {
                for (int i = 0; i < parameters.Length; i++)
                {
                    if (parametersInfo[i].IsIn || parametersInfo[i].IsOut)
                    {
                        parameters[i].Value = args[i];
                    }
                }
            }

            return true;
        }

        // RVA: 0x1CACCD4
        public bool Execute(object[] args)
        {
            if (!isCached)
            {
                isCached = true;
                FindCallback();
            }

            if (callback != null)
            {
                callback();
                return true;
            }

            if (methodInfo == null)
            {
                return false;
            }

            int count = parameters != null ? parameters.Length : 0;

            if (count != args.Length)
            {
                return Execute();
            }

            for (int i = 0; i < count; i++)
            {
                System.Type parameterType = parametersInfo[i].ParameterType;
                System.Type argumentType = args[i].GetType();

                if (parameterType != argumentType &&
                    !parameterType.IsAssignableFrom(argumentType))
                {
                    return Execute();
                }
            }

            object[] invokeArgs = count == 0 ? null : args;

            if (eventDelegate != null)
            {
                eventDelegate.Invoke(invokeArgs);
            }
            else
            {
                methodInfo.Invoke(target, invokeArgs);
            }

            return true;
        }

        // RVA: 0x1CAB28C
        public void SetEvent(Callback callback)
        {
            Clear();

            this.callback = callback;
            isCached = true;

            if (callback != null)
            {
                target = callback.Target as MonoBehaviour;

                MethodInfo method = callback.Method;
                if (method != null)
                {
                    methodName = method.Name;
                }
            }
        }

        // RVA: 0x1CAAE58
        public void SetEvent(Object target, string methodName, object[] args)
        {
            isCached = false;
            this.methodName = methodName;
            parametersInfo = null;
            this.args = null;
            eventDelegate = null;
            methodInfo = null;
            callback = null;
            this.target = target;

            if (args != null)
            {
                parameters = new ArgumentParameter[args.Length];

                for (int i = 0; i < args.Length; i++)
                {
                    parameters[i] = new ArgumentParameter();
                    parameters[i].Value = args[i];
                }
            }

            if (parameters != null)
            {
                isCached = true;
                FindCallback();

                if (parameters.Length != args.Length)
                {
                    for (int i = 0; i < args.Length; i++)
                    {
                        parameters[i].Value = args[i];
                    }
                }
            }
        }

        // RVA: 0x1CA8604
        public void SetEvent(IEventDelegate eventDelegate)
        {
            Clear();

            target = eventDelegate.Target;
            methodInfo = eventDelegate.Method;
            methodName = methodInfo.Name;
            parametersInfo = methodInfo.GetParameters();
            parameters = new ArgumentParameter[parametersInfo.Length];

            for (int i = 0; i < parametersInfo.Length; i++)
            {
                parameters[i] = new ArgumentParameter();
                parameters[i].Type = parametersInfo[i].ParameterType;
            }

            this.eventDelegate = eventDelegate;
            isCached = true;
        }

        // RVA: 0x1CAA830
        public static void Executes(List<DelegatableObject> list)
        {
            for (int i = 0; i < list.Count; i++)
            {
                list[i].Execute();
            }
        }

        // RVA: 0x1CAA994
        public static void Executes(List<DelegatableObject> list, object[] args)
        {
            for (int i = 0; i < list.Count; i++)
            {
                list[i].Execute(args);
            }
        }

        // RVA: 0x146C5CC (Executes<T> shared implementation)
        public static void Executes<T>(List<DelegatableObject> list, T parameter)
        {
            for (int i = 0; i < list.Count; i++)
            {
                list[i].Execute(parameter);
            }
        }

        // RVA: 0x26963E4 (Execute<T> shared implementation for reference types)
        public bool Execute<T>(T data)
        {
            if (!isCached)
            {
                isCached = true;
                FindCallback();
            }

            if (callback != null)
            {
                callback();
                return true;
            }

            if (methodInfo == null)
            {
                return false;
            }

            int count = parameters != null ? parameters.Length : 0;
            System.Type dataType = data.GetType();

            if (count != 0)
            {
                if (args == null)
                {
                    args = new object[count];
                }

                for (int i = 0; i < count; i++)
                {
                    System.Type parameterType = parametersInfo[i].ParameterType;

                    args[i] = parameterType == dataType ||
                              parameterType.IsAssignableFrom(dataType)
                        ? (object)data
                        : parameters[i].Value;
                }
            }

            object[] invokeArgs = count == 0 ? null : args;

            try
            {
                if (eventDelegate != null)
                {
                    eventDelegate.Invoke(invokeArgs);
                }
                else
                {
                    methodInfo.Invoke(target, invokeArgs);
                }
            }
            catch (Exception exception)
            {
                // 原实现会拼接 target/method/参数类型生成诊断信息后 LogError。
                Debug.LogError(exception.Message);
                return false;
            }

            for (int i = 0; i < count; i++)
            {
                if (parametersInfo[i].IsIn || parametersInfo[i].IsOut)
                {
                    parameters[i].Value = args[i];
                }
            }

            return true;
        }

        public bool IsValid
        {
            // RVA: 0x1CAB114
            get
            {
                if (!isCached)
                {
                    isCached = true;
                    FindCallback();
                }

                if (callback != null || eventDelegate != null)
                {
                    return true;
                }

                if (target != null)
                {
                    return !string.IsNullOrEmpty(methodName);
                }

                return false;
            }
        }

        // RVA: 0x1CAD720
        public override bool Equals(object obj)
        {
            if (obj == null)
            {
                return false;
            }

            if (obj is Callback otherCallback)
            {
                return callback == otherCallback;
            }

            if (obj is DelegatableObject other)
            {
                if (target != other.target)
                {
                    return false;
                }

                if (methodName != other.methodName)
                {
                    return false;
                }

                if (parameters == null && other.parameters == null)
                {
                    return true;
                }

                if (parameters == null || other.parameters == null)
                {
                    return false;
                }

                if (parameters.Length != other.parameters.Length)
                {
                    return false;
                }

                for (int i = 0; i < parameters.Length; i++)
                {
                    System.Type mine = parameters[i].Type;
                    System.Type theirs = other.parameters[i].Type;

                    if (mine != theirs &&
                        !mine.IsAssignableFrom(theirs) &&
                        !theirs.IsAssignableFrom(mine))
                    {
                        return false;
                    }
                }

                return true;
            }

            IEventDelegate eventDelegate = obj as IEventDelegate;
            return this.eventDelegate != null && this.eventDelegate.Equals(eventDelegate);
        }

        // RVA: 0x1CADD18
        public override int GetHashCode()
        {
            int hash = base.GetHashCode();

            hash ^= target != null ? target.GetHashCode() : 0;
            hash ^= !string.IsNullOrEmpty(methodName) ? methodName.GetHashCode() : 0;

            return hash;
        }

        // RVA: 0x1CABA1C
        protected void FindCallback()
        {
            if (callback != null)
            {
                MonoBehaviour callbackTarget = callback.Target as MonoBehaviour;

                if (callbackTarget == target && callback.Method.Name == methodName)
                {
                    return;
                }
            }

            if (target == null || string.IsNullOrEmpty(methodName))
            {
                return;
            }

            System.Type targetType = target.GetType();
            int count = parameters != null ? parameters.Length : 0;
            System.Type[] types = new System.Type[count];
            bool useParameterTypes = true;

            for (int i = 0; i < count; i++)
            {
                System.Type parameterType = parameters[i].Type;

                if (parameterType == typeof(void))
                {
                    useParameterTypes = false;
                    break;
                }

                types[i] = parameterType;
            }

            if (useParameterTypes)
            {
                methodInfo = targetType.GetMethod(
                    methodName,
                    ReflectionBindingFlag,
                    null,
                    types,
                    null);
            }
            else
            {
                methodInfo = targetType.GetMethod(methodName, ReflectionBindingFlag);
            }

            if (methodInfo == null)
            {
                return;
            }

            if (methodInfo.ReturnType != typeof(void))
            {
                return;
            }

            parametersInfo = methodInfo.GetParameters();
            int parameterCount = parametersInfo.Length;
            callback = null;

            if (parameters != null && parameters.Length == parameterCount)
            {
                for (int i = 0; i < parameterCount; i++)
                {
                    parameters[i].Type = parametersInfo[i].ParameterType;
                }

                return;
            }

            if (parameterCount == 0)
            {
                try
                {
                    Callback created = (Callback)Delegate.CreateDelegate(
                        typeof(Callback),
                        target,
                        methodName);

                    parameters = null;
                    callback = created;
                    methodInfo = null;
                    args = null;
                }
                catch (Exception exception)
                {
                    Debug.LogError(exception);
                }
            }

            parameters = new ArgumentParameter[parameterCount];
            args = null;

            for (int i = 0; i < parameterCount; i++)
            {
                parameters[i] = new ArgumentParameter();
                parameters[i].Type = parametersInfo[i].ParameterType;
            }
        }

        // RVA: 0x1CAB97C
        protected void Clear()
        {
            target = null;
            methodName = null;
            isCached = false;
            parameters = null;
            parametersInfo = null;
            args = null;
            eventDelegate = null;
            methodInfo = null;
            callback = null;
        }

        // RVA: 0x1CAE06C
        static DelegatableObject()
        {
            ReflectionBindingFlag =
                BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic;
        }
    }
}

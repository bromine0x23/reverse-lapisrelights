// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.Delegatable.ArgumentParameter
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Reflection;
using UnityEngine;

namespace Jigbox.Delegatable
{
    public class ArgumentParameter
    {
        private Object referencedObject; // 0x10
        private string fieldName;        // 0x18
        private string typeName;         // 0x20
        private object value;            // 0x28
        private System.Type type;               // 0x30
        private FieldInfo fieldInfo;     // 0x38
        private PropertyInfo propertyInfo; // 0x40
        private bool isCached;           // 0x48

        public Object ReferencedObject
        {
            // RVA: 0x1CA9FD0
            get { return referencedObject; }
            // RVA: 0x1CA9FD8
            set
            {
                if (referencedObject != value)
                {
                    referencedObject = value;
                }
            }
        }

        public string FieldName
        {
            // RVA: 0x1CAA060
            get { return fieldName; }
            // RVA: 0x1CAA068
            set
            {
                if (fieldName != value)
                {
                    fieldName = value;
                    type = null;
                    typeName = string.Empty;
                }
            }
        }

        public object Value
        {
            // RVA: 0x1CAA0E8
            get
            {
                if (value != null)
                {
                    return value;
                }

                if (!isCached)
                {
                    isCached = true;
                    propertyInfo = null;
                    fieldInfo = null;

                    if (referencedObject != null && !string.IsNullOrEmpty(fieldName))
                    {
                        System.Type referencedType = referencedObject.GetType();

                        propertyInfo = referencedType.GetProperty(
                            fieldName,
                            DelegatableObject.ReflectionBindingFlag);

                        if (propertyInfo == null)
                        {
                            fieldInfo = referencedType.GetField(
                                fieldName,
                                DelegatableObject.ReflectionBindingFlag);
                        }
                    }
                }

                if (propertyInfo != null)
                {
                    return propertyInfo.GetValue(referencedObject, null);
                }

                if (fieldInfo != null)
                {
                    return fieldInfo.GetValue(referencedObject);
                }

                if (referencedObject != null)
                {
                    return referencedObject;
                }

                return null;
            }
            // RVA: 0x1CAA334
            set { value = value; }
        }

        public System.Type Type
        {
            // RVA: 0x1CAA33C
            get
            {
                if (type != null)
                {
                    return type;
                }

                if (!string.IsNullOrEmpty(typeName))
                {
                    type = System.Type.GetType(
                        typeName + ", Assembly-CSharp, Version=0.0.0.0, " +
                        "Culture=neutral, PublicKeyToken=null");

                    if (type != null)
                    {
                        return type;
                    }

                    type = System.Type.GetType(typeName);

                    if (type != null)
                    {
                        return type;
                    }
                }

                if (value == null)
                {
                    value = Value;
                }

                if (value != null)
                {
                    type = value.GetType();
                    typeName = type.ToString();
                    return type;
                }

                type = typeof(void);
                return type;
            }
            // RVA: 0x1CAA4E4
            set
            {
                if (type != value)
                {
                    type = value;
                    typeName = value.ToString();
                }
            }
        }

        // RVA: 0x1CAA7B8
        public ArgumentParameter()
        {
        }
    }
}

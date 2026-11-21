// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jackpot.XmlSerializeSupport
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Xml;
using System.Xml.Serialization;

namespace Jackpot
{
    public static class XmlSerializeSupport
    {
        // RVA: 0x146BBE4 (XmlSerializeSupport.WriteFromXml<object, object>)
        public static void WriteFromXml<TKey, TValue>(IDictionary<TKey, TValue> dictionary, byte[] buffer)
        {
            using (MemoryStream input = new MemoryStream(buffer))
            {
                using (XmlTextReader reader = new XmlTextReader(input))
                {
                    reader.ReadStartElement("Dictionary");
                    XmlSerializer keySerializer = new XmlSerializer(typeof(TKey));
                    XmlSerializer valueSerializer = new XmlSerializer(typeof(TValue));
                    while (reader.MoveToContent() != XmlNodeType.EndElement)
                    {
                        reader.ReadStartElement("KeyValuePair");
                        reader.ReadStartElement("Key");
                        TKey key = (TKey)keySerializer.Deserialize(reader);
                        reader.ReadEndElement();
                        reader.ReadStartElement("Value");
                        TValue value = (TValue)valueSerializer.Deserialize(reader);
                        reader.ReadEndElement();
                        reader.ReadEndElement();
                        dictionary.Add(key, value);
                    }

                    reader.ReadEndElement();
                }
            }
        }

        // RVA: 0x130E0B0 (XmlSerializeSupport.ToXml<object, object>)
        public static byte[] ToXml<TKey, TValue>(IDictionary<TKey, TValue> dictionary)
        {
            if (dictionary == null)
            {
                throw new ArgumentNullException("dictionary");
            }

            using (MemoryStream output = new MemoryStream())
            {
                using (XmlTextWriter writer = new XmlTextWriter(output, Encoding.UTF8))
                {
                    writer.WriteStartElement("Dictionary");
                    XmlSerializer keySerializer = new XmlSerializer(typeof(TKey));
                    XmlSerializer valueSerializer = new XmlSerializer(typeof(TValue));
                    foreach (KeyValuePair<TKey, TValue> item in dictionary)
                    {
                        writer.WriteStartElement("KeyValuePair");
                        writer.WriteStartElement("Key");
                        keySerializer.Serialize(writer, item.Key);
                        writer.WriteEndElement();
                        writer.WriteStartElement("Value");
                        valueSerializer.Serialize(writer, item.Value);
                        writer.WriteEndElement();
                        writer.WriteEndElement();
                    }

                    writer.WriteEndElement();
                    writer.Flush();
                }

                return output.ToArray();
            }
        }
    }
}

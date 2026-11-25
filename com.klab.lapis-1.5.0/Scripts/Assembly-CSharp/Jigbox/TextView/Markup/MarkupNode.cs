// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Jigbox.TextView.Markup.MarkupNode
//  来源：Il2CppDumper 元数据（签名精确）+ libil2cpp.so 反汇编（方法体）
// =============================================================================

using System;
using System.Collections.Generic;

namespace Jigbox.TextView.Markup
{
    public class MarkupNode
    {
        protected List<MarkupNode> children;             // 0x10
        protected Dictionary<string, string> attributes; // 0x18

        public MarkupNode Parent { get; private set; }   // 0x20

        public List<MarkupNode> Children
        {
            // RVA: 0x181EB04
            get
            {
                if (children == null)
                {
                    children = new List<MarkupNode>();
                }

                return children;
            }
        }

        public int ChildrenCount
        {
            // RVA: 0x181EECC
            get { return children == null ? 0 : children.Count; }
        }

        public Dictionary<string, string> Attributes
        {
            // RVA: 0x181EDE4
            get
            {
                if (attributes == null)
                {
                    attributes = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
                }

                return attributes;
            }
        }

        public int AttributesCount
        {
            // RVA: 0x181ED84
            get { return attributes == null ? 0 : attributes.Count; }
        }

        // RVA: 0x181EF30
        public void AppendChild(MarkupNode node)
        {
            Children.Add(node);
            node.Parent = this;
        }

        // RVA: 0x181EFA8
        public void SetAttributesCapacity(int capacity)
        {
            attributes = new Dictionary<string, string>(capacity, StringComparer.OrdinalIgnoreCase);
        }

        // RVA: 0x181F08C
        public void SetChildrenCapacity(int capacity)
        {
            children = new List<MarkupNode>(capacity);
        }

        // RVA: 0x181EBB4
        public MarkupNode()
        {
        }
    }
}

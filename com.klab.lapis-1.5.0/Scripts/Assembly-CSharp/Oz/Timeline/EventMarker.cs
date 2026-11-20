// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EventMarker
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        get_id    : new PropertyName(m_EventName ?? string.Empty)
//        get_flags : TriggerInEditMode (+ Retroactive) (+ TriggerOnce)
// =============================================================================

using UnityEngine;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class EventMarker : Marker, INotification, INotificationOptionProvider
    {
        [SerializeField]
        private bool m_Retroactive;
        [SerializeField]
        private bool m_EmitOnce;
        [SerializeField]
        private string m_EventName;
        [SerializeField]
        private EventData m_EventData;
        public bool Retroactive { get; set; }
        public bool EmitOnce { get; set; }
        public string EventName { get; set; }
        public EventData EventData { get; set; }

        // RVA: 0x13D75B4
        public bool get_Retroactive()
        {
            return Retroactive;
        }

        // RVA: 0x13D75BC
        public void set_Retroactive(bool value)
        {
            Retroactive = value;
        }

        // RVA: 0x13D75C8
        public bool get_EmitOnce()
        {
            return EmitOnce;
        }

        // RVA: 0x13D75D0
        public void set_EmitOnce(bool value)
        {
            EmitOnce = value;
        }

        // RVA: 0x13D75DC
        public string get_EventName()
        {
            return EventName;
        }

        // RVA: 0x13D75E4
        public void set_EventName(string value)
        {
            EventName = value;
        }

        // RVA: 0x13D75EC
        public EventData get_EventData()
        {
            return EventData;
        }

        // RVA: 0x13D75F4
        public void set_EventData(EventData value)
        {
            EventData = value;
        }

        // RVA: 0x13D75FC
        PropertyName INotification.id
        {
            get { return new PropertyName(m_EventName ?? string.Empty); }
        }

        // RVA: 0x13D7674
        NotificationFlags INotificationOptionProvider.flags
        {
            get
            {
                NotificationFlags flags = m_Retroactive
                    ? NotificationFlags.TriggerInEditMode | NotificationFlags.Retroactive
                    : NotificationFlags.TriggerInEditMode;
                if (m_EmitOnce)
                {
                    flags |= NotificationFlags.TriggerOnce;
                }
                return flags;
            }
        }

        // RVA: 0x13D769C
        public EventMarker()
        {
        }
    }
}

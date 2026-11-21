// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Timeline.EventMarker
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        get_id    : new PropertyName(EventName ?? string.Empty)
//        get_flags : TriggerInEditMode (+ Retroactive) (+ TriggerOnce)
// =============================================================================

using UnityEngine;
using UnityEngine.Timeline;

namespace Oz.Timeline
{
    public class EventMarker : Marker, INotification, INotificationOptionProvider
    {
        [field: SerializeField]
        public bool Retroactive { get; set; }
        [field: SerializeField]
        public bool EmitOnce { get; set; }
        [field: SerializeField]
        public string EventName { get; set; }
        [field: SerializeField]
        public EventData EventData { get; set; }

        // RVA: 0x13D75FC
        PropertyName INotification.id
        {
            get { return new PropertyName(EventName ?? string.Empty); }
        }

        // RVA: 0x13D7674
        NotificationFlags INotificationOptionProvider.flags
        {
            get
            {
                NotificationFlags flags = Retroactive
                    ? NotificationFlags.TriggerInEditMode | NotificationFlags.Retroactive
                    : NotificationFlags.TriggerInEditMode;
                if (EmitOnce)
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

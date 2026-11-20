// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.Enemy
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Build 创建同名根对象并挂 Enemy，Init 建立 Model/Motion 子系统；
//        SetMaterialProperty 系列转发 m_ModelSystem。
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public class Enemy : MonoBehaviour, IMaterialPropertyBlockModifier, ITimelineBinding
    {
        [SerializeField]
        private ModelSystem m_ModelSystem;
        [SerializeField]
        private MotionSystem m_MotionSystem;
        [SerializeField]
        private GameObject m_Root;
        public ModelSystem ModelSystem { get; }
        public MotionSystem MotionSystem { get; }
        public GameObject Root { get; }
        public GameObject ModelRoot { get; }

        // RVA: 0x16B0AB0
        public ModelSystem get_ModelSystem()
        {
            return m_ModelSystem;
        }

        // RVA: 0x16B0AB8
        public MotionSystem get_MotionSystem()
        {
            return m_MotionSystem;
        }

        // RVA: 0x16B0AC0
        public GameObject get_Root()
        {
            return m_Root;
        }

        // RVA: 0x16B0AC8
        public GameObject get_ModelRoot()
        {
            return m_ModelSystem.Root;
        }

        // RVA: 0x16B0AE0
        public static Enemy Build(
            string name,
            GameObject modelPrefab,
            ScaleSettings scaleSettings,
            MotionController controller)
        {
            GameObject root = new GameObject(name);
            Enemy enemy = root.AddComponent<Enemy>();
            enemy.Init(root, modelPrefab, scaleSettings, controller);
            return enemy;
        }

        // RVA: 0x16B0B98
        private void Init(
            GameObject enemyRoot,
            GameObject modelPrefab,
            ScaleSettings scaleSettings,
            MotionController controller)
        {
            m_Root = enemyRoot;
            m_ModelSystem = new ModelSystem(enemyRoot.transform, modelPrefab, scaleSettings);
            m_MotionSystem = new MotionSystem(m_ModelSystem, controller);
        }

        // RVA: 0x16B0C6C
        public void Create()
        {
            m_ModelSystem.Create();
            m_MotionSystem.Create();
        }

        // RVA: 0x16B0CAC
        public void Destroy()
        {
            m_ModelSystem.Destroy();
            m_MotionSystem.Destroy();
            Object.Destroy(gameObject);
        }

        // RVA: 0x16B0D50
        public void SetMaterialProperty(string name, float value)
        {
            m_ModelSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16B0D64
        public void SetMaterialProperty(string name, Vector4 value)
        {
            m_ModelSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16B0D78
        public void SetMaterialProperty(string name, Color value)
        {
            m_ModelSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16B0D8C
        public void ClearMaterialPropertyBlock()
        {
            m_ModelSystem.ClearMaterialPropertyBlock();
        }

        // RVA: 0x16B0DA0
        public Enemy()
        {
        }
    }
}

// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.ActorModule.Enemy
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
//        Build 创建同名根对象并挂 Enemy，Init 建立 Model/Motion 子系统；
//        SetMaterialProperty 系列转发 ModelSystem。
// =============================================================================

using UnityEngine;

namespace Oz.ActorModule
{
    public class Enemy : MonoBehaviour, IMaterialPropertyBlockModifier, ITimelineBinding
    {
        [field: SerializeField]
        public ModelSystem ModelSystem { get; private set; }
        [field: SerializeField]
        public MotionSystem MotionSystem { get; private set; }
        [field: SerializeField]
        public GameObject Root { get; private set; }
        public GameObject ModelRoot { get; }

        // RVA: 0x16B0AC8
        public GameObject get_ModelRoot()
        {
            return ModelSystem.Root;
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
            Root = enemyRoot;
            ModelSystem = new ModelSystem(enemyRoot.transform, modelPrefab, scaleSettings);
            MotionSystem = new MotionSystem(ModelSystem, controller);
        }

        // RVA: 0x16B0C6C
        public void Create()
        {
            ModelSystem.Create();
            MotionSystem.Create();
        }

        // RVA: 0x16B0CAC
        public void Destroy()
        {
            ModelSystem.Destroy();
            MotionSystem.Destroy();
            Object.Destroy(gameObject);
        }

        // RVA: 0x16B0D50
        public void SetMaterialProperty(string name, float value)
        {
            ModelSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16B0D64
        public void SetMaterialProperty(string name, Vector4 value)
        {
            ModelSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16B0D78
        public void SetMaterialProperty(string name, Color value)
        {
            ModelSystem.SetMaterialProperty(name, value);
        }

        // RVA: 0x16B0D8C
        public void ClearMaterialPropertyBlock()
        {
            ModelSystem.ClearMaterialPropertyBlock();
        }

        // RVA: 0x16B0DA0
        public Enemy()
        {
        }
    }
}

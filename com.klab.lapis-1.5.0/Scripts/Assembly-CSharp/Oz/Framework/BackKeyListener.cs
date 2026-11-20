// =============================================================================
//  Lapis Re:Lights 1.5.0 — Assembly-CSharp.dll
//  Oz.Framework.BackKeyListener
//  来源：libil2cpp.so (ARM64) Hex-Rays 伪代码 + Il2CppDumper 元数据
// =============================================================================

using System;
using LuaInterface;
using Oz.Framework.UIModule;
using Oz.GameFramework.Runtime.Resource;
using Oz.GameKit.Version;
using UnityEngine;
using UnityEngine.UI;

namespace Oz.Framework
{
    /// <summary>
    /// Android 返回键处理：优先交给 Lua 的 AndroidBackFunc，
    /// 无人处理时弹出退出确认框；短时间内连按两次则不响应。
    /// </summary>
    public class BackKeyListener : MonoBehaviour
    {
        private long timely;
        private const int BACK_KEY_DURAUTION = 500;
        private GameObject gQuit;
        private bool isShowQuit;

        // RVA: 0x13F8170
        private void Update()
        {
            if (Input.GetKeyDown(KeyCode.Escape))
            {
                ProcessAndroidBack();
            }
        }

        /// <summary>距上次记录不足 501ms 时返回 true（并按需刷新时间戳）。</summary>
        // RVA: 0x13F8534
        private bool isInShortTime()
        {
            long now = DateTime.Now.Ticks / 10000;
            if (now - timely < 501)
            {
                return true;
            }
            timely = now;
            return false;
        }

        // RVA: 0x13F81AC
        public void ProcessAndroidBack()
        {
            if (isInShortTime())
            {
                return;
            }

            if (isShowQuit)
            {
                OnClickCancel();
                return;
            }

            if (Launcher.isUpdateComplete)
            {
                if (Launcher.Instance == null)
                {
                    return;
                }
                if (Launcher.Instance.LuaMgr != null)
                {
                    bool handled;
                    using (LuaFunction func = Launcher.Instance.LuaMgr.luaState.GetFunction("AndroidBackFunc", true))
                    {
                        handled = func != null && func.Invoke<bool>();
                    }
                    if (!handled)
                    {
                        ShowCommonQuit();
                    }
                    return;
                }
            }

            // 版本更新界面：面板显示时等价于点击“确定”
            GameObject layerNode = UIManager.GetLayerNode("POPUP");
            if (layerNode == null)
            {
                return;
            }
            UIVersionControl ui = layerNode.GetComponentInChildren<UIVersionControl>();
            if (ui == null)
            {
                return;
            }
            if (ui.IsChooiceUiShow())
            {
                ui.CallClickOk();
            }
        }

        /// <summary>弹出通用退出确认框（带 OzST 字体）。</summary>
        // RVA: 0x13F866C
        public void ShowCommonQuit()
        {
            isShowQuit = true;

            if (Launcher.isUpdateComplete)
            {
                AssetRef assetRef = ResourceManager.LoadSync("UIVersionControl/PanelQuit", typeof(GameObject));
                gQuit = Object.Instantiate(assetRef.Asset as GameObject);

                AssetRef fontRef = ResourceManager.LoadSync("Font/OzST", typeof(Font));
                Font font = fontRef.Asset as Font;
                Text[] texts = gQuit.GetComponentsInChildren<Text>();
                for (int i = 0; i < texts.Length; i++)
                {
                    texts[i].font = font;
                }
            }
            else
            {
                gQuit = Object.Instantiate(Resources.Load("UIVersionControl/PanelQuit")) as GameObject;
            }

            UIManager.AttachToLayer(gQuit, "LOADING");

            Transform choiceRoot = gQuit.transform.Find("ChoiceRoot");
            Button btnOk = choiceRoot.gameObject.transform.Find("Btn_Ok").GetComponent<Button>();
            Button btnCancel = choiceRoot.gameObject.transform.Find("Btn_Cancel").GetComponent<Button>();
            btnOk.onClick.AddListener(OnClickOk);
            btnCancel.onClick.AddListener(OnClickCancel);
        }

        // RVA: 0x13F8A54
        public void ForceClose()
        {
            if (gQuit != null)
            {
                OnClickCancel();
            }
        }

        // RVA: 0x13F8ADC
        private void OnClickOk()
        {
            Launcher.Instance.Quit();
        }

        // RVA: 0x13F85F4
        private void OnClickCancel()
        {
            isShowQuit = false;
            Object.Destroy(gQuit);
            gQuit = null;
        }

        // RVA: 0x13F8C38
        public BackKeyListener()
        {
        }
    }
}

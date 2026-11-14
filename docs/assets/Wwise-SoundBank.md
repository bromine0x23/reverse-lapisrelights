# Wwise SoundBank

## 来源
资源清单中 `Oz.GameKit.Version.SoundBankInfo` 类型的对象是 Wwise SoundBank 格式的音频数据，从 `/<version>/Android/SoundBanks/<name>.bnk` 路径下载。

## 事件名
文件没有加密，但 Wwise 引擎本身的工作机制将音频事件名进行了哈希处理，需要通过事件名模式、已有的事件名进行猜测和逆向。
参见[bnnm/wwiser-utils: REVERSING WWISE NUMBERS]。

利用 wwiser-utils 逆向工具，参考剧情脚本、参数数据库的语音播放事件名，可以大致总结出语音事件的命名模式：
* `Play_<group>_<speaker>_<no><suffix>`，
* `<group>` 一般是 SoundBank 文件名，但也有存在差异的情况
* `<speaker>` 是说话人编号，推测前三位用于标识声优，第四位用于区分所配音的人物
* `<no>` 是时间线编号（或单纯的序号），一般从 `0001` 开始按顺序递增，但存在疑似废案的数据会使用 `1001` 开始的值
* `<suffix>` 是可选的，可能为 `b`、`c`、`_b`、`_c`、`_1` 等，猜测也是用于废案。
* e.g. `Play_VOX_EVT_0001_01_01_0010_0001`
  + `groug = VOX_EVT_0001_01_01`，0001号活动语音第1话
  + `speaker = 0010`，ティアラ（安齋由香里）
  + `no = 0001`，时间线顺序 `0001`

[bnnm/wwiser-utils: REVERSING WWISE NUMBERS]: https://github.com/bnnm/wwiser-utils/blob/master/doc/NAMES.md

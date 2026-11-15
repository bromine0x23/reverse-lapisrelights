# 逆向结论：游戏资源

[[_TOC_]]

## ~~资源下载~~
> 游戏已经停止运营，游戏资源已无法下载

游戏资源在 `https://prod-lapis-pack.you-zhe.com` 路径下获取，没有身份认证，但需要设置 `X-Unity-Version` 请求头：
```shell
curl -X HEAD -H "X-Unity-Version: 2019.4.26f1c1" --location "https://prod-lapis-pack.you-zhe.com/<path>"

curl -X HEAD -H "X-Unity-Version: 2019.4.26f1c1" --location "https://prod-lapis-pack.you-zhe.com/assets/products/resources"
```

## 资源清单
[manifest.md](manifest.md)

## Unity AssetBundle
[Unity-AssetBundle.md](Unity-AssetBundle.md)

## MasterData
格式：[MasterData.md](MasterData.md)

数据表：[MasterData-tables.md](MasterData-tables.md)

## Wwise SoundBank
[Wwise-SoundBank.md](Wwise-SoundBank.md)

## 卡图
Unity AssetBundle 资源中存在使用 Spine 的 2D 动画。

贴图文件未经过 premultiplied alpha 处理。

## 脚本
[Lua.md](Lua.md)
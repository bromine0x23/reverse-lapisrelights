# 角色

| 角色                                    | 组合                                               | 声优       | `CharacterRole`表ID | 三字母代号 | 语音事件编号 |
|-----------------------------------------|----------------------------------------------------|------------|---------------------|------------|--------------|
| ティアラ<br>缇亚拉<br>Tiara             | LiGHTs<br>霓光<br>LiGHTs                           | 安齋由香里 | 105                 | Tia        | 0010         |
| ロゼッタ<br>洛赛塔<br>Rosetta           | LiGHTs<br>霓光<br>LiGHTs                           | 久保田梨沙 | 104                 | Ros        | 0020         |
| ラヴィ<br>拉薇<br>Lavie                 | LiGHTs<br>霓光<br>LiGHTs                           | 向井莉生   | 102                 | Lav        | 0030         |
| アシュレイ<br>艾什莉<br>Ashley          | LiGHTs<br>霓光<br>LiGHTs                           | 佐伯伊織   | 101                 | Ash        | 0040         |
| リネット<br>莉奈特<br>Lynette           | LiGHTs<br>霓光<br>LiGHTs                           | 山本瑞稀   | 103                 | Lin        | 0050         |
| エミリア<br>艾米莉亚<br>Emilia          | IV KLORE<br>四重异奏<br>IV KLORE                   | 星乃葉月   | 301                 | Emi        | 0080         |
| あるふぁ<br>埃尔法<br>α                 | IV KLORE<br>四重异奏<br>IV KLORE                   | 嶺内ともみ | 302                 | Alp        | 0060         |
| サルサ<br>赛露莎<br>Salsa               | IV KLORE<br>四重异奏<br>IV KLORE                   | 篠原侑     | 303                 | Sal        | 0070         |
| ガーネット<br>嘉奈特<br>Garnet          | IV KLORE<br>四重异奏<br>IV KLORE                   | 中山瑶子   | 304                 | Gar        | 0090         |
| ナデシコ<br>抚子<br>Nadeshiko           | この花は乙女<br>花为乙女<br>Konohana wa Otome      | 本泉莉奈   | 401                 | Nad        | 0130         |
| ツバキ<br>椿<br>Tsubaki                 | この花は乙女<br>花为乙女<br>Konohana wa Otome      | 鈴木亜理沙 | 402                 | Tsu        | 0140         |
| カエデ<br>枫<br>Kaede                   | この花は乙女<br>花为乙女<br>Konohana wa Otome      | 大野柚布子 | 403                 | Kae        | 0150         |
| ラトゥーラ<br>菈图菈<br>Ratura          | シュガーポケッツ<br>口袋甜心<br>Sugar Pockets      | 早瀬雪未   | 501                 | Rat        | 0180         |
| シャンペ<br>香蓓<br>Champe              | シュガーポケッツ<br>口袋甜心<br>Sugar Pockets      | 広瀬世華   | 502                 | Cha        | 0200         |
| メアリーベリー<br>玛莉贝丽<br>Maryberry | シュガーポケッツ<br>口袋甜心<br>Sugar Pockets      | 赤尾ひかる | 503                 | Mar        | 0190, 0191   |
| アンジェリカ<br>安吉莉卡<br>Angelica    | Sadistic★Candy<br>小恶魔★糖果<br>Sadistic★Candy | 雨宮夕夏   | 601                 | Ang        | 0160         |
| ルキフェル<br>露西菲尔<br>Lucifer       | Sadistic★Candy<br>小恶魔★糖果<br>Sadistic★Candy | 松田利冴   | 602                 | Luc        | 0170         |
| ユエ<br>月<br>Yue                       | supernova<br>超新星<br>supernova                   | 桜木夕     | 201                 | Yue        | 0100         |
| ミルフィーユ<br>米露菲<br>Millefeuille  | supernova<br>超新星<br>supernova                   | 奥紗瑛子   | 202                 | Mil        | 0110         |
| フィオナ<br>费奥娜<br>Fiona             | supernova<br>超新星<br>supernova                   | 伊藤はるか | 203                 | Fio        | 0120         |
| エリザ<br>伊莉莎<br>Eliza               | Ray<br>星光<br>Ray                                 | 花澤香菜   | 701                 | Emi        | 0210         |
| クロエ<br>克洛伊<br>Chloe               | Ray<br>星光<br>Ray                                 | 南條愛乃   | 702                 | Chl        | 0220         |
| あんじぇ<br>安洁<br>Angers              | Ray<br>星光<br>Ray                                 | 雨宮夕夏   | 703                 | Anl        | 0161         |
| カミラ<br>卡米拉<br>Camilla             | Ray<br>星光<br>Ray                                 | 上坂すみれ | 704                 | Cam        | 0230         |
| ユズリハ<br>让叶<br>Yuzuriha            | Ray<br>星光<br>Ray                                 | 佐倉綾音   | 705                 | Yuz        | 0240         |

## 体型参数

> 来自于 `assets/products/resources/actors/avatars/<角色>/human.bdl` 包含的 ScaleSettings

- `isLoli`: 体型标记，某些场景用作通用缩放；
- `scaleRatio`: 身高比例；
- `Bip001_Head`、`Bip001_Neck`: 来自 `listScaleData` 的骨骼局部缩放；
- `breastUp`、`breastDown`、`breastLarger`、`breastSmall`: 胸部参数；

| 角色                                    | isLoli | scaleRatio | Bip001_Head | Bip001_Neck | breastUp | breastDown | breastLarger | breastSmall |
|-----------------------------------------|--------|------------|-------------|-------------|----------|------------|--------------|-------------|
| ティアラ<br>缇亚拉<br>Tiara             | ❌     | 1.0000     | 1.1111      | 0.90        | 0        | 0          | 0            | 0           |
| ロゼッタ<br>洛赛塔<br>Rosetta           | ❌     | 1.0513     | 1.0569      | 0.90        | 65       | 0          | 0            | 50          |
| ラヴィ<br>拉薇<br>Lavie                 | ❌     | 0.9615     | 1.1556      | 0.90        | 0        | 25         | 75           | 0           |
| アシュレイ<br>艾什莉<br>Ashley          | ❌     | 1.0513     | 1.0569      | 0.90        | 20       | 0          | 20           | 0           |
| リネット<br>莉奈特<br>Lynette           | ❌     | 0.9872     | 1.1255      | 0.90        | 0        | 40         | 100          | 0           |
| エミリア<br>艾米莉亚<br>Emilia          | ❌     | 1.0513     | 1.0569      | 0.90        | 60       | 0          | 80           | 0           |
| あるふぁ<br>埃尔法<br>α                 | ❌     | 0.9936     | 1.1183      | 0.90        | 0        | 0          | 0            | 0           |
| サルサ<br>赛露莎<br>Salsa               | ❌     | 0.8900     | 1.1765      | 0.85        | 0        | 0          | 0            | 0           |
| ガーネット<br>嘉奈特<br>Garnet          | ❌     | 1.0000     | 1.1111      | 0.90        | 0        | 0          | 25           | 0           |
| ナデシコ<br>抚子<br>Nadeshiko           | ❌     | 1.0256     | 1.0833      | 0.90        | 0        | 0          | 0            | 0           |
| ツバキ<br>椿<br>Tsubaki                 | ❌     | 1.0513     | 1.0569      | 0.90        | 0        | 40         | 75           | 0           |
| カエデ<br>枫<br>Kaede                   | ✅     | 0.8900     | 1.1765      | 0.85        | 0        | 0          | 0            | 0           |
| ラトゥーラ<br>菈图菈<br>Ratura          | ❌     | 1.0705     | 1.0379      | 0.90        | 20       | 0          | 40           | 0           |
| シャンペ<br>香蓓<br>Champe              | ✅     | 0.9027     | 1.1599      | 0.85        | 0        | 0          | 0            | 0           |
| メアリーベリー<br>玛莉贝丽<br>Maryberry | ✅     | 0.8900     | 1.1765      | 0.85        | 0        | 0          | 0            | 0           |
| アンジェリカ<br>安吉莉卡<br>Angelica    | ❌     | 1.1026     | 1.0078      | 0.90        | 20       | 0          | 0            | 0           |
| ルキフェル<br>露西菲尔<br>Lucifer       | ✅     | 0.9154     | 1.1438      | 0.85        | 0        | 0          | 0            | 0           |
| ユエ<br>月<br>Yue                       | ❌     | 1.0449     | 1.0634      | 0.90        | 40       | 0          | 0            | 20          |
| ミルフィーユ<br>米露菲<br>Millefeuille  | ❌     | 1.0000     | 1.1111      | 0.90        | 0        | 40         | 50           | 0           |
| フィオナ<br>费奥娜<br>Fiona             | ❌     | 1.0385     | 1.0700      | 0.90        | 65       | 0          | 0            | 50          |
| エリザ<br>伊莉莎<br>Eliza               | ❌     | 1.0577     | 1.0505      | 0.90        | 20       | 0          | 20           | 0           |
| クロエ<br>克洛伊<br>Chloe               | ❌     | 1.0385     | 1.0700      | 0.90        | 30       | 0          | 75           | 0           |
| あんじぇ<br>安洁<br>Angers              | ✅     | 0.8834     | 1.1853      | 0.85        | 0        | 0          | 0            | 0           |
| カミラ<br>卡米拉<br>Camilla             | ❌     | 1.0833     | 1.0256      | 0.90        | 0        | 0          | 0            | 60          |
| ユズリハ<br>让叶<br>Yuzuriha            | ✅     | 0.8838     | 1.2409      | 0.85        | 0        | 0          | 40           | 0           |



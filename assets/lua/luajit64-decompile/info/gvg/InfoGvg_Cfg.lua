-- chunkname: @/Users/kc-pazuran/Documents/lapiz_jp/lapiz-asset-android/Assets/Products/Lua/Info/gvg/InfoGvg_Cfg.lua

local mt = {}

mt.maxportalCfg = {}
mt.maxportalCfg["207"] = {
	5,
	4,
	4
}
mt.portalCardTag = {}
mt.portalCardTag["207"] = {
	{
		{
			1001,
			1010
		},
		{
			1001,
			1005
		},
		{
			1001,
			1009
		},
		{
			1001,
			1010
		},
		{
			1003,
			1012
		}
	},
	{
		{
			1002,
			1009
		},
		{
			1008,
			1010
		},
		{
			1002,
			1008,
			1010
		},
		{
			1002,
			1009,
			1014
		}
	},
	{
		{
			1009,
			1008
		},
		{
			1002,
			1008
		},
		{
			1002,
			1009
		},
		{
			1002,
			1009,
			1014
		}
	}
}
mt.portalCardTag["301"] = {
	{
		{
			1001,
			1010
		},
		{
			1001,
			1005
		},
		{
			1001,
			1009
		},
		{
			1001,
			1010
		},
		{
			1003,
			1012
		}
	},
	{
		{
			1002,
			1009
		},
		{
			1008,
			1010
		},
		{
			1002,
			1008,
			1010
		},
		{
			1002,
			1009,
			1014
		}
	},
	{
		{
			1009,
			1008
		},
		{
			1002,
			1008
		},
		{
			1002,
			1009
		},
		{
			1002,
			1009,
			1014
		}
	}
}
mt.portalCardTag["302"] = {
	{
		{
			1001,
			1010
		},
		{
			1001,
			1005
		},
		{
			1001,
			1009
		},
		{
			1001,
			1010
		},
		{
			1003,
			1012
		}
	},
	{
		{
			1002,
			1009
		},
		{
			1008,
			1010
		},
		{
			1002,
			1008,
			1010
		},
		{
			1002,
			1009,
			1014
		}
	},
	{
		{
			1009,
			1008
		},
		{
			1002,
			1008
		},
		{
			1002,
			1009
		},
		{
			1002,
			1009,
			1014
		}
	}
}
mt.portalCardTag["777002"] = {
	{
		{
			1001,
			1010
		},
		{
			1001,
			1005
		},
		{
			1001,
			1009
		},
		{
			1001,
			1010
		},
		{
			1003,
			1012
		}
	},
	{
		{
			1002,
			1009
		},
		{
			1008,
			1010
		},
		{
			1002,
			1008,
			1010
		},
		{
			1002,
			1009,
			1014
		}
	},
	{
		{
			1009,
			1008
		},
		{
			1002,
			1008
		},
		{
			1002,
			1009
		},
		{
			1002,
			1009,
			1014
		}
	}
}
mt.portalCardTag["777005"] = {
	{
		{
			1001,
			1010
		},
		{
			1001,
			1005
		},
		{
			1001,
			1009
		},
		{
			1001,
			1010
		},
		{
			1003,
			1012
		}
	},
	{
		{
			1002,
			1009
		},
		{
			1008,
			1010
		},
		{
			1002,
			1008,
			1010
		},
		{
			1002,
			1009,
			1014
		}
	},
	{
		{
			1009,
			1008
		},
		{
			1002,
			1008
		},
		{
			1002,
			1009
		},
		{
			1002,
			1009,
			1014
		}
	}
}
mt.portalCardTag["777008"] = {
	{
		{
			1001,
			1010
		},
		{
			1001,
			1005
		},
		{
			1001,
			1009
		},
		{
			1001,
			1010
		},
		{
			1003,
			1012
		}
	},
	{
		{
			1002,
			1009
		},
		{
			1008,
			1010
		},
		{
			1002,
			1008,
			1010
		},
		{
			1002,
			1009,
			1014
		}
	},
	{
		{
			1009,
			1008
		},
		{
			1002,
			1008
		},
		{
			1002,
			1009
		},
		{
			1002,
			1009,
			1014
		}
	}
}
mt.portalCardTag["777011"] = {
	{
		{
			1001,
			1010
		},
		{
			1001,
			1005
		},
		{
			1001,
			1009
		},
		{
			1001,
			1010
		},
		{
			1003,
			1012
		}
	},
	{
		{
			1002,
			1009
		},
		{
			1008,
			1010
		},
		{
			1002,
			1008,
			1010
		},
		{
			1002,
			1009,
			1014
		}
	},
	{
		{
			1009,
			1008
		},
		{
			1002,
			1008
		},
		{
			1002,
			1009
		},
		{
			1002,
			1009,
			1014
		}
	}
}

function mt:Init(activeId)
	self.activeId = tostring(activeId)
end

function mt:MaxPortal()
	if self.maxportalCfg[self.activeId] then
		return self.maxportalCfg[self.activeId]
	end

	return self.maxportalCfg["207"]
end

local CardTag = require("luaData/CardTag")

function mt:PortalCardTags(step, portalIdx)
	local cfg = self.portalCardTag[self.activeId]

	if cfg and cfg[step] then
		local ids = cfg[step][portalIdx]

		if ids then
			return ids
		end
	end

	return {}
end

local _stageImg_portal = {
	"UI/PageGvg/AtlasGvg/BG_gvg_list_stage_04",
	"UI/PageGvg/AtlasGvg/BG_gvg_list_stage_03",
	"UI/PageGvg/AtlasGvg/BG_gvg_list_stage_02",
	"UI/PageGvg/AtlasGvg/BG_gvg_list_stage_01",
	"UI/PageGvg/AtlasGvg/BG_gvg_list_stage_05"
}
local _stageImg = {
	"UI/PageGvg/AtlasGvg/BG_gvg_list_stage_04",
	"UI/PageGvg/AtlasGvg/BG_gvg_list_stage_03",
	"UI/PageGvg/AtlasGvg/BG_gvg_list_stage_02",
	"UI/PageGvg/AtlasGvg/BG_gvg_list_stage_01c",
	"UI/PageGvg/AtlasGvg/BG_gvg_list_stage_05c"
}

function mt:StageImagePortal(i)
	return _stageImg_portal[i]
end

function mt:StageImage(i)
	return _stageImg[i]
end

local cellitemicons = {
	complete_stage = "UIDyAtlas/ItemRarity/BG_Stat_word_07",
	complete_stage_23 = "UIDyAtlas/ItemRarity/BG_Stat_word_07",
	complete_stage_1 = "UIDyAtlas/ItemRarity/BG_Stat_word_08",
	complete_step = "UIDyAtlas/ItemRarity/BG_tower_word_03"
}

function mt:GetCellItemIcon(field)
	return cellitemicons[field]
end

local rewardTitleImg = {
	GVGHELP = "UI/Common/DlgGetAward/AtlasDlgGetAward/BG_itemget_word_03",
	GVGSTEP = "UI/Common/DlgGetAward/AtlasDlgGetAward/BG_word_stageclear_04",
	GVGSTAGE = "UI/Common/DlgGetAward/AtlasDlgGetAward/BG_word_stageclear_03"
}

function mt:GetRewardTitleIcon(field)
	return rewardTitleImg[field]
end

return mt

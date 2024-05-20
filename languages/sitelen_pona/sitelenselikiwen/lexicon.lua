-- Created for "sitelen seli kiwen" font (https://www.kreativekorp.com/software/fonts/sitelenselikiwen/)

---@class SitelenPona: string
-- TODO: use preprocess

---@type table<string, SitelenPona>
local __lexicon = {}
do
	package.loaded.romanized_lexicon   = nil
	package.loaded.cyrillization       = nil
	package.loaded.greek_transcription = nil

	---@type table<string, SitelenPona>[]
	local lexicons = {
		require("romanized_lexicon"),
		require("cyrillization"),
		require("greek_transcription"),
	}

	package.loaded.romanized_lexicon   = nil
	package.loaded.cyrillization       = nil
	package.loaded.greek_transcription = nil

	for _, _lexicon in pairs(lexicons) do
		for k, v in pairs(_lexicon) do
			__lexicon[k] = v
		end
	end
end


__lexicon["1"] = "󱥳"
__lexicon["2"] = "󱥮"
__lexicon["5"] = "󱤭"


return __lexicon

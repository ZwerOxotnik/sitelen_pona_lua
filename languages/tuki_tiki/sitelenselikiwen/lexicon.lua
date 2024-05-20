-- Created for "nasin-nanpa" font (https://github.com/ETBCOR/nasin-nanpa)

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


return __lexicon

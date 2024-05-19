-- Library to simplify text interactions with sitelen pona
-- sitelen pona: https://sona.pona.la/wiki/sitelen_pona/en
-- toki pona: https://tokipona.org
-- Maintainer: ZwerOxotnik
-- License: MIT


---@class SitelenPonaPart : table
---@field sitelen_pona SitelenPona?
---@field original string?
---@field is_add_space true?
---@field is_new_line boolean?


--[[
sitelen_pona.toki_pona_to_sitelen_pona(word: string): SitelenPona?
sitelen_pona.toki_pona_mute_to_sitelen_pona(_text: string, new_line_pattern="[^\r\n]+"): SitelenPonaPart[], boolean
sitelen_pona.ligature_sitelen_pona(parts: SitelenPonaPart[]): SitelenPonaPart[], boolean
]]


---@class SitelenPonaModule : module
local M = {
	_VERSION = "0.0.5",
	_LICENSE = "MIT",
	_SOURCE  = "https://github.com/ZwerOxotnik/sitelen_pona_lua",
	_URL     = "https://github.com/ZwerOxotnik/sitelen_pona_lua"
}


---@type table<string, SitelenPona>[]
M.__full_lexicon = require("sitelen_pona_lexicon")
local __lexicon = {}
for k, v in pairs(M.__full_lexicon) do
	__lexicon[k] = (type(v) == "table" and v[1]) or v
end
M.__lexicon = __lexicon

---@type table<string, SitelenPona>[]
local __characters_lexicon = require("characters_to_sitelen_pona")
M.__characters_lexicon = __characters_lexicon

---@type table<string, SitelenPona>[]
local __ligature_lexicon = require("sitelen_pona_kulupu")
M.__ligature_lexicon = __ligature_lexicon


-- TODO: use preprocessor
local __special_chars_length = {} -- messy workaround due to Lua bug
local __dots = {
	["。"] = true,
}
local __commas = {
	["、"] = true,
}
local __special_char_expr = "(["
local __spec_string_delimeters = {
	["「"]  = "」", -- for Chinese Simplified language
	-- ["﹁"]  = "﹂", -- for Chinese Simplified language
	["《"]  = "》", -- for Chinese Simplified language
	["«"]   = "»", -- for German language
	["『"]  = "』", -- for Japanese language
	["„"]   = "”", -- for several language
	["‚"]   = "‘", -- for several language
}
for k, v in pairs(__spec_string_delimeters) do
	local _, char
	_, _, char = k:find("([" .. k .. "])")
	__special_chars_length[char] = #k
	_, _, char = v:find("([" .. v .. "])")
	__special_chars_length[char] = #v
	__special_char_expr = __special_char_expr .. k .. v
end
for k in pairs(__dots) do
	local _, char
	_, _, char = k:find("([" .. k .. "])")
	__special_chars_length[char] = #k
	__special_char_expr = __special_char_expr .. k
end
for k in pairs(__commas) do
	local _, char
	_, _, char = k:find("([" .. k .. "])")
	__special_chars_length[char] = #k
	__special_char_expr = __special_char_expr .. k
end
__special_char_expr = __special_char_expr .. "])"


---@param word string
---@return SitelenPona?
function M.toki_pona_to_sitelen_pona(word)
	return __lexicon[word]
end


---@param _text string
---@param new_line_pattern string? # new_line_pattern
---@return SitelenPonaPart[], boolean # string[], is sitelen pona?
function M.toki_pona_mute_to_sitelen_pona(_text, new_line_pattern)
	new_line_pattern = new_line_pattern or "[^\r\n]+"
	local is_sitelen_pona = false
	local result = {}


	---@param word string
	---@return string?
	local function split_numbers(word)
		local last_part = word
		local last_result_i = 0
		while true do
			local first_i, last_i, number = last_part:find("(%d+)", last_result_i + 1)
			if first_i == nil then
				if last_result_i == 1 then
					return word
				else
					return last_part:sub(last_result_i+1, #last_part)
				end
			end

			if last_result_i < last_i then
				local prev_part = last_part:sub(last_result_i+1, first_i-1)
				local sitelen_pona_char = __lexicon[prev_part]
				if sitelen_pona_char then
					result[#result+1] = {
						sitelen_pona = sitelen_pona_char,
						original = prev_part
					}
				else
					result[#result+1] = {original = prev_part}
				end
			end

			local sitelen_pona_char = __lexicon[number]
			if sitelen_pona_char then
				result[#result+1] = {
					sitelen_pona = sitelen_pona_char,
					original = number
				}
			else
				result[#result+1] = {original = number}
			end

			last_result_i = last_i

			if last_i == #number then
				return
			end
		end
	end

	---@param word string
	---@return string?
	local function find_special_characters(word)
		local last_part = word
		local last_word_i = 1
		local last_result_i = 1
		while true do
			local first_i, last_i, char = last_part:find(__special_char_expr, last_result_i)
			if first_i == nil then
				if last_word_i == 1 then
					return split_numbers(word)
				else
					return split_numbers(last_part:sub(last_word_i, #last_part))
				end
			end

			---@cast first_i integer
			---@cast last_i integer
			local special_char_length = __special_chars_length[char]
			if special_char_length then
				if last_word_i < last_i then
					local prev_part = last_part:sub(last_result_i, last_i-1)
					last_word_i = last_i
					local sitelen_pona_char = __lexicon[prev_part]
					if sitelen_pona_char then
						result[#result+1] = {
							sitelen_pona = sitelen_pona_char,
							original = prev_part
						}
					else
						local _word = split_numbers(prev_part)
						if _word then
							result[#result+1] = {original = _word}
						end
					end
				end

				last_result_i = last_i + special_char_length
				local original_char = last_part:sub(last_word_i, last_result_i-1)
				last_word_i = last_result_i
				local sitelen_pona_char = __characters_lexicon[original_char]
				if sitelen_pona_char then
					result[#result+1] = {
						sitelen_pona = sitelen_pona_char,
						original = original_char
					}
				else
					result[#result+1] = {original = original_char}
				end
			else
				last_result_i = last_i + 1
			end

			if last_i >= #word then
				return nil
			end
		end
	end

	---@param text string
	local function add_punctuations(text)
		for char in text:gmatch(".") do
			sitelen_pona_char = __characters_lexicon[char]
			if sitelen_pona_char then
				result[#result+1] = {
					sitelen_pona = sitelen_pona_char,
					original = char,
					is_add_space = (is_end and word == nil)
				}
			else
				result[#result+1] = {
					original = char,
					is_add_space = (is_end and word == nil)
				}
			end
		end
	end

	local function parse(text)
		local _, end_i, punc, word, punc2 = text:find("^([%p]*)([^%p]*)([%p]*)")
		if punc == "" then
			punc = nil
		else
			add_punctuations(punc)
		end
		if word == "" then
			word = nil
		else
			word = find_special_characters(word)
			if word == "" then
				word = nil
			end
		end
		if punc2 == "" then
			punc2 = nil
		end

		local is_end = #text == end_i
		if word then
			local sitelen_pona = __lexicon[word]
			if sitelen_pona then
				result[#result+1] = {
					sitelen_pona = sitelen_pona,
					original = word,
					is_add_space = (is_end and punc2 == nil)
				}
			else
				result[#result+1] = {
					original = word,
					is_add_space = (is_end and punc2 == nil)
				}
			end
		end
		if punc2 then
			add_punctuations(punc2)
		end

		if not is_end then
			parse(text:sub(end_i+1, #text))
		end
	end

	for line in _text:gmatch(new_line_pattern) do -- TODO: improve, detect several new lines
		for part_text in line:gmatch("[^%s]+") do
			parse(part_text)
		end
		result[#result+1] = {
			is_new_line = true
		}
	end

	if #result > 0 and result[#result].is_new_line then
		result[#result] = nil
	end

	return result, is_sitelen_pona
end


---@param parts SitelenPonaPart[]
---@return SitelenPonaPart[], boolean # is ligatured?
function M.ligature_sitelen_pona(parts)
	local parts_copy = {}
	for i = 1, #parts do
		parts_copy[i] = parts[i]
	end

	if #parts_copy <= 1 then return parts_copy, false end

	local original_text = ""
	local ligature_length = 0
	local ligature_lexicon = __ligature_lexicon
	local i = 0
	while true do
		if i == #parts_copy then
			return parts_copy, #parts_copy ~= #parts
		end

		i = i + 1
		local part = parts_copy[i]
		if not part.sitelen_pona then
			ligature_length = 0
			ligature_lexicon = __ligature_lexicon
			original_text = ""
			goto skip
		end

		if part.original == "-" then
			if ligature_length > 0 then
				ligature_length = ligature_length + 1
			end
			goto skip
		end

		ligature_lexicon = ligature_lexicon[part.sitelen_pona] or __ligature_lexicon
		if ligature_lexicon == __ligature_lexicon then
			original_text = ""
			ligature_length = 0

			ligature_lexicon = ligature_lexicon[part.sitelen_pona]
			if ligature_lexicon == nil then
				ligature_lexicon = __ligature_lexicon
				goto skip
			end
		end

		ligature_length = ligature_length + 1

		original_text = original_text .. part.original .. " "
		if type(ligature_lexicon) == "table" then
			goto skip
		end

		local prev_i = i - ligature_length + 1
		for _ = 1, ligature_length - 1 do
			table.remove(parts_copy, prev_i)
		end
		i = prev_i
		parts_copy[i] = {
			sitelen_pona = ligature_lexicon,
			original = original_text,
			is_add_space = part.is_add_space
		}

		::skip::
	end
end


return M

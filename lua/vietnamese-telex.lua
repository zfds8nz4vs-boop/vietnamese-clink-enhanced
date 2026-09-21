-- Vietnamese Telex input for Clink.
-- Requires a Clink version with rl_buffer Lua bindings (1.1.20+).
--
-- This is a Clink-side input method. It does not use UniKey binaries.

local M = {}

local tone_marks = { s=1, f=2, r=3, x=4, j=5 }

local tone = {
    [1]={a="á",ă="ắ",â="ấ",e="é",ê="ế",i="í",o="ó",ô="ố",ơ="ớ",u="ú",ư="ứ",y="ý"},
    [2]={a="à",ă="ằ",â="ầ",e="è",ê="ề",i="ì",o="ò",ô="ồ",ơ="ờ",u="ù",ư="ừ",y="ỳ"},
    [3]={a="ả",ă="ẳ",â="ẩ",e="ẻ",ê="ể",i="ỉ",o="ỏ",ô="ổ",ơ="ở",u="ủ",ư="ử",y="ỷ"},
    [4]={a="ã",ă="ẵ",â="ẫ",e="ẽ",ê="ễ",i="ĩ",o="õ",ô="ỗ",ơ="ỡ",u="ũ",ư="ữ",y="ỹ"},
    [5]={a="ạ",ă="ặ",â="ậ",e="ẹ",ê="ệ",i="ị",o="ọ",ô="ộ",ơ="ợ",u="ụ",ư="ự",y="ỵ"},
}
local tone_upper = {
    [1]={A="Á",Ă="Ắ",Â="Ấ",E="É",Ê="Ế",I="Í",O="Ó",Ô="Ố",Ơ="Ớ",U="Ú",Ư="Ứ",Y="Ý"},
    [2]={A="À",Ă="Ằ",Â="Ầ",E="È",Ê="Ề",I="Ì",O="Ò",Ô="Ồ",Ơ="Ờ",U="Ù",Ư="Ừ",Y="Ỳ"},
    [3]={A="Ả",Ă="Ẳ",Â="Ẩ",E="Ẻ",Ê="Ể",I="Ỉ",O="Ỏ",Ô="Ổ",Ơ="Ở",U="Ủ",Ư="Ử",Y="Ỷ"},
    [4]={A="Ã",Ă="Ẵ",Â="Ẫ",E="Ẽ",Ê="Ễ",I="Ĩ",O="Õ",Ô="Ỗ",Ơ="Ỡ",U="Ũ",Ư="Ữ",Y="Ỹ"},
    [5]={A="Ạ",Ă="Ặ",Â="Ậ",E="Ẹ",Ê="Ệ",I="Ị",O="Ọ",Ô="Ộ",Ơ="Ợ",U="Ụ",Ư="Ự",Y="Ỵ"},
}

local base = {
    aa="â", aw="ă", ee="ê", oo="ô", ow="ơ", uw="ư", dd="đ",
    AA="Â", AW="Ă", EE="Ê", OO="Ô", OW="Ơ", UW="Ư", DD="Đ",
}

local unaccent = {
    ["á"]="a",["à"]="a",["ả"]="a",["ã"]="a",["ạ"]="a",
    ["ắ"]="ă",["ằ"]="ă",["ẳ"]="ă",["ẵ"]="ă",["ặ"]="ă",
    ["ấ"]="â",["ầ"]="â",["ẩ"]="â",["ẫ"]="â",["ậ"]="â",
    ["é"]="e",["è"]="e",["ẻ"]="e",["ẽ"]="e",["ẹ"]="e",
    ["ế"]="ê",["ề"]="ê",["ể"]="ê",["ễ"]="ê",["ệ"]="ê",
    ["í"]="i",["ì"]="i",["ỉ"]="i",["ĩ"]="i",["ị"]="i",
    ["ó"]="o",["ò"]="o",["ỏ"]="o",["õ"]="o",["ọ"]="o",
    ["ố"]="ô",["ồ"]="ô",["ổ"]="ô",["ỗ"]="ô",["ộ"]="ô",
    ["ớ"]="ơ",["ờ"]="ơ",["ở"]="ơ",["ỡ"]="ơ",["ợ"]="ơ",
    ["ú"]="u",["ù"]="u",["ủ"]="u",["ũ"]="u",["ụ"]="u",
    ["ứ"]="ư",["ừ"]="ư",["ử"]="ư",["ữ"]="ư",["ự"]="ư",
    ["ý"]="y",["ỳ"]="y",["ỷ"]="y",["ỹ"]="y",["ỵ"]="y",
    ["đ"]="d",
    ["Á"]="A",["À"]="A",["Ả"]="A",["Ã"]="A",["Ạ"]="A",
    ["Ắ"]="Ă",["Ằ"]="Ă",["Ẳ"]="Ă",["Ẵ"]="Ă",["Ặ"]="Ă",
    ["Ấ"]="Â",["Ầ"]="Â",["Ẩ"]="Â",["Ẫ"]="Â",["Ậ"]="Â",
    ["É"]="E",["È"]="E",["Ẻ"]="E",["Ẽ"]="E",["Ẹ"]="E",
    ["Ế"]="Ê",["Ề"]="Ê",["Ể"]="Ê",["Ễ"]="Ê",["Ệ"]="Ê",
    ["Í"]="I",["Ì"]="I",["Ỉ"]="I",["Ĩ"]="I",["Ị"]="I",
    ["Ó"]="O",["Ò"]="O",["Ỏ"]="O",["Õ"]="O",["Ọ"]="O",
    ["Ố"]="Ô",["Ồ"]="Ô",["Ổ"]="Ô",["Ỗ"]="Ô",["Ộ"]="Ô",
    ["Ớ"]="Ơ",["Ờ"]="Ơ",["Ở"]="Ơ",["Ỡ"]="Ơ",["Ợ"]="Ơ",
    ["Ú"]="U",["Ù"]="U",["Ủ"]="U",["Ũ"]="U",["Ụ"]="U",
    ["Ứ"]="Ư",["Ừ"]="Ư",["Ử"]="Ư",["Ữ"]="Ư",["Ự"]="Ư",
    ["Ý"]="Y",["Ỳ"]="Y",["Ỷ"]="Y",["Ỹ"]="Y",["Ỵ"]="Y",
    ["Đ"]="D",
}

local vowels = {
    a=true,ă=true,â=true,e=true,ê=true,i=true,o=true,ô=true,ơ=true,u=true,ư=true,y=true,
    A=true,Ă=true,Â=true,E=true,Ê=true,I=true,O=true,Ô=true,Ơ=true,U=true,Ư=true,Y=true,
}

local function utf8_chars(s)
    local out={}
    for c in s:gmatch("[\0-\127\194-\244][\128-\191]*") do out[#out+1]=c end
    return out
end


local canonical_base = {
    ["â"]="aa",["ă"]="aw",["ê"]="ee",["ô"]="oo",["ơ"]="ow",["ư"]="uw",["đ"]="dd",
    ["Â"]="AA",["Ă"]="AW",["Ê"]="EE",["Ô"]="OO",["Ơ"]="OW",["Ư"]="UW",["Đ"]="DD",
}

local tone_for_char = {}
for n,map in pairs(tone) do
    for plain,accented in pairs(map) do tone_for_char[accented]={plain,n} end
end
for n,map in pairs(tone_upper) do
    for plain,accented in pairs(map) do tone_for_char[accented]={plain,n} end
end

local function to_canonical_telex(word)
    local out={}
    for _,c in ipairs(utf8_chars(word)) do
        local t=tone_for_char[c]
        if t then
            local plain=t[1]
            local base_key=canonical_base[plain]
            out[#out+1]=base_key or plain
            out[#out+1]=({"s","f","r","x","j"})[t[2]]
        else
            local b=unaccent[c] or c
            out[#out+1]=canonical_base[b] or b
        end
    end
    return table.concat(out)
end

local function normalize_raw(word)
    local chars=utf8_chars(word)
    local out={}
    local tone_id
    local last=1
    for i,c in ipairs(chars) do
        if i==#chars and tone_marks[c] then
            tone_id=tone_marks[c]
        elseif i==#chars and c=="z" then
            tone_id=nil
        else
            out[#out+1]=unaccent[c] or c
        end
    end

    local mod={}
    local i=1
    while i<=#out do
        local key=out[i] and out[i+1] and (out[i]..out[i+1])
        if key and base[key] then
            mod[#mod+1]=base[key]
            i=i+2
        else
            mod[#mod+1]=out[i]
            i=i+1
        end
    end

    -- A tone key only acts when the syllable has at least one vowel.
    if tone_id then
        local has_vowel=false
        for _,c in ipairs(mod) do if vowels[c] then has_vowel=true break end end
        if not has_vowel then tone_id=nil end
    end
    return mod,tone_id
end

local function choose_tone_index(chars)
    local idx={}
    for i,c in ipairs(chars) do
        if vowels[c] then idx[#idx+1]=i end
    end
    if #idx==0 then return nil end
    if #idx==1 then return idx[1] end

    local first,last=chars[idx[1]],chars[idx[#idx]]
    if #idx==2 and (first=="i" or first=="I" or first=="u" or first=="U" or first=="ư" or first=="Ư")
       and (last=="a" or last=="A") then
        return idx[1]
    end
    return idx[#idx]
end

local function apply_tone(chars,tone_id)
    if not tone_id then return chars end
    local pos=choose_tone_index(chars)
    if not pos then return chars end
    local c=chars[pos]
    local map=(c:match("%u") and tone_upper[tone_id]) or tone[tone_id]
    if map and map[c] then chars[pos]=map[c] end
    return chars
end

function M.compose(word)
    if word=="" then return word end
    local chars,tone_id=normalize_raw(word)
    return table.concat(apply_tone(chars,tone_id))
end

local old_bindings={}
local installed=false

-- Shadow the raw Telex keystrokes for the word currently being composed.
-- This lets Backspace undo a Telex keystroke instead of deleting the rendered
-- Vietnamese character as a whole (e.g. "aa" -> "â", then Backspace -> "a").
local composition = nil
local backspace_binding = nil
local backspace_del_binding = nil

local function is_letter_key(c)
    return c:match("^[A-Za-z]$") ~= nil
end

local function current_word_info(rl_buffer)
    local line=rl_buffer:getbuffer()
    local cursor=rl_buffer:getcursor()
    local prefix=line:sub(1,cursor-1)
    local word_start=1
    local byte_pos=1
    for _,c in ipairs(utf8_chars(prefix)) do
        local is_word = is_letter_key(c) or unaccent[c] ~= nil
        if not is_word then
            word_start=byte_pos+#c
        end
        byte_pos=byte_pos+#c
    end
    return line,cursor,prefix,word_start,prefix:sub(word_start)
end

local function clear_composition()
    composition=nil
end

local function sync_composition(rl_buffer)
    local line,cursor,prefix,word_start,displayed=current_word_info(rl_buffer)
    if displayed=="" or cursor ~= #prefix+1 then
        composition=nil
        return
    end

    if composition
       and composition.start==word_start
       and composition.display==displayed then
        return
    end

    composition={
        start=word_start,
        raw=to_canonical_telex(displayed),
        display=displayed,
    }
end

local function replace_current_word(rl_buffer, start_pos, old_display, new_display)
    local cursor=rl_buffer:getcursor()
    rl_buffer:beginundogroup()
    rl_buffer:remove(start_pos,cursor)
    rl_buffer:setcursor(start_pos)
    rl_buffer:insert(new_display)
    rl_buffer:setcursor(start_pos+#new_display)
    rl_buffer:endundogroup()
end

local function append_telex_key(raw,key)
    -- Telex tone keys replace an existing trailing tone instead of stacking
    -- tones: "asf" behaves as "af".  Z removes a trailing tone.
    if tone_marks[key] then
        if raw:match("[sfrxj]$") then
            return raw:sub(1,-2)..key
        end
        return raw..key
    end
    if key=="z" and raw:match("[sfrxj]$") then
        return raw:sub(1,-2)
    end
    if key=="Z" and raw:match("[SFRXJ]$") then
        return raw:sub(1,-2)
    end
    return raw..key
end

local function handle_letter(rl_buffer,key)
    local old=old_bindings[key]
    if old then
        rl.invokecommand(old)
    else
        rl_buffer:insert(key)
    end

    local line,cursor,prefix,word_start,displayed=current_word_info(rl_buffer)
    if cursor ~= #prefix+1 then
        clear_composition()
        return
    end

    if composition
       and composition.start==word_start
       and composition.display==displayed:sub(1,-2) then
        composition.raw=append_telex_key(composition.raw,key)
        composition.display=M.compose(composition.raw)
        replace_current_word(rl_buffer,word_start,displayed,composition.display)
        return
    end

    -- If the word was not produced by our current composition state (for
    -- example after paste/history/completion), rebuild a best-effort state
    -- from the visible text and then accept the new key.
    composition={
        start=word_start,
        raw=to_canonical_telex(displayed:sub(1,-2)),
        display=displayed:sub(1,-2),
    }
    composition.raw=append_telex_key(composition.raw,key)
    composition.display=M.compose(composition.raw)
    replace_current_word(rl_buffer,word_start,displayed,composition.display)
end

local function handle_backspace(rl_buffer)
    sync_composition(rl_buffer)
    if not composition then
        local old=backspace_binding
        if old then rl.invokecommand(old) end
        return
    end

    if composition.raw=="" then
        clear_composition()
        local old=old_bindings.__backspace
        if old then rl.invokecommand(old) end
        return
    end

    composition.raw=composition.raw:sub(1,-2)
    composition.display=M.compose(composition.raw)

    local line,cursor,prefix,word_start,displayed=current_word_info(rl_buffer)
    replace_current_word(rl_buffer,word_start,displayed,composition.display)
    if composition.display=="" then clear_composition() end
end

local function handle_delete(rl_buffer)
    -- Delete in the middle of a word is delegated to Readline.  The shadow
    -- state is invalidated because the raw Telex stream can no longer be
    -- inferred safely after arbitrary cursor edits.
    clear_composition()
    local old=old_bindings.__delete
    if old then rl.invokecommand(old) end
end

local function transform_current_word(rl_buffer)
    sync_composition(rl_buffer)
    if not composition then return end

    local line,cursor,prefix,word_start,displayed=current_word_info(rl_buffer)
    if cursor ~= #prefix+1 then
        clear_composition()
        return
    end

    local composed=M.compose(composition.raw)
    if composed==displayed then return end

    composition.start=word_start
    composition.display=composed
    replace_current_word(rl_buffer,word_start,displayed,composed)
end

local function make_key_handler(key)
    return function(rl_buffer)
        handle_letter(rl_buffer,key)
    end
end

local function make_backspace_handler()
    return function(rl_buffer)
        handle_backspace(rl_buffer)
    end
end

local function make_delete_handler()
    return function(rl_buffer)
        handle_delete(rl_buffer)
    end
end

local function install()
    if installed then return end
    installed=true

    for c in ("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"):gmatch(".") do
        local key=string.format("%q",c)
        local old=rl.getbinding(key)
        old_bindings[c]=old
        local name="vi_telex_key_"..c
        _G[name]=make_key_handler(c)
        rl.setbinding(key,"luafunc:"..name)
    end

    -- Backspace is commonly reported as either Ctrl-H or DEL depending on
    -- the console/input path.  Bind both forms to the same semantic handler.
    backspace_binding=rl.getbinding([["\C-H"]])
    local backspace_name="vi_telex_backspace"
    _G[backspace_name]=make_backspace_handler()
    rl.setbinding([["\C-H"]],"luafunc:"..backspace_name)

    backspace_del_binding=rl.getbinding([["\C-?"]])
    if backspace_del_binding then
        rl.setbinding([["\C-?"]],"luafunc:"..backspace_name)
    end

    -- Delete is deliberately only invalidated/delegated; semantic deletion
    -- in the middle of a word is ambiguous without a full IME state model.
    old_bindings.__delete=rl.getbinding([["\e[3~"]])
    local delete_name="vi_telex_delete"
    _G[delete_name]=make_delete_handler()
    rl.setbinding([["\e[3~"]],"luafunc:"..delete_name)
end

clink.onbeginedit(install)

return M

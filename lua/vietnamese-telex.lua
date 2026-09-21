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

local lower_vowel = {
    ["A"]="a", ["Ă"]="ă", ["Â"]="â", ["E"]="e", ["Ê"]="ê", ["I"]="i",
    ["O"]="o", ["Ô"]="ô", ["Ơ"]="ơ", ["U"]="u", ["Ư"]="ư", ["Y"]="y",
}

local function vowel_lower(c)
    return lower_vowel[c] or c
end

local function choose_tone_index(chars)
    -- Vietnamese tone placement is based on the written vowel structure,
    -- not simply on "the last vowel".  In particular, that naive rule turns
    -- "ao/au/ai" into bad forms such as "aó/aú/aí".
    local idx={}
    for i,c in ipairs(chars) do
        if vowels[c] then idx[#idx+1]=i end
    end
    if #idx==0 then return nil end
    if #idx==1 then return idx[1] end

    -- gi- and qu- contain a spelling glide that must not receive the tone
    -- when it is functioning as part of the initial consonant.
    local start=1
    local first=vowel_lower(chars[idx[1]])
    local second=vowel_lower(chars[idx[2]])
    local first_char=vowel_lower(chars[1] or "")
    local second_char=vowel_lower(chars[2] or "")
    if first_char=="g" and second_char=="i" then
        start=2
    elseif first_char=="q" and second_char=="u" then
        start=2
    end

    local work={}
    for n=start,#idx do
        work[#work+1]=vowel_lower(chars[idx[n]])
    end
    if #work==0 then return idx[1] end

    local seq=table.concat(work)

    -- Three-vowel nuclei: the middle vowel carries the tone, except UYÊ,
    -- where Ê is the main vowel.  These cover iêu/yêu, oai/oao/oay,
    -- uây, uôi, uya, uyê, uơ/ưới/ươu families, etc.
    if #work==3 then
        local target=2
        if seq=="uyê" then
            target=3
        elseif seq=="uây" then
            target=2
        elseif seq=="uyu" then
            target=2
        end
        return idx[start+target-1]
    end

    -- Two-vowel nuclei whose second letter is the main vowel/glide boundary.
    -- This includes oa/oe/uê/uâ/uy and the closed diphthongs iê/yê/uô/ươ.
    local second_tone={
        oa=true, oe=true, uê=true, uâ=true, uy=true,
        iê=true, yê=true, uô=true, ươ=true,
    }
    if #work==2 then
        if second_tone[seq] then
            return idx[start+1]
        end

        -- The remaining common Vietnamese diphthongs take the tone on the
        -- first vowel: ai, ao, au, ay, âu, ây, eo, êu, ia, iu, oi, ôi,
        -- ơi, ua, ui, ưa, ưi, ưu.
        local first_tone={
            ai=true, ao=true, au=true, ay=true, âu=true, ây=true,
            eo=true, êu=true, ia=true, iu=true, oi=true, ôi=true,
            ơi=true, ua=true, ui=true, ưa=true, ưi=true, ưu=true,
        }
        if first_tone[seq] then
            return idx[start]
        end

        -- Unknown two-vowel sequences should fail conservatively toward the
        -- first vowel rather than producing malformed forms like aó/aú/aí.
        return idx[start]
    end

    -- Vietnamese orthography normally has at most three consecutive vowel
    -- letters in a syllable.  For an unexpected longer sequence, choose the
    -- central vowel rather than the final one.
    return idx[start+math.floor((#work-1)/2)]
end

local valid_onsets = {
    b=true,c=true,d=true,đ=true,g=true,h=true,k=true,l=true,m=true,n=true,p=true,
    q=true,r=true,s=true,t=true,v=true,x=true,
    ch=true,gh=true,gi=true,kh=true,ng=true,ngh=true,nh=true,ph=true,
    qu=true,th=true,tr=true,
    B=true,C=true,D=true,Đ=true,G=true,H=true,K=true,L=true,M=true,N=true,P=true,
    Q=true,R=true,S=true,T=true,V=true,X=true,
    CH=true,GH=true,GI=true,KH=true,NG=true,NGH=true,NH=true,PH=true,
    QU=true,TH=true,TR=true,
}

local valid_nuclei = {
    -- Single vowels.
    a=true, ă=true, â=true, e=true, ê=true, i=true, o=true, ô=true, ơ=true,
    u=true, ư=true, y=true,

    -- Common open/closed diphthongs and vowel pairs.
    ai=true, ao=true, au=true, ay=true, âu=true, ây=true,
    eo=true, êu=true,
    ia=true, iu=true,
    oa=true, oe=true, oi=true, ôi=true, ơi=true,
    ua=true, ui=true, ưa=true, ưi=true, ưu=true,
    uê=true, uơ=true, uy=true,

    -- Iê/uô/ươ families.
    iê=true, yê=true, uô=true, ươ=true,

    -- Common triphthongs.
    oai=true, oay=true,
    uai=true, uay=true, uây=true,
    uoi=true, uôi=true,
    ươi=true,
    iêu=true, yêu=true,
    uyê=true,
    ươu=true,

    -- A few valid orthographic sequences encountered in names/loanwords.
    iau=true, ieu=true, yeu=true,
    uya=true, uye=true, uyu=true,
}
local valid_codas = {
    c=true,ch=true,m=true,n=true,ng=true,nh=true,p=true,t=true,
    C=true,CH=true,M=true,N=true,NG=true,NH=true,P=true,T=true,
}

local function is_valid_tone_syllable(chars)
    -- Validate onset + vowel nucleus + optional Vietnamese coda.  This is a
    -- phonotactic guard, not a dictionary lookup: rejecting every unknown
    -- word would also reject names, technical terms, slang, and new words.
    local onset={}
    local nucleus={}
    local coda={}
    local seen_vowel=false

    for _,c in ipairs(chars) do
        if vowels[c] then
            if #coda>0 then return false end
            seen_vowel=true
            nucleus[#nucleus+1]=vowel_lower(c)
        elseif not seen_vowel then
            onset[#onset+1]=c
        else
            coda[#coda+1]=c
        end
    end

    if not seen_vowel then return false end

    local onset_s=table.concat(onset)
    local nucleus_s=table.concat(nucleus)
    local coda_s=table.concat(coda)

    if onset_s~="" and not valid_onsets[onset_s] then
        return false
    end
    if not valid_nuclei[nucleus_s] then
        return false
    end
    if coda_s~="" and not valid_codas[coda_s] then
        return false
    end
    return true
end

local function apply_tone(chars,tone_id)
    if not tone_id then return chars end
    if not is_valid_tone_syllable(chars) then
        return chars
    end
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

local function make_backspace_handler(original_binding)
    return function(rl_buffer)
        handle_backspace(rl_buffer, original_binding)
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
    _G[backspace_name]=make_backspace_handler(backspace_binding)
    rl.setbinding([["\C-H"]],"luafunc:"..backspace_name)

    backspace_del_binding=rl.getbinding([["\C-?"]])
    if backspace_del_binding then
        local backspace_del_name="vi_telex_backspace_del"
        _G[backspace_del_name]=make_backspace_handler(backspace_del_binding)
        rl.setbinding([["\C-?"]],"luafunc:"..backspace_del_name)
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

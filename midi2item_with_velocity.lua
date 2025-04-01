--[[
    midi2item_with_velocity by XBACT (based on midi2item by ePi)
    MIDIの音量（ベロシティ）を反映したバージョン
]]

local R = reaper

local function print(...)
    local t = {...}
    for k,v in pairs(t) do t[k] = tostring(v) end
    R.ShowConsoleMsg(table.concat(t, "\t") .. "\n")
end

local function createNewItem(track, st, ed, pitch, velocity)
    local mi = R.AddMediaItemToTrack(track)
    local take = R.AddTakeToMediaItem(mi)
    R.SetMediaItemPosition(mi, st, false)
    R.SetMediaItemLength(mi, ed - st, false)
    R.SetMediaItemTakeInfo_Value(take, "D_PITCH", pitch)
    -- ベロシティ (0-127) をアイテムボリューム (0.0-2.0) に変換
    local vol = (velocity / 127) * 2.0
    R.SetMediaItemInfo_Value(mi, "D_VOL", vol)
    return mi
end

local proj = 0
R.Undo_BeginBlock2(proj)

xpcall(function()
    local tracks = {}
    for i = 0, R.CountSelectedMediaItems(proj) - 1 do
        local item = R.GetSelectedMediaItem(proj, i)
        local take = R.GetActiveTake(item)
        if R.TakeIsMIDI(take) then
            local track = R.GetMediaItemTake_Track(take)
            local idx = R.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
            if tracks[idx] == nil then tracks[idx] = {} end
            table.insert(tracks[idx], {item = item, take = take})
        end
    end

    -- 選択アイテムがない場合の処理（元のコードと同じ）
    if next(tracks) == nil then
        for _, track in (function(proj)
            local i = -1
            local function f(_, k)
                i = i + 1
                local track = R.GetSelectedTrack(proj, i)
                if track == nil then return nil, nil end
                return i, track
            end
            return f
        end)(proj) do
            local n = R.GetTrackNumMediaItems(track)
            for i = 0, n - 1 do
                local item = R.GetTrackMediaItem(track, i)
                local take = R.GetActiveTake(item)
                if R.TakeIsMIDI(take) then
                    local track = R.GetMediaItemTake_Track(take)
                    local idx = R.GetMediaTrackInfo_Value(track, "IP_TRACKNUMBER")
                    if tracks[idx] == nil then tracks[idx] = {} end
                    table.insert(tracks[idx], {item = item, take = take})
                end
            end
        end
        if next(tracks) == nil then
            error("アイテム、もしくは有効なトラックが選択されていません.")
        end
    end

    for track_idx, items in (function(t)
        local kt = {}
        for k,v in pairs(t) do table.insert(kt, k) end
        table.sort(kt)
        local i = #kt + 1
        local function itr(t, k)
            if i < 1 then return nil end
            i = i - 1
            return kt[i], t[kt[i]]
        end
        return itr, t
    end)(tracks) do
        local notes = {}
        for i, v in ipairs(items) do
            local item_st = R.GetMediaItemInfo_Value(v.item, "D_POSITION")
            local item_ed = item_st + R.GetMediaItemInfo_Value(v.item, "D_LENGTH")
            local take = v.take
            local source_length = R.GetMediaSourceLength(R.GetMediaItemTake_Source(take))
            
            for nc = 0, select(2, R.MIDI_CountEvts(take)) - 1 do
                local ret, _, _, st_ppq, ed_ppq, _, pitch, velocity = R.MIDI_GetNote(take, nc)
                if ret == false then goto CONTINUE end
                pitch = pitch - 72
                local st_qn = R.MIDI_GetProjQNFromPPQPos(take, st_ppq)
                local ed_qn = R.MIDI_GetProjQNFromPPQPos(take, ed_ppq)
                local note = {
                    R.TimeMap2_QNToTime(proj, st_qn),
                    R.TimeMap2_QNToTime(proj, ed_qn),
                    pitch,
                    velocity  -- ベロシティを追加
                }

                -- ループ処理（元のコードと同じ）
                if note[2] <= item_st then
                    st_qn = st_qn + source_length
                    ed_qn = ed_qn + source_length
                    note[1] = R.TimeMap2_QNToTime(proj, st_qn)
                    note[2] = R.TimeMap2_QNToTime(proj, ed_qn)
                elseif note[1] < item_st then
                    note[1] = item_st
                end

                while true do
                    if item_ed <= note[1] then break end
                    if item_ed < note[2] then note[2] = item_ed table.insert(notes, note) break end
                    table.insert(notes, note)
                    st_qn = st_qn + source_length
                    ed_qn = ed_qn + source_length
                    note = {
                        R.TimeMap2_QNToTime(proj, st_qn),
                        R.TimeMap2_QNToTime(proj, ed_qn),
                        pitch,
                        velocity
                    }
                end
                ::CONTINUE::
            end
        end

        -- ソート処理（元のコードと同じ）
        table.sort(notes, function(a, b)
            if a[1] == b[1] then
                if a[2] == b[2] then
                    return a[3] > b[3]
                else
                    return a[2] < b[2]
                end
            else
                return a[1] < b[1]
            end
        end)

        local tl = {{}}
        for j, note in ipairs(notes) do
            local k = 1
            repeat
                local tr_ed = tl[k][#tl[k]]
                if tr_ed == nil then
                    tl[k][1] = note
                    break
                elseif note[1] < tr_ed[2] and tr_ed[1] < note[2] then
                    k = k + 1
                    if tl[k] == nil then tl[k] = {} end
                else
                    tl[k][#tl[k] + 1] = note
                    break
                end
            until #notes < j
        end

        for j, tr in ipairs(tl) do
            local idx = track_idx + j - 1
            R.InsertTrackAtIndex(idx, false)
            local track = R.GetTrack(proj, idx)
            for _, note in ipairs(tr) do
                createNewItem(track, note[1], note[2], note[3], note[4]) -- ベロシティを渡す
            end
        end

        local parent = R.GetTrack(proj, track_idx - 1)
        local depth = R.GetMediaTrackInfo_Value(parent, "I_FOLDERDEPTH")
        R.SetMediaTrackInfo_Value(parent, "I_FOLDERDEPTH", 1)
        R.SetMediaTrackInfo_Value(R.GetTrack(proj, track_idx + #tl - 1), "I_FOLDERDEPTH", depth - 1)
    end
end, function(err)
    print("エラーが発生しました:\n%s", err)
end)

R.UpdateArrange()
R.Undo_EndBlock2(proj, "midi2item_with_velocity", -1)
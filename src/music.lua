local music = {
    early = { 
        source = love.audio.newSource("assets/music/AlexanderEhlers-FreeMusicPack/Alexander Ehlers - Flags.mp3", "stream"),
        volume = 0.0,
    },
    mid = { 
        source = love.audio.newSource("assets/music/AlexanderEhlers-FreeMusicPack/Alexander Ehlers - Great mission.mp3", "stream"),
        volume = 0.0,
    },
    late = { 
        source = love.audio.newSource("assets/music/AlexanderEhlers-FreeMusicPack/Alexander Ehlers - Doomed.mp3", "stream"),
        volume = 0.0,
    },
}

local MAX_VOL = 0.1
local MIDGAME_LEVEL = 5
local LATEGAME_LEVEL = 8
local MUSIC_VELOCITY = 0.2

for key,musicItem in pairs(music) do
    musicItem.source:setVolume(0.0)
    musicItem.source:setLooping(true)
    musicItem.source:play()
end

local function updateVolume(sound, dt, asc)
    -- Updates sound. Makes louder if `asc` is true, quieter if `asc` is false.
    assert(dt > 0)
    if asc == true then
        if sound.volume < MAX_VOL then
            sound.volume = sound.volume + (MUSIC_VELOCITY * dt)
        end
        if sound.volume > MAX_VOL then sound.volume = MAX_VOL end
    else
        if sound.volume > 0 then
            sound.volume = sound.volume - (MUSIC_VELOCITY * dt)
        end
        if sound.volume < 0 then sound.volume = 0 end
    end
    if menuOpen then
        sound.source:setVolume(0.5 * sound.volume)
    else
        sound.source:setVolume(sound.volume)
    end

    assert(sound.volume > 0 or not asc)
    assert(sound.volume < MAX_VOL or asc)
end

function musicUpdate(dt)

    --if not level then return end
    local curLevel = level:getFloorNum()

    -- Idea: We're always playing all 3 tracks, we just fade them in and out 
    if curLevel < MIDGAME_LEVEL then
        updateVolume(music.early, dt, true)
        updateVolume(music.mid, dt, false)
        updateVolume(music.late, dt, false)
        assert(music.early.volume > 0)
    elseif curLevel < LATEGAME_LEVEL then
        updateVolume(music.early, dt, false)
        updateVolume(music.mid, dt, true) 
        updateVolume(music.late, dt, false)
        assert(music.mid.volume > 0)
    else
        updateVolume(music.early, dt, false)
        updateVolume(music.mid, dt, false)
        updateVolume(music.late, dt, true)
        assert(music.late.volume > 0)
    end
end


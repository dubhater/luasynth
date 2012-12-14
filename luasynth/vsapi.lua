local ffi = require "ffi"

local vapoursynth_h = ""
for line in io.lines("VapourSynth.h") do
  -- ffi doesn't support the C preprocessor yet, so preprocess it manually
  if not line:match("^%s*#") then
    vapoursynth_h = vapoursynth_h .. line:gsub("VS_CC ", ""):gsub("VS_API%(([^)]+)%)", "%1") .. "\n"
  end
end

ffi.cdef(vapoursynth_h)

local vs = ffi.load "vapoursynth"

local vsapi = vs.getVapourSynthAPI(3)
if vsapi == nil then error("Failed to initialize VapourSynth") end

local VSAPI = {}
VSAPI.__index = VSAPI
VSAPI._ffi_module = vs -- Ensure there's a reference somewhere so it doesn't get gc'd

function VSAPI:readEnum(prefix)
  local ret = {}
  for tok in vapoursynth_h:gmatch(" " .. prefix .. "([A-Z][A-z0-9]*)") do
    ret[tok] = ffi.C[prefix .. tok]
  end
  return ret
end

ffi.metatype("VSAPI", VSAPI)

return vsapi

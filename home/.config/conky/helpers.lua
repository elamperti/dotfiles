require 'cairo' -- requires conky build with flags BUILD_LUA_CAIRO, BUILD_LUA_IMLIB2, BUILD_LUA_RSVG
local cr

local settings = {
  cpu = {
    -- Number of CPU cores. Leave on 0 to auto-detect (if setting manually, see core_loads)
    cores = 0,
    x = 1240,
    y = 6,
    total_width = 72,
    total_height = 26,
    padding = 2,
    rows = 3,
    cols = 8
  }
}

-- Fill with as many zeros as cpu.cores if that value is hardcoded
local core_loads = {}

local function draw_cpu_core(core, x, y, w, h)
  local load = (tonumber(conky_parse("${cpu cpu".. core .."}")) or 0) / 100

  -- fill: current load
  cairo_set_source_rgba(cr, 0.3, 0.7, 0.3, 0.1 + load)
  cairo_rectangle(cr, x, y, w, h)
  cairo_fill(cr)

  -- border: trailing load
  core_loads[core] = (core_loads[core] + load) / 2
  cairo_set_source_rgba(cr, 0.3, 0.7, 0.3, math.max(core_loads[core], load) * 5)
  cairo_rectangle(cr, x, y, w, h)
  cairo_stroke(cr)
end

local function count_cores()
  -- Using nproc
  if io.popen then
      local n = tonumber(io.popen("nproc"):read())
      if n then return n end
  end

  -- Fallback method
  local n = 0
  while tonumber(conky_parse("${cpu cpu".. n .."}")) do
      n = n + 1
  end
  return n - 1
end

local base_x
local base_y
local size_x
local size_y
local offset_x
local offset_y

local function init_cpu_graph_values(core_count)
  for i=1, core_count do
    core_loads[i] = 0
  end

  -- calc
  if settings.cpu.rows == 0 or settings.cpu.cols == 0 then
    if math.fmod(core_count, 2) > 0 or math.fmod(core_count, 3) == 0 then
      settings.cpu.rows = 3
    else
      settings.cpu.rows = 2
    end

    settings.cpu.cols = math.ceil(core_count / settings.cpu.rows)
  end

  -- initial definitions
  base_x = settings.cpu.x
  base_y = settings.cpu.y
  size_x = (settings.cpu.total_width / settings.cpu.cols) - settings.cpu.padding
  size_y = (settings.cpu.total_height / settings.cpu.rows) - settings.cpu.padding
  offset_x = size_x + settings.cpu.padding
  offset_y = size_y + settings.cpu.padding
end


-- Conky functions must be preceded by `conky_`

function conky_main()
  if conky_window == nil then
    return
  end

  if settings.cpu.cores == 0 then
    local n = count_cores()
    if n > 0 then
        settings.cpu.cores = n
        init_cpu_graph_values(n)
    else
        -- Try again later
        return
    end
  end

  -- -- Create a surface to draw on
  local cs = cairo_xlib_surface_create(
    conky_window.display,
    conky_window.drawable,
    conky_window.visual,
    conky_window.width,
    conky_window.height
  )
  cr = cairo_create(cs)

  -- Rectangle border width
  cairo_set_line_width(cr, 1)

  for i=1, settings.cpu.cores do
    draw_cpu_core(
      i,
      base_x + math.floor((i - 1) / settings.cpu.rows) * offset_x, -- x
      base_y + math.fmod(i - 1, settings.cpu.rows) * offset_y, -- y
      size_x,
      size_y
    )
  end

  cairo_destroy(cr)
  cairo_surface_destroy(cs)
  cr = nil
end

-- Pads a string to the given length
function conky_pad(padding, varname)
    value = conky_parse(varname)
    return value .. string.rep(" ", math.max(padding - #value, 0))
end

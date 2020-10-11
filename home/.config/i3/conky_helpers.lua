-- Conky functions must be preceded by `conky_`

-- Pads a string to the given length
function conky_pad(padding, varname)
    value = conky_parse(varname)
    return value .. string.rep(" ", math.max(padding - #value, 0))
end

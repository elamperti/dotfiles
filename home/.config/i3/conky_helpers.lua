-- Conky functions must be preceded by `conky_`
function conky_pad(padding, varname)
    value = conky_parse(varname)
    return value .. string.rep(" ", math.max(padding - #value, 0))
end

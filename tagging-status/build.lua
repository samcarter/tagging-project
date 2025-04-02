module = "tagging-project-examples"

test_order = {'structure_test'}
-- includetests = {'**'}
checkengines = {'pdftex'}

local pdf_structure do
  local output_handle
  local env = setmetatable({
    os = setmetatable({
      exit = error,
    }, {__index = os}),
    print = function(...)
      local tostring = tostring
      for i, arg in ipairs{...} do
        if i ~= 1 then output_handle:write'\t' end
        output_handle:write(tostring(arg))
      end
      output_handle:write'\n'
    end,
  }, {__index = _ENV})
  local preload = package.preload
  preload.process_stream = loadfile('./pdf_structure/show_pdf_tags/process_stream.lua')
  preload.luapdfscanner = loadfile('./pdf_structure/show_pdf_tags/luapdfscanner.lua')
  preload.decode = loadfile('./pdf_structure/show_pdf_tags/decode.lua')
  -- package
  local mod = loadfile('./pdf_structure/show_pdf_tags/show_pdf_tags.lua', 't', env)
  function pdf_structure(target, ...)
    env.arg = {[0] = 'show_pdf_tags', ...}
    output_handle = target
    local success, err = pcall(mod)
    output_handle = nil
    return success, err
  end
end

local bundleunpack = bundleunpack
function _ENV.bundleunpack(sourcedirs, sources)
  bundleunpack(sourcedirs, sources)

  cp('**', 'testfiles', unpackdir)
end

test_types = {
  structure_test = {
    test = ".tex",
    reference = ".struct.xml",
    generated = ".pdf",
    rewrite = function(source, normalized, engine, errorcode)
      local output_file = assert(io.open(normalized, 'w'))
      if errorcode[1] == 0 then
        local success, err = pdf_structure(output_file, '--xml', source)
        if not success then
          output_file:write(string.format('<run-error err="%q" />', err))
        end
      else
        output_file:write(string.format('<run-error code="%i" />', errorcode[1]))
      end
      assert(output_file:close())
    end,
  },
}

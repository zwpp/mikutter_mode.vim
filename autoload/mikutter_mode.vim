function! mikutter_mode#onthefly_excuter_current_buffer()
  let lines = getline(0, line("$"))

  let current_plugin = s:current_plugin(lines)
  if current_plugin != ''
      call s:onthefly_excuter('Plugin.uninstall(:' . current_plugin . ')')
  endif

  let code = join(lines, "\n")
  call s:onthefly_excuter(code)
endfunction

function! s:onthefly_excuter(code)
  ruby << EOF
  require 'dbus'

  bus = DBus::SessionBus.instance
  mikutter_service = bus.service("org.mikutter.dynamic")
  client_to_mikutter = mikutter_service.object("/org/mikutter/MyInstance")
  client_to_mikutter.introspect
  eval_ruby = client_to_mikutter["org.mikutter.eval"]

  code = Vim::evaluate "a:code"
  eval_ruby.ruby([["code", code],["file", ""]])
EOF

endfunction

function! s:current_plugin(lines)
  for i in a:lines
    let plugin_name = matchstr(i, 'Plugin\(.\|::\)create.*:\zs[a-zA-Z0-9_]\+\ze.*do')
    if plugin_name != ''
      return plugin_name
    endif
  endfor
  return ''
endfunction

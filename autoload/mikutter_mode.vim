let s:rbfile = " " . expand('<sfile>:p:h') . "/mikutter_mode.rb "

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
  let command = 'ruby' . s:rbfile . shellescape(a:code)
  call system(command)
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

" metarw scheme: nowa
" Version: 0.0.1
" Copyright (C) 2008 ujihisa <http://ujihisa.nowa.jp/>
" License: MIT license  {{{
"     Permission is hereby granted, free of charge, to any person obtaining
"     a copy of this software and associated documentation files (the
"     "Software"), to deal in the Software without restriction, including
"     without limitation the rights to use, copy, modify, merge, publish,
"     distribute, sublicense, and/or sell copies of the Software, and to
"     permit persons to whom the Software is furnished to do so, subject to
"     the following conditions:
"
"     The above copyright notice and this permission notice shall be included
"     in all copies or substantial portions of the Software.
"
"     THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
"     OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
"     MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
"     IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
"     CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
"     TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
"     SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
" }}}
" Interface  "{{{1
" FIXME: metarw#nowa#complete NOT IMPLEMENTED!
"   Following is just copy from metarw-git
function! metarw#nowa#complete(arglead, cmdline, cursorpos)  "{{{2
  " a:arglead always contains "nowa:".
  let _ = s:parse_incomplete_fakepath(a:arglead)

  let candidates = []
  if _.path_given_p  " git:{commit-ish}:{path} -- complete {path}.
    for object in s:git_ls_tree(_.git_dir, _.commit_ish, _.leading_path)
      call add(candidates,
      \        printf('%s:%s%s:%s%s',
      \               _.scheme,
      \               _.git_dir_part,
      \               _.given_commit_ish,
      \               object.path,
      \               (object.type ==# 'tree' ? '/' : '')))
    endfor
    let head_part = printf('%s:%s%s:%s%s',
    \                      _.scheme,
    \                      _.git_dir_part,
    \                      _.given_commit_ish,
    \                      _.leading_path,
    \                      _.leading_path == '' ? '' : '/')
    let tail_part = _.last_component
  else  " git:{commit-ish} -- complete {commit-ish}.
    " sort by remote branches or not.
    for branch_name in s:git_branches(_.git_dir)
      call add(candidates,
      \        printf('%s:%s%s:', _.scheme, _.git_dir_part, branch_name))
    endfor
    let head_part = printf('%s:%s',
    \                      _.scheme,
    \                      _.git_dir_part)
    let tail_part = _.given_commit_ish
  endif

  return [candidates, head_part, tail_part]
endfunction




function! metarw#nowa#read(fakepath)  "{{{2
  let _ = s:parse_incomplete_fakepath(a:fakepath)
  if _.method == 'show'
    return ['read', printf('!nowa entry %s %s', _.entry_id, _.nowa_id)]
  elseif _.method == 'list'
    let s:browse = []
    for entry in split(system(printf('nowa entries %s', _.nowa_id)), "\n")
      let entry_id = split(entry, ":")[0]
      let s:browse = add(s:browse, {
      \  'label': entry,
      \  'fakepath': 'nowa:' . _.nowa_id . ':' . entry_id})
    endfor
    return ['browse', s:browse]
  else
    " TODO: error
  endif
endfunction




function! metarw#nowa#write(fakepath, line1, line2, append_p)  "{{{2
  let _ = s:parse_incomplete_fakepath(a:fakepath)
  if !!_.entry_id
    return ['write', printf('!nowa update %s %s', _.entry_id, _.nowa_id)]
  else
    return ['write', printf('!nowa create %s', _.nowa_id)]
  endif
endfunction



function! s:parse_incomplete_fakepath(incomplete_fakepath)  "{{{2
  " Return value '_' has the following items:
  "
  " Key			Value
  " ------------------  -----------------------------------------
  " given_fakepath      same as a:incomplete_fakepath
  "
  " scheme              {scheme} part in a:incomplete_fakepath (always 'nowa')
  "
  " nowa_id             'nowa:{nowa_id}:...'
  " entry_id            'nowa:...:{entry_id}' or nil
  " method		'list' or 'show'
  let _ = {}

  let fragments = split(a:incomplete_fakepath, ':', !0)
  if  len(fragments) <= 2
    echoerr 'Unexpected a:incomplete_fakepath:' string(a:incomplete_fakepath)
    throw 'metarw:nowa#e1'
  endif

  let _.given_fakepath = a:incomplete_fakepath
  let _.scheme = fragments[0]

  " {nowa_id}
  let _.nowa_id = fragments[1]

  if fragments[2] == 'list'
    let _.method = 'list'
  else
    let _.method = 'show'
    " {entry_id}
    let _.entry_id = fragments[2]
  endif

  return _
endfunction





" __END__  "{{{1
" vim: foldmethod=marker

" Copyright (C) 2004 UECHI Yasumasa

" Author: UECHI Yasumasa <uechi@.potaway.net>

" $Revision: 1.1 $

" This program is free software; you can redistribute it and/or
" modify it under the terms of the GNU General Public License as
" published by the Free Software Foundation; either version 2, or (at
" your option) any later version.

" This program is distributed in the hope that it will be useful, but
" WITHOUT ANY WARRANTY; without even the implied warranty of
" MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.	 See the GNU
" General Public License for more details.

" You should have received a copy of the GNU General Public License
" along with this program; see the file COPYING.  If not, write to the
" Free Software Foundation, Inc., 59 Temple Place - Suite 330,
" Boston, MA 02111-1307, USA.


if !exists("g:tdiary_site1_url")
	finish
endif

command! -nargs=0 TDiaryNew call <SID>TDiary_new()
command! -nargs=0 TDiaryReplace call <SID>TDiary_replace()
command! -nargs=0 TDiaryUpdate call <SID>TDiary_update()
command! -nargs=0 TDiarySelect call <SID>TDiary_select()


if !exists("g:tdiary_update_script_name")
	let g:tdiary_update_script_name = "update.rb"
endif

let s:tdiary_url = g:tdiary_site1_url
let s:mode = "append"
let s:curl_cmd = "curl"
let s:date = ''
let s:user = ''
let s:title = ''

function! s:TDiary_new()
	let s:date = ''
	call s:CreateBuffer()
	let s:mode = "append"
endfunction

function! s:TDiary_replace()
	let s:date = ''
	call s:CreateBuffer()
	let s:mode = "replace"

	let data = ' -d "'
	let data = data . s:Date2PostDate()
	let data = data . '&edit=edit" '

	call s:SetUser()

	execute 'r !' . s:curl_cmd . ' -s ' . s:user . data . s:tdiary_url . '/'. g:tdiary_update_script_name
	let save_pat = @/
	let @/ = 'input.\+name="title"[^>]\+>'
	execute "normal ggn"
	let s:title = substitute(getline("."), '.\+value="\(.*\)".\+', '\1', '')

	let @/ = 'textarea \+name="body"[^>]\+>'
	execute "normal ggdndf>"
	let @/ = '</textarea'
	execute "normal ndG"
	execute "%s///"

	silent! %s/&amp;/\&/g
	silent! %s/&quot;/\"/g
	silent! %s/&gt;/>/g
	silent! %s/&lt;/</g

	execute "normal G"
	execute "redraw!"
	let @/ = save_pat
endfunction

function! s:TDiary_update()
	" set mode
	let s:mode = input("Editing mode (append or replace): ", s:mode)
	let data = s:mode . "=" . s:mode

	" set date
	call s:SetDate()
	let data = data . s:Date2PostDate()

	" set title
	let title = input("Title for " . s:date . ": ", s:title)
	let title = s:URLencode(title)
	let data = data . "&title=" . title

	" set body
	let body = ''
	let i = 1
	let lastline = line("$")

	while i <= lastline
		let body = body . s:URLencode(getline(i) . "\r\n")
		let i = i + 1
	endwhile

	let data = data . "&body=" . body

	" debug mode
	if exists("g:tdiary_vim_debug") && g:tdiary_vim_debug
		call append("$", data)
		return
	endif

	" redirect data to tmpfile
	let tmpfile = tempname()
	execute "redir! > " . tmpfile
	silent echo data
	redir END

	" set user and password
	call s:SetUser()

	" update diary
	let result = system(s:curl_cmd . s:user . " -d @" . tmpfile . " " . s:tdiary_url . "/" . g:tdiary_update_script_name)
	call delete(tmpfile)
	redraw!
	if match(result, 'Wait or.\+Click here') != -1
		echo "SUCCESS"
	else
		echo result
	endif

endfunction


function! s:TDiary_select()
	split tDiary_select
	set buftype=nofile
	set nobuflisted
	set noswapfile

	let i = 1
	while exists("g:tdiary_site{i}_url")
		let site_name = ''
		if exists("g:tdiary_site{i}_name")
			let site_name = g:tdiary_site{i}_name . " "
		endif
		call append(i - 1, site_name . g:tdiary_site{i}_url)
		let i = i + 1
	endwhile
	normal gg

	nnoremap <buffer> <silent> <CR> :call <SID>SetURL()<CR>
endfunction


function! s:SetURL()
	let i = line(".")
	let s:tdiary_url = g:tdiary_site{i}_url
	let s:usr = ""
	close
endfunction



function! s:SetUser()
	if s:user == ''
		let s:user = input("User Name: ")
		let password = inputsecret("Password: ")
		if s:user != ''
			let  s:user = ' -u ' . s:user . ':' . password . ' '
		endif
	endif
endfunction


function! s:CreateBuffer()
	call s:SetDate()
	execute "edit " s:date
	set buftype=nofile
	set noswapfile
	set bufhidden=hide
	"set fileformat=dos
endfunction


function! s:SetDate()
	if s:date == ''
		let s:date = strftime("%Y%m%d", localtime())
	endif

	let s:date = input("Date: ", s:date)
endfunction


function! s:Date2PostDate()
	let year = strpart(s:date, 0, 4)
	let month = strpart(s:date, 4, 2)
	let day = strpart(s:date, 6, 2)

	let old = ''
	if s:mode == "replace"
		let old = "&old=" . s:date
	endif

	return  "&year=" . year . "&month=" . month . "&day=" . day . old
endfunction


function! s:URLencode(str)
	let r = iconv(a:str, &encoding, 'euc-jp')
	let save_enc = &encoding
	let &encoding = 'japan'
	let r = substitute(r, '[^ a-zA-Z0-9_.-]', '\=s:Char2Hex(submatch(0))', 'g')
	let &encoding = save_enc
	let r = substitute(r, ' ', '+', 'g')
	return r
endfunction


function! s:Char2Hex(c)
	let n = char2nr(a:c)
	let r = ''

	while n
		let r = '0123456789ABCDEF'[n % 16] . r
		let n = n / 16
	endwhile

	if strlen(r) % 2 == 1
		let r = '0' . r
	endif

	let r = substitute(r, '..', '%\0', 'g')

	return r
endfunction


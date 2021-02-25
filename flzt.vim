" -------------------------------------------------------------------------------
"
"                                      自动函数补全
"
"  ------------------------------------------------------------------------------


" 默认开启类名补全
let s:isable = 1
" 默认命名空间为空
let s:namespace = ''
" 默认保存在 ../build文件夹
let s:compath = '../build/'
" 默认开启gdb调试
let s:enable_gdb = 1
" 默认加入DEBUG宏
let s:add_debug_macro = 1
" 选项
let s:flzt_opt = {'classcomple' : 'flzt#FlztEDClassName()','namespace' : 'flzt#FlztSetNamespace('''')','exedir' : 'flzt#FlztSetExecutePath('''')','gdb' : 'flzt#FlztOptGdb()','macro' : 'flzt#FlztOptMacro()'}
"--------------------------------- function complement -----------------------------------

func! flzt#FlztEDClassName()
	if s:isable == 1
	echo "Prompt: disable class name complement."
		let s:isable = 0
	else
		echo "Prompt: enable class name complement."
		let s:isable = 1
	endif
endfunc

" 设置命名空间 
func! flzt#FlztSetNamespace(ns)
	if a:ns == ''
		let s:namespace = input("namespace: ")
	else
		let s:namespace = a:ns
	endif
	echo "current namespace: ".s:namespace
endfunc

func! flzt#FuncStr()
	let cur_str = substitute(getline('.'),';',' {','')
	let equ_symbol = match(cur_str,'=')
	let sub_part = strpart(cur_str,match(cur_str,')'),len(cur_str))
	if equ_symbol != -1
		if cur_str =~ ','
			let res_list = []
			let list = split(cur_str,',')
			for str in list 
				let temp = split(str,'=')
				call add(res_list,temp[0])
				if str != list[-1]
					call add(res_list,',')
				endif
			endfor
			let res =  trim(join(res_list)).sub_part
		else
			let res = trim(strpart(cur_str,0,equ_symbol)).sub_part
		endif
	else
		let res = cur_str	
	endif	
	return res
endfunc



" 非成员函数
func! flzt#Nonmember()
	let pattern = ['','}']
	" 把将末尾分号变成{}
	let cur_line = line('.')
	let funcName = flzt#FuncStr()
	if funcName =~ "extern"
		let res = [trim(substitute(funcName,"extern",'',''))]
	else
		let res = [funcName]
	endif

	if funcName =~ "static"
		let res = [trim(substitute(funcName,"static",'',''))]
	else
		let res = [funcName]
	endif

	let text = ''
	if funcName =~ "template"
		let text = current
	elseif getline(cur_line-1) =~ "template"
		let text = getline(cur_line-1)
	endif

	if text != ''
		let begin = stridx(text,'<')+1
		let end = strridx(text,'>') - 1
		let typeStr = strpart(text,begin,end)
		if typeStr =~ ','
			let type_list = split(typeStr,',')
			let template = 'template <'
			
			for i in range(0,len(type_list) - 1)
				if type_list[i] =~ "typename" || type_list[i] =~ "class"
					let template = template.type_list[i]
				elseif type_list[i] =~ "="
					let tmp_list = split(type_list[i],'=')
					let template = template.trim(tmp_list[0])
				endif

				if i != (len(type_list) - 1)
					let template = template.','
				endif
			endfor
			let template = template.'>'
		else
			if typeStr =~ "="
				let typeStr = trim(split(typeStr,'=')[0]).'>'
			endif
			let template = "template <".typeStr
		endif
		return ['',template] + res + pattern
	endif
	return [''] + res + pattern
	
endfunc

" 成员函数
func! flzt#Member() 
	let pattern = ['','}']
	" 当前行号
	let cur_line = line('.')
	let symbol_idx = 0
	let symbol = 1

	let commentary = trim(getline(cur_line))
	if matchend(commentary,"//") == 2 || matchend(commentary,"*") == 1
		echo "warning: It's a commentary."
		return []
	endif

	" 从当前行开始找class关键字
	for i in range(cur_line - 1,0,-1)
		let current = getline(i)
		let flag = 0	
	
		if current =~ "class"
			let flag =  1
		elseif current =~ "struct"
			let flag = 2
		endif

		if flag && current =~ "{"
			let symbol = symbol-1
		elseif flag && getline(i+1) =~ "{"
			let symbol = symbol-1
		elseif current =~ "{"
			let symbol = symbol-1
		elseif current =~"};"
			let symbol = symbol+1
		endif
	
		
		"如果该行包含class关键字
		if flag && symbol == 0
			" 模板类的情况
			let text = ''
			if current =~ "template"
				let text = trim(current)
			elseif getline(i-1) =~ "template"
				let text = trim(getline(i-1))
			endif
			
			if text != '' && matchend(text,'//') != 2 && matchend(text,'*') != 1
				let begin = stridx(text,'<')+1
				let end = strridx(text,'>') - 1
				let typeStr = strpart(text,begin,end)
				if typeStr =~ ','
					let type_list = split(typeStr,',')
					let template = 'template <'
					let typeSymbol = '< '

					for i in range(0,len(type_list) - 1)
						if type_list[i] =~ "typename" || type_list[i] =~ "class"
							let template = template.type_list[i]
							if type_list[i] =~ "template"
								let typeSymbol = typeSymbol.trim(split(type_list[i])[2])
							else
								let typeSymbol = typeSymbol.trim(split(type_list[i])[1])
							endif
						elseif type_list[i] =~ "="
							let tmp_list = split(type_list[i],'=')
							let template = template.trim(tmp_list[0])
							let typeSymbol = typeSymbol.trim(split(tmp_list[0])[1])
						endif

						if i != (len(type_list) - 1)
							let template = template.','
							let typeSymbol = typeSymbol.','
						endif
					endfor
				else
					if typeStr =~ "="
						let typeStr = trim(split(typeStr,'=')[0]).'>'
					endif

					let template = "template <".typeStr

					if typeStr =~ "typename"
						let typeStr = substitute(typeStr,"typename",'','')
					elseif typeStr =~ "class"
						let typeStr = substitute(typeStr,"class",'','')
					endif
					let tmp_list = split(typeStr)
					if len(tmp_list) > 1
						let typeStr = tmp_list[1]
					endif
					let typeSymbol = '<'.trim(typeStr)
				endif
			else
				let template = ''
				let typeSymbol = ''
			endif
		
			" class 关键字匹配结束处
			let curLineLen = strlen(current)
			" 如果该行文本仅仅只有class
			if curLineLen == matchend(current,"class") || curLineLen == matchend(current,"struct")
				" 那么该行的下一行就是类名
				let nextLine = getline(i+1)
				let text = substitute(nextLine,'{','','')
				if match(nextLine,':') != -1
					let l:className = strpart(text,0,match(nextLine,':'))
				else
					let l:className = substitute(text,' {','','')
				endif
			" 如果该行文本不仅仅只有class or struct
			else 
				if flag == 1
					let text = substitute(current,'class','','')
				elseif flag == 2
					let text = substitute(current,'struct','','')
				endif
				" 去除class关键字和多余符号
				if match(current,':') != -1
					let index = match(text,':')
					let l:className = trim(strpart(text,0,index))
				else
					if match(text,'{') != -1
						let temp = substitute(text,'{','','')
						let className = trim(strpart(temp,0,strlen(temp)))
					else
						let className = trim(strpart(text,0,strlen(text)))
					endif
				endif
			endif
				let cur_str = flzt#FuncStr()
				if cur_str =~ "static"
					let cur_str = substitute(cur_str,"static",'','')	
				endif
				if cur_str=~ "override"
					let cur_str = substitute(cur_str,"override",'','')	
				elseif cur_str =~ "final"
					let cur_str = substitute(cur_str,"final",'','')	
				endif
				let str_list = split(cur_str)
			
				if str_list[0] == "virtual"
					if str_list[-2] =~ '0'
						echo "warning: It's a pure virtual function."
						return []
					endif
					call remove(str_list,0)
				endif
				for i in range(0,len(str_list))
					if get(str_list,i) =~ '('
						if s:namespace == ''
							let str = className.typeSymbol."::".get(str_list,i)
						else
							let str = s:namespace."::".l:className.typeSymbol."::".get(str_list,i)
						endif
						call remove(str_list,i)
						call insert(str_list,str,i)
						if template == ''
							return [''] + [trim(join(str_list))] + pattern

						else
							return [''] + [template,trim(join(str_list))] + pattern
						endif
					endif
				endfor
		endif
	endfor
	return flzt#Nonmember()
endfunc

func! flzt#WriteComplement() 
	" 如果未启类名补全
	if s:isable == 0 
		" 返回结果字符串
		let res = flzt#Nonmember()
		" 如果开启类名补全
	elseif s:isable == 1
		let res = flzt#Member()
	endif
	return res
endfunc

func! flzt#IsUndefineFunction(cur_str)
	if a:cur_str == ''
		echo "warning: It's a empty line."
		return 0
	endif
	" 有括号说明是函数,必须以分号结尾
	if a:cur_str =~ '(' && a:cur_str =~ ')' && a:cur_str =~ ';'
		return 1
	else
		echo "warning: It's not an unimplemented function."
		return 0
	endif
endfunc

func! flzt#IsCppFile() 
	if expand("%:e") == 'cpp'
		return 1
	endif
	return 0
endfunc

" 函数补全
func! flzt#FlztComplement()	
	let cur_line = line('.')
	let cur_text = getline('.')
	if flzt#IsUndefineFunction(cur_text)	
		let cur_is_cpp = 0
		if flzt#IsCppFile()
			let cur_is_cpp = 1	
		endif
		" 当前源文件名
		let file = expand('%')
		let cur_file_name = strpart(file,0,strridx(file,'.')).'.cpp'
		let comp_str =  flzt#WriteComplement()
		echo cur_file_name
		" 当前源文件存在
		if findfile(cur_file_name) != '' && !cur_is_cpp 
			call writefile(comp_str,cur_file_name,'a')
		else  
			if s:namespace != ''
				echo "current namespace: ".s:namespace
				let total = line('$') - 1
			else
				let total = line('$')
			endif
			call append(total,comp_str)		
			call cursor(total+3,0)
		endif
	endif
endfunc

"  ------------------------------------------------------------------------------  End 
"
"
"  文件跳转      *.h to *.cpp
func! flzt#FlztTarget() 
	if expand("%:e") == 'cpp'
		let name = expand('%')
		let header = substitute(strpart(name,strridx(name,'/')+1,strlen(name)),'.cpp','.h','')
		if findfile(header) != ''
			if !bufexists(header) 
				execute("open ".header)
			else
				execute("b ".header)
			endif
		else
			let bufnum = bufnr('$')
			let curnum = bufnr('%')
			for i in range(1,bufnum)
				if i != curnum
					if bufname(i) =~ header
						execute("b ".bufname(i))
					endif
				endif
			endfor
		endif
	elseif expand("%:e") == 'h'
			let name = expand('%')
			let cpp = substitute(strpart(name,strridx(name,'/')+1,strlen(name)),'.h','.cpp','')
		if findfile(cpp) != ''
			if !bufexists(cpp) 
				execute("open ".cpp)
			else
				execute("b ".cpp)
			endif
		else
			let bufnum = bufnr('$')
			let curnum = bufnr('%')
			for i in range(1,bufnum)
				if i != curnum
					if bufname(i) =~ cpp
						execute("b ".bufname(i))
					endif
				endif
			endfor
		endif
	endif
endfunc

func! flzt#FlztCreateClass(cn)
	let line = line('.')
	let class = ['class '.a:cn.'{' , '' , '  public:' , '' , '  private:' , '' , '};']
	call append(line,class)
	call cursor(line+4,0)
endfunc




"---------------------------------- compile run debug-------------------------

func! flzt#FlztSetExecutePath(path)
	if a:path == ''
		let s:compath = input("please input execute dir:")
	endif
	if strridx(a:path,'/') == strlen(a:path)
		let s:compath =  a:path
	else
		let s:compath = a:path.'/'
	endif
	echo "path:".s:compath
endfunc

func! flzt#FlztOptGdb()
	if s:enable_gdb == 1
		echo "disable the compile options gdb"
		let s:enable_gdb = 0
	else
		echo "ensable the compile options gdb"
		let s:enable_gdb = 1
	endif
endfunc

func! flzt#FlztOptMacro()
	if s:add_debug_macro == 1
		echo "disable the macro DEBUG"
		let s:add_debug_macro = 0
	else
		echo "enable the macro DEBUG"
		let s:add_debug_macro = 1
	endif
endfunc

func! flzt#FlztCompileCpp(...)
	let file = bufname('%')
	let name = substitute(file,'.cpp','','')
	let opt_macro = ''
	let opt_gdb = ''
	let liblist = a:000
	let libstr = ' '

	if liblist[0] != 'null' && liblist[0] != ''
		for lib in liblist
			let opt = '-l'.lib
			let libstr = libstr.opt
		endfor
	endif


	if s:enable_gdb == 1
		let opt_gdb = ' -g'
	endif

	if s:add_debug_macro == 1
		let opt_macro = ' -D_DEBUG_'
	endif
	execute("AsyncRun clang++ ".file.opt_macro.' -o '.s:compath.name.libstr.opt_gdb)
	echo "compile finish: "."[clang++ ".file.opt_macro.' -o '.s:compath.name.libstr.opt_gdb."]"
endfunc

func! flzt#FlztRunCpp(file)
	let file = bufname('%')
	let name = substitute(file,'.cpp','','')
	if a:file =~ '/'
		execute("AsyncRun ".a:file)
	else
		execute("AsyncRun ".s:compath.a:file)
	endif
endfunc

func! flzt#FlztCompileAndRun(...)
	let file = bufname('%')
	let name = substitute(file,'.cpp','','')
	let opt_macro = 'DEBUG'
	let opt_gdb = ''
	let liblist = a:000
	let libstr = ' '

	if liblist[0] != 'null' && liblist[0] != ''
		for lib in liblist
			let opt = '-l'.lib
			let libstr = libstr.opt
		endfor
	endif

	if s:enable_gdb == 1
		let opt_gdb = ' -g'
	endif

	if s:add_debug_macro == 1
		let opt_macro = ' -DDEBUG'
	endif
	execute("AsyncRun -mode=term -pos=hide clang++ ".file.opt_macro.' -o '.s:compath.name.libstr.opt_gdb)
	echo "compile finish: "."[clang++ ".file.opt_macro.' -o '.s:compath.name.libstr.opt_gdb."]"
	execute("AsyncRun ".s:compath.name)
endfunc

func! flzt#FlztCppmanpage(type)
		execute("vert ter ++close cppman ".a:type)
endfunc  

fu! flzt#FlztDebug()
	let fname = expand("%")
	let exe_name = strpart(fname,0,strridx(fname,'.'))
	execute("packadd termdebug")
	execute("Termdebug ".s:compath.exe_name)
endfu


"--------------------------------- symbol auto pair-----------------------------
func! flzt#AutoCompleteSymbol()
    "相关映射
    ":inoremap ( ()<Left>
    :inoremap ) <c-r>=flzt#ClosePair(')')<CR>
    :inoremap { {}<Left>
    :inoremap } <c-r>=flzt#ClosePair('}')<CR>
    :inoremap [ []<Left>
    :inoremap ] <c-r>=flzt#ClosePair(']')<CR>
    :inoremap " <c-r>=flzt#DQuote()<CR>
    :inoremap ' <c-r>=flzt#SQuote()<CR>
	" 将BackSpace键映射为RemovePairs函数
    :inoremap <BS> <c-r>=flzt#RemovePairs()<CR>
	" 将回车键映射为BracketIndent函数
	:inoremap <CR> <c-r>=flzt#BracketIndent()<CR>
endfunc

func! flzt#ClosePair(char)
    if getline('.')[col('.') - 1] == a:char
        return "\<Right>"
    else
        return a:char
    endif
endfunc

"自动补全双引号
func! flzt#DQuote()
    if getline('.')[col('.') - 1] == '"'
        return "\<Right>"
    else
		if getline('.')[col('.') - 2] == '"'
			return '"'
		else
			return "\"\"\<Left>"
    endif
endfunc
"自动补全单引号
func! flzt#SQuote()
    if getline('.')[col('.') - 1] == "'"
        return "\<Right>"
    else
		if getline('.')[col('.') - 2] == "'"
			return "'"
		else
	        return "''\<Left>"
    endif
endfunc

" 按BackSpace键时判断当前字符和前一字符是否为括号对或一对引号，如果是则两者均删除，并保留BackSpace正常功能
func! flzt#RemovePairs()
	let l:line = getline(".") " 取得当前行
	let l:current_char = l:line[col(".")-1] " 取得当前光标字符
	let l:previous_char = l:line[col(".")-2] " 取得光标前一个字符

	if (l:previous_char == '"' || l:previous_char == "'") && l:previous_char == l:current_char
		return "\<delete>\<bs>"
	elseif index(["(", "[", "{"], l:previous_char) != -1
		" 将光标定位到前括号上并取得它的索引值
		execute "normal! h"
		let l:front_col = col(".")
		" 将光标定位到后括号上并取得它的行和索引值
		execute "normal! %"
		let l:line1 = getline(".")
		let l:back_col = col(".")
		" 将光标重新定位到前括号上
		execute "normal! %"
		" 当行相同且后括号的索引比前括号大1则匹配成功
		if l:line1 == l:line && l:back_col == l:front_col + 1
			return "\<right>\<delete>\<bs>"
		else
			return "\<right>\<bs>"
		end
	else
	  	return "\<bs>"
	end
endfunc

" 在大括号内换行时进行缩进
func! flzt#BracketIndent()
	let l:line = getline(".")
	let l:current_char = l:line[col(".")-1]
	let l:previous_char = l:line[col(".")-2]

	if l:previous_char == "{" && l:current_char == "}"
		return "\<cr>\<esc>\ko"
	else
		return "\<cr>"
	end
endfunc

func! flzt#FlztOptList()
	let opt_list = items(s:flzt_opt)
	for opt in opt_list
		echo opt
	endfor
endfunc

func! flzt#FlztOpt(opt) 
	if has_key(s:flzt_opt,a:opt)
		let flzt_func = get(s:flzt_opt,a:opt)
		execute("call ".flzt_func)
	else
		echo "error: undifine option..."
	endif
endfunc


func! flzt#InitFlzt()

" 默认开启类名补全
noremap <leader>/ : call flzt#FlztComplement() <CR>
command! -nargs=0 Target :call flzt#FlztTarget()
command! -nargs=0 Flztcn :call flzt#FlztEDClassName()
command! -nargs=1 Flztsns :call flzt#FlztSetNamespace(<f-args>)
command! -nargs=0 Flztcomp :call flzt#FlztComplement()
command! -nargs=1 Flztclass :call flzt#FlztCreateClass(<f-args>)

command! -nargs=1 Flztexedir :call flzt#FlztSetExecutePath(<f-args>)
command! -nargs=+ Flztcc :call flzt#FlztCompileCpp(<f-args>)
command! -nargs=1 Flztrun :call flzt#FlztRunCpp(<f-args>)
command! -nargs=+ Flztcr :call flzt#FlztCompileAndRun(<f-args>)
command! -nargs=0 Flztdebug :call flzt#FlztDebug()
command! -nargs=1 Flztman :call flzt#FlztCppmanpage(<f-args>)

command! -nargs=0 FlztOptList :call flzt#FlztOptList()
command! -nargs=1 FlztOpt :call flzt#FlztOpt(<f-args>)

endfunc

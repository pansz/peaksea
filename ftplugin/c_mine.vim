setlocal nowrap
iab u8 uint8_t
iab i8 int8_t
iab u16 uint16_t
iab i16 int16_t
iab u32 uint32_t
iab i32 int32_t
iab u64 uint64_t
iab i64 int64_t

noremap <buffer> <C-]> g<C-]>
nmap <buffer> g<C-]> :cs find 1 <C-R>=expand("<cword>")<CR><CR>
nmap <buffer> <C-_> :cs find 0 <C-R>=expand("<cword>")<CR><CR>

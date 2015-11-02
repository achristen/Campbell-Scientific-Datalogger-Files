;+ 
; name: 
;   csi_check_tagnames.pro 
; 
; purpose: 
;   for automatic generation of tag-names of structures. removes 
;   illegal characters and makes similar tags unique by adding numbers.
;   allowed ascii characters are letters a to z [65 to 90], numbers 0 to 9 
;   [48 to 57] and the underscore [95]. all tag_names will be first converted
;   to uppercase.
;
; category:
;   general tools
;
; calling sequence: 
;   data=csi_check_tagnames(tag_names) 
; 
; inputs: 
;   tag_names  : string-array. tag-names to refrain for structure
;
; output: 
;   tag_names  : string-array. refrained rag names.
;
; example 
;   print, csi_check_tagnames('five[5]%illegal (chars)') 
;   print, csi_check_tagnames(['a','b','a'])
; 
; revision history: 
;   may-16-2007 ac 
;- 

function csi_check_tagnames, tag_names

  tag_names=strupcase(tag_names)
  ni=n_elements(tag_names)
  
  ;##########################################
  ;# check for illegal characters           #
  ;##########################################
  
  for i=0, ni-1 do begin
   tagb=byte(tag_names[i])
   legal=where((tagb ge 48 and tagb le 57) $
            or (tagb ge 65 and tagb le 90) $
            or (tagb eq 95), cnt)
   if cnt gt 0 then begin
    tag_names[i]=string(tagb[legal])
   endif else tag=strupcase('illegalcharsonly')
  endfor
   
  ;##########################################
  ;# make unique tags                       #
  ;##########################################
  
  for i=0, ni-1 do begin
   multiple=where(tag_names eq tag_names[i], cnt)
   if cnt gt 1 then begin
    for j=0, cnt-1 do begin
      tag_names[multiple[j]]=tag_names[multiple[j]]+'_'+strcompress(string(j+1),/remove_all)
    endfor
   endif
  endfor
  
  return, strcompress(tag_names,/remove_all)

end

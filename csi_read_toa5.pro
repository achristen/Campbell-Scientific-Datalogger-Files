;+ 
; name: 
;   csi_read_toa5.pro 
; 
; purpose: 
;   reads campbell ascii toa5 files (created by loggernet / dataloggers) into
;   an idl-structure. each tag of the strcture corresponds to an array [t]
;   of a field.
;
; category:
;   campbell scientific file formats
;
; calling sequence: 
;   data=csi_read_toa5(file,header=header) 
;
; inputs: 
;   file      : string. full path of toa5 file.
;
; kewords:
;   header    : set to a non-zero parameter to return toa5 fiele header information
;               in a structure (see #csi_tob1_header.pro# for
;               details)
;   julian    : set to add a tag 'julday' to the sturcture that
;               contains the time axis as julian date (see julday).
;
; output: 
;   structure : with tags
;               tag names and data formats from header of toa5 file
;
; subroutines:
;  #csi_header#
;  #tls_check_tagnames#
;
; reference:
;   jon trauntvein, 'campbell scientific data file formats', version 1.1.1.10
; 
; example: 
;   data=csi_read_toa5(dialog_pickfile())
;   help, data, /stru
;   ;get header
;   header=1
;   data=csi_read_toa5(dialog_pickfile(),header=header)
;   help, header, /stru
;   
; revision history: 
;   may-16-2007 ac 
;   aug-03-2007 ac keyword julian added.
;   mar-20-2009 ac allows fractional seconds to be considered.
;- 

function csi_read_toa5, file, header=header, julian=julian
  
  fileinfo=file_info(file)
  if fileinfo.read eq 0 then begin
   message, 'file not existing or no read access: '+file, /informational
   return, !values.f_nan
  endif

  ;##########################################
  ;# read file header                       #
  ;##########################################

  header = csi_header(file)
  if strupcase(header.file_type) ne strupcase('toa5') then begin
   message, 'illegal file format (toa5 expected): '+file, /informational
   return, !values.f_nan
  endif
  data_block_len = fileinfo.size-header.header_bytes

  ;##########################################
  ;# calculating size of 1 record fields    #
  ;##########################################

  n_cols = n_elements(header.field_names)

  ;##########################################
  ;# calculating number of records in file  #
  ;##########################################

  line=''
  n_rec=0l
  openr, lun, file, /get_lun
  for i=0, 4 do readf, lun, line ; skip header
  while not eof(lun) do begin
    readf, lun, line
    n_rec=n_rec+1
  endwhile
  
  ;##########################################
  ;# creating output structure              #
  ;##########################################

  tag_names = tls_check_tagnames(header.field_names)
  
  if ((strlowcase(tag_names[0]) eq 'timestamp') or (strlowcase(header.field_units[0]) eq 'text')) then default='' else default=!values.f_nan
  data = create_struct(tag_names[0],replicate(default,n_rec))
  
  for i=1l, n_cols-1 do begin
   if ((strlowcase(tag_names[i]) eq 'timestamp') or (strlowcase(header.field_units[i]) eq 'text')) then default='' else default=!values.f_nan
   data  = create_struct(data,tag_names[i],replicate(default,n_rec))
  endfor

  ;##########################################
  ;# reading data block in file             #
  ;##########################################

  point_lun, lun, 0
  for i=0, 3 do readf, lun, line ; skip header
  for r=0l, n_rec-1 do begin
    readf, lun, line
    strvalues = strsplit(line,',',/extract)
    for c=0l, n_cols-1 do begin 
      if strpos(strvalues[c],'"') ne -1 then $
       strvalues[c]=(strmid(strvalues[c],1,strlen(strvalues[c])-2)) ; remove "__"
       data.(c)[r] = strvalues[c]
    endfor 
  endfor

  close, lun, /FORCE
  free_lun, lun, /FORCE

  ;##########################################
  ;# optionally create julian axis          #
  ;##########################################
  
  if keyword_set(julian) then begin
  
    if strlowcase(header.field_names(0)) eq 'timestamp' then begin
    
      timesplit=fltarr(6,n_rec)
      for i=0L,n_rec-1 DO begin
        timesplit[0:5,i]=strsplit(data.timestamp(i), '-: ', /extract)
      endfor
      
      timesplit=float(timesplit)
      julianarray=julday(timesplit[1,*],timesplit[2,*],timesplit[0,*],timesplit[3,*],timesplit[4,*],timesplit[5,*])
      data  = create_struct(data,strupcase('julday'),transpose(julianarray))
      
    endif else begin
    
      year_pos = where(strlowcase(tag_names) eq 'year',ycnt)
      doy_pos  = where(strlowcase(tag_names) eq 'doy' ,dcnt)
      time_pos = where(strlowcase(tag_names) eq 'time',tcnt)
         
      if ycnt eq 1 and dcnt eq 1 and tcnt eq 1 then begin

        day_mon = csi_doy2dat(data.(doy_pos),data.(year_pos))
        hour = reform(floor(float(data.(time_pos)) / 100))
        minute = reform(data.(time_pos) mod 100)

        julianarray=julday(reform(day_mon[0,*]),reform(day_mon[1,*]),reform(data.(year_pos)[*]),hour[*],minute[*],0)  
        data  = create_struct(data,strupcase('julday'),julianarray)

      endif
 
    endelse
   

  endif

  return, data

end

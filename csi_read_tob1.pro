;+ 
; name: csi_read_tob1.pro 
; 
; purpose: 
;   reads campbell binary tob1 files (created by loggernet / dataloggers) into
;   an idl-structure, where each tag of the strcture corresponds to an array [t]
;   of a field.
;
; category:
;   campbell scientific file formats
;
; calling sequence: 
;   data=csi_read_tob1(file,header=header) 
;
; inputs: 
;   file      : string. full path of tob1 file.
;
; kewords:
;   header    : set to a non-zero parameter to return tob1 fiel header information
;               in a structure (see #csi_tob1_header.pro# for
;               details)
;   julian    : set to add a tag 'julday' to the sturcture that
;               contains the time axis as julian date (see julday).
;
; output: 
;   structure : with tags
;               tag names and data formats from header of tob1 file
;               'julday': julday time axis (if seconds
;               are present and keyword julina set)
;
; subroutines:
;  #csi_tob_datatypes#
;  #csi_fs2#
;  #csi_header#
;  #tls_check_tagnames#
;
; reference:
;   jon trauntvein, 'campbell scientific data file formats', version 1.1.1.10
; 
; example: 
;   data=csi_read_tob1(dialog_pickfile())
;   help, data, /stru
;   ;get header
;   header=1
;   data=csi_read_tob1(dialog_pickfile(),header=header)
;   help, header, /stru
;   
; revision history: 
;   may-16-2007 ac 
;   jun-14-2010 ac - changed type of rec_len from byte to long to allow for
;                    reading files with record-lenths > 255 (bug-fix)
;- 

function csi_read_tob1, file, header=header, julian=julian
  
  fileinfo=file_info(file)
  if fileinfo.read eq 0 then begin
   message, 'file not existing or no read access: '+file, /informational
   return, !values.f_nan
  endif

  ;##########################################
  ;# read file header                       #
  ;##########################################

  header = csi_header(file)
  if strupcase(header.file_type) ne strupcase('tob1') then begin
   message, 'illegal file format (tob1 expected): '+file, /informational
   return, !values.f_nan
  endif
  data_block_len = fileinfo.size-header.header_bytes

  ;##########################################
  ;# calculating size of 1 record in bytes  #
  ;##########################################

  n_cols = n_elements(header.field_names)
  record_bytes=long(csi_tob_datatypes(header.data_types[0],/bytes))
  for i=1l, n_cols-1 do begin
   record_bytes=record_bytes+csi_tob_datatypes(header.data_types[i],/bytes)
  endfor

  ;##########################################
  ;# calculating number of records in file  #
  ;##########################################

  n_rec=floor(long64(data_block_len)/record_bytes)

  ;##########################################
  ;# creating output structure              #
  ;##########################################

  tag_names = tls_check_tagnames(header.field_names)
  data = create_struct(tag_names[0],replicate(csi_tob_datatypes(header.data_types[0],/equivalent),n_rec))
  for i=1l, n_cols-1 do begin
   data  = create_struct(data,tag_names[i],replicate(csi_tob_datatypes(header.data_types[i],/equivalent),n_rec))
  endfor

  ;##########################################
  ;# creating template structure for readu  #
  ;##########################################

  template = create_struct(tag_names[0],csi_tob_datatypes(header.data_types[0],/template))
  for i=1l, n_cols-1 do begin
   template  = create_struct(template,tag_names[i],csi_tob_datatypes(header.data_types[i],/template))
  endfor

  ;##########################################
  ;# reading data block in file             #
  ;##########################################


  openr, lun, file, /get_lun
  point_lun, lun, long(header.header_bytes) ;skip header

  for r=0l, n_rec-1 do begin
   for c=0l, n_cols-1 do begin
    dummy=template.(c)
    readu,lun,dummy
    data.(c)[r]=csi_tob_datatypes(header.data_types[c],dummy)
   endfor
  endfor
  
  ; /FORCE added BC 10 May 2008
    ;there have been frequent file close errors with the new micromet server.  This forces files to close, but there is some danger of data loss.
  close, lun, /FORCE
  free_lun, lun, /FORCE

  ;##########################################
  ;# creating julday time axis (optional)   #
  ;##########################################

  if keyword_set(julian) then begin
    dummy=where(strlowcase(tag_names(data)) eq 'seconds',scnt)
    dummy=where(strlowcase(tag_names(data)) eq 'nanosec',ncnt)
    if scnt eq 1 then begin
      if ncnt eq 1 then begin
        julianarray=(double(data.seconds)+(double(data.nanosec)/1000000)/(60l*60*24))+julday(1,1,1990,0,0,0)
      endif else begin
        julianarray=(double(data.seconds)/(60l*60*24))+julday(1,1,1990,0,0,0)
      endelse
      data  = create_struct(data,strupcase('julday'),julianarray)
    endif
  endif

  return, data

end

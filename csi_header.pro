;+ 
; name: 
;   csi_header
; 
; purpose: 
;   reads campbell ascii toa5 and tob 1 headers into a structure.
;
; category:
;   campbell scientific file formats
;
; calling sequence: 
;   header=csi_header(file) 
;
; inputs: 
;   file      : string. full path of toa5 or tob1 file.
;
; output: 
;   structure : with tags
;               tag names and data formats from header of toa5 file
;   
;   file_type        string    name of file typ e.g. 'tob1' or 'toa5'
;   station_name     string    name of station as indicated in logger program
;   model_name       string    logger model type (e.g. 'cr3000')
;   serial_number    string    logger serial no
;   os_version       string    logger os version
;   dld_name         string    logger program e.g. 'cpu:mpb1csatprf024.cr3'
;   dld_signature    string    logger program signature
;   table_name       string    table name
;   field_names      strarr    names of all fields (array)
;   field_units      strarr    physical units of all fields (array)
;   field_processing string    averaging procedure of all fields (array)
;   data_types       string    data type of all fields (array, tob1 only)
;   header_bytes     long      total number of heeader bytes
;
; reference:
;   jon trauntvein, 'campbell scientific data file formats', version 1.1.1.10
; 
; example: 
;    file=dialog_pickfile()
;    header=csi_header(file)
;    help, header, /stru
;   
; revision history: 
;   may-16-2007 ac 
;- 


function csi_header, file

  line         = ''          ;default string
  header_bytes = 0l          ;parameter for length of ascii header

  ;#########################
  ;# read first line       #
  ;#########################

  openr, lun, file, /get_lun
  readf, lun, line
  header_bytes   = header_bytes+strlen(line)+2 ;add single line lengths plus crlf
  z1 = strsplit(line,',',/extract)

  file_type=strlowcase(strmid(z1[0],1,strlen(z1[0])-2))
  case file_type of ;determine file format
   'tob1' : header_lines=5
   'toa5' : header_lines=4
   else   : return, create_struct('file_type','unknown')
  endcase

  ;#########################
  ;# read next lines       #
  ;#########################

  asc_head = strarr(header_lines-1)  
  for i=0, header_lines-2 do begin
    readf, lun, line
    asc_head[i] = line
    header_bytes   = header_bytes+strlen(asc_head[i])+2
  endfor
  close, lun
  free_lun, lun

  ;#########################
  ;# splitting into tags   #
  ;#########################

  n_fields = n_elements(strsplit(asc_head[0],',',/extract))
  z = strarr(header_lines-1,n_fields)
  for i=0, header_lines-2 do begin
     if n_elements(strsplit(asc_head[i],',',/extract)) ne n_fields then $
       message, 'error in header of '+file
     z[i,*] = strsplit(asc_head[i],',',/extract)
  endfor

  ;#########################
  ;# creating structure    #
  ;#########################

  header={$  ;header line 1 
             file_type          : '', $
             station_name       : '', $
             model_name         : '', $
             serial_number      : '', $
             os_version         : '', $
             dld_name           : '', $
             dld_signature      : '', $
             table_name         : '', $
             $;header line 2
             field_names        : strarr(n_fields), $
             $;header line 3
             field_units        : strarr(n_fields), $
             $;header line 4
             field_processing   : strarr(n_fields)}

   if file_type eq 'tob1' then header = create_struct(header,'data_types',strarr(n_fields))
   header = create_struct(header,'header_bytes',header_bytes)

  ;#########################
  ;# filling structure     #
  ;#########################

  ;header line 1
  for i=0, 7 do header.(i) = strupcase(strmid(z1[i],1,strlen(z1[i])-2))

  ;header line 2-5
  for i=0,n_fields-1 do header.field_names[i]      = strupcase(strmid(z[0,i],1,strlen(z[0,i])-2))
  for i=0,n_fields-1 do header.field_units[i]      = strupcase(strmid(z[1,i],1,strlen(z[1,i])-2))
  for i=0,n_fields-1 do header.field_processing[i] = strupcase(strmid(z[2,i],1,strlen(z[2,i])-2))
  if file_type eq 'tob1' then begin
     for i=0,n_fields-1 do header.data_types[i]       = strupcase(strmid(z[3,i],1,strlen(z[3,i])-2))
  endif
  
  return, header

end

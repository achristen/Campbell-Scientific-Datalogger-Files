;+ 
; name: 
;   csi_tob_datatypes.pro 
; 
; purpose: 
;   subroutine to look-up data type properties and conversions used in the campbell scientific
;   tob (table-oriented binary) formats (see also #csi_read_tob1.pro#)
;
; category:
;   campbell scientific file formats
;
; calling sequence: 
;   value=csi_tob_datatypes(typestring,[value]) 
; 
; inputs: 
;   typestring  : string. valid tob data type sting.
;   value       : array or number. optional. binary value read from file (format must be
;                 the same as readu_template of the data type). if this parameter is present,
;                 the binary value will be converted into an idl number.
; keywords:
;    bytes      : retuns the number of bytes the data type uses in the tob file
;    equivalent : returns the idl equivalent of this data type (for creating variables)
;    template   : returns a dummy parameter as template to read the binary data step by step
;                 using readu.
;
; output: 
;   depends on keyword set (see above)
;
; subroutines:
;  #csi_fs2#
;
; reference:
;   jon trauntvein, 'campbell scientific data file formats', version 1.1.1.10
; 
; revision history: 
;   may-16-2007 ac 
;- 

function csi_tob_datatypes, typestring, value, $
         bytes=bytes, equivalent=equivalent, template=template

  case strlowcase(typestring) of
  'ieee4'  : begin
             bytes_in_file=byte(4)
             readu_template=float(0)
             idl_equivalent=float(0)
             if n_params() gt 1 then value=value
             end
  'ieee4l' : begin ;not tested yet
             bytes_in_file=byte(4)
             readu_template=float(0)
             idl_equivalent=float(0)
             if n_params() gt 1 then value=value
             end
  'ulong'  : begin
             bytes_in_file=byte(4)
             readu_template=ulong(0)
             idl_equivalent=ulong(0)
             if n_params() gt 1 then value=value
             end
  'long'   : begin ;not tested yet
             bytes_in_file=byte(4)
             readu_template=long(0)
             idl_equivalent=long(0)
             if n_params() gt 1 then value=value
             end
  'fp2'    : begin
             bytes_in_file=byte(2)
             readu_template=bytarr(2)
             idl_equivalent=float(0)
             if n_params() gt 1 then value=csi_fs2(value)
             end
  'uint4'  : begin
             bytes_in_file=byte(4)
             readu_template=ulong(0)
             idl_equivalent=ulong(0)
             if n_params() gt 1 then value=value
             end
  else     : message, 'error: unknown data type in tob file header.'
  endcase

  if keyword_set(bytes) then return, bytes_in_file else begin
   if keyword_set(equivalent) then return, idl_equivalent else begin
    if keyword_set (template) then return, readu_template else begin
     return, value
    endelse
   endelse
  endelse

end

Campbell-Scientific-Datalogger-Files
====================================

Code in the commercial Interactive Data Language (IDL) to read Campbell Scientific TOB1 and TOA5 data files 
into an IDL structure and attribute a continuous julian time axis.

Top-level routines
====================================

csi_read_toa5.pro
------------------------------------

Reads a campbell ascii toa5 file (created by loggernet / dataloggers) into
an idl-structure. each tag of the strcture corresponds to an array [t]
of a field. Optionally create a julian time axis from year, day of year,
and decimal time.

csi_read_tob1.pro
------------------------------------

Reads a campbell binary tob1 file (created by loggernet / dataloggers) into
an idl-structure, where each tag of the strcture corresponds to an array [t]
of a field. Optionally create a julian time axis from year, day of year,
and decimal time

Sub-routines
====================================

Subroutines are called from 'csi_read_tob1.pro' and 'csi_read_toa5.pro'

* csi_header.pro - reads the header of TOB1 and TOA5 files
* csi_fs2.pro - determines file types
* csi_doy2dat.pro - date handling
* csi_months.pro - date handling
* csi_leapyear.pro - date handling


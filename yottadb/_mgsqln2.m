%mgsqln2 ;(CM) MGSQL odbc ; 17 dec 2003  3:15 pm
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2021 M/Gateway Developments Ltd,                      |
 ;  | Surrey UK.                                                               |
 ;  | All rights reserved.                                                     |
 ;  |                                                                          |
 ;  | http://www.mgateway.com                                                  |
 ;  |                                                                          |
 ;  | Licensed under the Apache License, Version 2.0 (the "License"); you may  |
 ;  | not use this file except in compliance with the License.                 |
 ;  | You may obtain a copy of the License at                                  |
 ;  |                                                                          |
 ;  | http://www.apache.org/licenses/LICENSE-2.0                               |
 ;  |                                                                          |
 ;  | Unless required by applicable law or agreed to in writing, software      |
 ;  | distributed under the License is distributed on an "AS IS" BASIS,        |
 ;  | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. |
 ;  | See the License for the specific language governing permissions and      |
 ;  | limitations under the License.                                           |
 ;  ----------------------------------------------------------------------------
 ;
a d vers^%mgsql("%mgsqln2") q
 ;
typ(dbid,data,%zi,%zo) ; data types
 n tname,r,sn,cn,cols,dtyp,i,x,error
 new $ztrap set $ztrap="zgoto "_$zlevel_":type^%mgsqln2"
 d nv^%mgsqln(data,.nv)
 s error=""
 k ^mgsqls($j,%zi(0,"stmt"))
 s tname="DATA_TYPE"
 s cn=0
 s cn=cn+1,a(cn)="TYPE_NAME"            ;  1
 s cn=cn+1,a(cn)="DATA_TYPE"            ;  2
 s cn=cn+1,a(cn)="COLUMN_SIZE"          ;  3
 s cn=cn+1,a(cn)="LITERAL_PREFIX"       ;  4
 s cn=cn+1,a(cn)="LITERAL_SUFFIX"       ;  5
 s cn=cn+1,a(cn)="CREATE_PARAMS"        ;  6
 s cn=cn+1,a(cn)="NULLABLE"             ;  7
 s cn=cn+1,a(cn)="CASE_SENSITIVE"       ;  8
 s cn=cn+1,a(cn)="SEARCHABLE"           ;  9
 s cn=cn+1,a(cn)="UNSIGNED_ATTRIBUTE"   ; 10
 s cn=cn+1,a(cn)="FIXED_PREC_SCALE"     ; 11
 s cn=cn+1,a(cn)="AUTO_UNIQUE_VALUE"    ; 12
 s cn=cn+1,a(cn)="LOCAL_TYPE_NAME"      ; 13
 s cn=cn+1,a(cn)="MINIMUM_SCALE"        ; 14
 s cn=cn+1,a(cn)="MAXIMUM_SCALE"        ; 15
 s cn=cn+1,a(cn)="SQL_DATA_TYPE"        ; 16
 s cn=cn+1,a(cn)="SQL_DATETIME_SUB"     ; 17
 s cn=cn+1,a(cn)="NUM_PREC_RADIX"       ; 18
 s cn=cn+1,a(cn)="INTERVAL_PRECISION"   ; 19
 ;s tname="data_type"
 s cols="" f cn=1:1 q:'$d(a(cn))  s cols=cols_cn_"~"_a(cn)_"~"_a(cn)_"~"_tname_$c(13,10)
 s cols=cols_$c(13,10)
 ;
 s rn=0
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="BIT"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("BIT")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("BIT")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="TINYINT"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("TINYINT")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("TINYINT")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="BIGINT"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("BIGINT")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="19"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("BIGINT")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="LONGVARBINARY"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("LONGVARBINARY")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="2147483647"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="MAX LENGTH"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("LONGVARBINARY")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="VARBINARY"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("VARBINARY")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="4096"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="MAX LENGTH"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("VARBINARY")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="LONGVARCHAR"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("LONGVARCHAR")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="2147483647"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="MAX LENGTH"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("LONGVARCHAR")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="NUMERIC"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("NUMERIC")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="15"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="PRECISION,SCALE"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="15"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("NUMERIC")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="INTEGER"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("INTEGER")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="10"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("INTEGER")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="SMALLINT"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("SMALLINT")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="5"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("SMALLINT")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="DOUBLE"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("DOUBLE")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="15"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("DOUBLE")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="DATE"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("DATE")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="10"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("DATE")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="TIME"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("TIME")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="8"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("TIME")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="TIMESTAMP"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("TIMESTAMP")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="23"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("TIMESTAMP")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 ;
 s rn=rn+1
 s cn=0
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="VARCHAR"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("VARCHAR")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="4096"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="'"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="MAX LENGTH"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="3"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=$$sqltypeid("VARCHAR")
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,%zi(0,"stmt"),0,rn,cn)=""
typ1 d send^%mgsqln(cols,$l(cols),0,"t",1) ; send data
 q 0
type ; error
 s error=$$error^%mgsqls()
 d logerror^%mgsqls("MGSQL:typ: "_error,"M Exception")
 d send^%mgsqln(error,$l(error),0,"e",0)
 q 0
 ;
sqltypeid(type) ; get sql/odbc type ID
 s type=$$ucase^%mgsqls(type)
 i type["VARCHAR" q 12
 i type="TIMESTAMP" q 11
 i type="TIME" q 10
 i type="DATE" q 9
 i type="DOUBLE" q 8
 i type="SMALLINT" q 5
 i type="INTEGER" q 4
 i type="NUMERIC" q 2
 i type="LONGVARCHAR" q -1
 i type="VARBINARY" q -3
 i type="LONGVARBINARY" q -4
 i type="BIGINT" q -5
 i type="TINYINT" q -6
 i type="BIT" q -7
 i type="LONGVARCHAR" q -1
 q 12
 ;

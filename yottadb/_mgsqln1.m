%mgsqln1 ;(CM) MGSQL odbc ; 17 dec 2003  3:15 pm
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2019 M/Gateway Developments Ltd,                      |
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
a d vers^%mgsql("%mgsqln1") q
 ;
tab ; tables
 n a,tname,r,rn,sn,cn,nv,dtyp,i,x,n,desc,cols
 new $ztrap set $ztrap="zgoto "_$zlevel_":tabe^%mgsqln1"
 d nv^%mgsqln(data,.nv)
 s dbid=$$schema^%mgsql($g(nv("SchemaName")))
 k ^mgsqls($j,stmt)
 ;d logarray^%mgsqls(.nv,"tab() array","ODBC")
 s error=""
 ; CatalogName=%s\r\nSchemaName=%s\r\nTableName=%s\r\nTableType=%s\r\n\r\n"
 s tname="TABLES"
 s cn=0
 s cn=cn+1,a(cn)="TABLE_CAT"
 s cn=cn+1,a(cn)="TABLE_SCHEM"
 s cn=cn+1,a(cn)="TABLE_NAME"
 s cn=cn+1,a(cn)="TABLE_TYPE"
 s cn=cn+1,a(cn)="REMARKS"
 s cols="" f cn=1:1 q:'$d(a(cn))  s cols=cols_cn_"~"_a(cn)_"~"_a(cn)_"~"_tname_$c(13,10)
 s cols=cols_$c(13,10)
 ;
 i $g(nv("CatalogName"))["%" d  g tab1
 . s rn=0
 . s rn=rn+1
 . s cn=0
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . q
 i $g(nv("SchemaName"))["%" d  g tab1
 . s rn=0
 . s dbid="" f  s dbid=$$nxtdbid^%mgsqld(dbid) q:dbid=""  d
 . . s rn=rn+1
 . . s cn=0
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=dbid
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . q
 . q
 i $g(nv("TableType"))["SYSTEM TABLE" d  g tab1
 . q
 . s rn=0
 . s rn=rn+1
 . s cn=0
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=dbid
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=$g(nv("TableType"))
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . q
 i $g(nv("TableType"))["TABLE" d  g tab1
 . s rn=0
 . s dbid="" f  s dbid=$$nxtdbid^%mgsqld(dbid) q:dbid=""  d
 . . s tname="" f  s tname=$$nxttname^%mgsqld(dbid,tname) q:tname=""  d
 . . . s r=$$tab^%mgsqld(dbid,tname) i r="" q
 . . . s desc=$p(r,"\",1)
 . . . s rn=rn+1,cn=0
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=dbid
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=tname
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=$g(nv("TableType"))
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=desc
 . . . q
 . . q
 . q
 i $g(nv("TableType"))["VIEW" d  g tab1
 . q
 . s rn=0
 . s rn=rn+1
 . s cn=0
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=dbid
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=$g(nv("TableType"))
 . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . q
tab1 ; send result
 d send^%mgsqln(cols,$l(cols),0,"t",1) ; send data
 q
tabe ; error
 s error=$$error^%mgsqls()
 d logerror^%mgsqls("MGSQL:tab: "_error,"M Exception")
 d send^%mgsqln(error,$l(error),0,"e",0)
 q
 ;
col ; table columns
 n %d,%data,%ind,%ref,a,cols,col,colx,ord,cname,cname1,tname,r,rc,rn,cn,pkey,sn,dtyp,type,i,x,cname,n,kn,knm,sc,ino,desc,pk,nv
 new $ztrap set $ztrap="zgoto "_$zlevel_":cole^%mgsqln1"
 d nv^%mgsqln(data,.nv)
 s dbid=$$schema^%mgsql($g(nv("SchemaName")))
 k ^mgsqls($j,0,stmt)
 ;d logarray^%mgsqls(.nv,"col() array","ODBC")
 s error=""
 s tname="TABLE_COLUMNS"
 s cn=0
 s cn=cn+1,a(cn)="TABLE_CAT"
 s cn=cn+1,a(cn)="TABLE_SCHEM"
 s cn=cn+1,a(cn)="TABLE_NAME"
 s cn=cn+1,a(cn)="COLUMN_NAME"
 s cn=cn+1,a(cn)="DATA_TYPE"
 s cn=cn+1,a(cn)="TYPE_NAME"
 s cn=cn+1,a(cn)="COLUMN_SIZE"
 s cn=cn+1,a(cn)="BUFFER_LENGTH"
 s cn=cn+1,a(cn)="DECIMAL_DIGITS"
 s cn=cn+1,a(cn)="NUM_PREC_RADIX"
 s cn=cn+1,a(cn)="NULLABLE"
 s cn=cn+1,a(cn)="REMARKS"
 s cn=cn+1,a(cn)="COLUMN_DEF"
 s cn=cn+1,a(cn)="SQL_DATA_TYPE"
 s cn=cn+1,a(cn)="SQL_DATETIME_SUB"
 s cn=cn+1,a(cn)="CHAR_OCTET_LENGTH"
 s cn=cn+1,a(cn)="ORDINAL_POSITION"
 s cn=cn+1,a(cn)="IS_NULLABLE"
 s cols="" f cn=1:1 q:'$d(a(cn))  s cols=cols_cn_"~"_a(cn)_"~"_a(cn)_"~"_tname_$c(13,10)
 s cols=cols_$c(13,10)
 ;
 s tname=$g(nv("TableName"))
 i tname="" g col1
 s cname=$g(nv("ColumnName"))
 s knm=0
 s %d=$$tab^%mgsqld(dbid,tname) i %d="" g col1
 s pk=$$pkey^%mgsqld(dbid,tname)
 s sc=$$ind^%mgsqld(dbid,tname,.%ind)
 s sc=$$key^%mgsqld(dbid,tname,pk,.%ind)
 s ord=0,kn="" f  s kn=$o(%ind(pk,kn)) q:kn=""  d
 . s cname1=$g(%ind(pk,kn))
 . i 'cname1?1a.e q
 . s r=$$col^%mgsqld(dbid,tname,cname1)
 . s desc=""
 . s ord=ord+1,knm=ord s col(ord)=cname1,col(ord,"k")=1,col(ord,"d")=desc
 . s colx(cname1)=ord
 . q
 s sc=$$data^%mgsqld(dbid,tname,.%data)
 s cname1="" f  s cname1=$o(%data(cname1)) q:cname1=""  d
 . s r=$g(%data(cname1))
 . s pkey=$g(colx(cname1))+0
 . s ord=$s(pkey:pkey,1:$p(r,"\",1)+knm)
 . ;s r=$$col^%mgsqld(dbid,tname,cname)
 . s desc=""
 . s type=$p(r,"\",2)
 . s col(ord)=cname1,col(ord,"k")=$s(pkey:1,1:0),col(ord,"d")=desc,col(ord,"t")=type
 . s colx(cname1)=ord
 . q
 ;d logevent^%mgsqls("MGSQL:col:"_fid_":"_cname, "col","ODBC")
 i cname="" d  g col1
 . s rn=0
 . f ord=1:1 q:'$d(col(ord))  d
 . . s cname=col(ord)
 . . s rn=rn+1
 . . d col2(dbid,tname,cname,rn,ord,.col)
 . . q
 . q
 f ord=1:1 q:'$d(col(ord))  i $g(col(ord))=cname d  g col1
 . s rn=0
 . d col2(dbid,tname,cname,rn,ord,.col)
 . q
col1 ; send result
 d send^%mgsqln(cols,$l(cols),0,"t",1) ; send data
 q
cole ; error
 s error=$$error^%mgsqls()
 d logerror^%mgsqls("MGSQL:col: "_error,"M Exception")
 d send^%mgsqln(error,$l(error),0,"e",0)
 q
 ;
col2(dbid,tname,cname,rn,ord,cdata)
 n cn,type
 s type=$$ucase^%mgsqls($g(col(ord,"t")))
 s cn=0
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=dbid
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=tname
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=cname
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=$$sqltypeid^%mgsqln2(type)
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=type
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="256"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="256"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=$$sqltypeid^%mgsqln2(type)
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=ord
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="NO"
 q
 ;
stt ; table statistics
 n a,n,nv,tname,r,rn,sn,cn,cols,dtyp,i,x,kn,knx,idx,idxn
 new $ztrap set $ztrap="zgoto "_$zlevel_":stte^%mgsqln1"
 d nv^%mgsqln(data,.nv)
 s dbid=$$schema^%mgsql($g(nv("SchemaName")))
 k ^mgsqls($j,stmt)
 ;d logarray^%mgsqls(.nv,"stt() array","ODBC")
 s error=""
 s tname="TABLE_STATISTICS"
 s cn=0
 s cn=cn+1,a(cn)="TABLE_CAT" ; 1
 s cn=cn+1,a(cn)="TABLE_SCHEM" ; 2
 s cn=cn+1,a(cn)="TABLE_NAME" ; 3
 s cn=cn+1,a(cn)="NON_UNIQUE" ; 4
 s cn=cn+1,a(cn)="INDEX_QUALIFIER" ; 5
 s cn=cn+1,a(cn)="INDEX_NAME" ; 6
 s cn=cn+1,a(cn)="TYPE" ; 7
 s cn=cn+1,a(cn)="ORDINAL_POSITION" ; 8
 s cn=cn+1,a(cn)="COLUMN_NAME" ; 9
 s cn=cn+1,a(cn)="ASC_OR_DESC" ; 10
 s cn=cn+1,a(cn)="CARDINALITY" ; 11
 s cn=cn+1,a(cn)="PAGES" ; 12
 s cn=cn+1,a(cn)="FILTER_CONDITION" ; 13
 s cols="" f cn=1:1 q:'$d(a(cn))  s cols=cols_cn_"~"_a(cn)_"~"_a(cn)_"~"_tname_$c(13,10)
 s cols=cols_$c(13,10)
 ;
 g stt1
stt1 ; send result
 d send^%mgsqln(cols,$l(cols),0,"n",1) ; send data
 q
stte ; error
 s error=$$error^%mgsqls()
 d logerror^%mgsqls("MGSQL:stt: "_error,"M Exception")
 d send^%mgsqln(error,$l(error),0,"e",0)
 q
 ;
pky ; table primary key
 n %ind,%ref,a,n,tname,r,rc,sn,kn,sc,rn,cn,nv,cols,dtyp,pk,i,ino,x,n,r,cname,kn
 new $ztrap set $ztrap="zgoto "_$zlevel_":pkye^%mgsqln1"
 d nv^%mgsqln(data,.nv)
 s dbid=$$schema^%mgsql($g(nv("SchemaName")))
 k ^mgsqls($j,stmt)
 ;d logarray^%mgsqls(.nv,"pky() array","ODBC")
 s error=""
 s tname="TABLE_PRIMARY_KEY"
 s cn=0
 s cn=cn+1,a(cn)="TABLE_CAL" ; 1
 s cn=cn+1,a(cn)="TABLE_SCHEM" ; 2
 s cn=cn+1,a(cn)="TABLE_NAME" ; 3
 s cn=cn+1,a(cn)="COLUMN_NAME" ; 4
 s cn=cn+1,a(cn)="KEY_SEQ" ; 5
 s cn=cn+1,a(cn)="PK_NAME" ; 6
 s cols="" f cn=1:1 q:'$d(a(cn))  s cols=cols_cn_"~"_a(cn)_"~"_a(cn)_"~"_tname_$c(13,10)
 s cols=cols_$c(13,10)
 ;
 s tname=$g(nv("TableName"))
 i tname'="" d  g pky1
 . s n=0
 . s pk=$$pkey^%mgsqld(dbid,tname)
 . s sc=$$ind^%mgsqld(dbid,tname,.%ind)
 . s sc=$$key^%mgsqld(dbid,tname,pk,.%ind)
 . s rn=0,kn=0
 . s n="" f  s n=$o(%ind(pk,n)) q:n=""  d
 . . s r=$g(%ind(pk,n)) i r=""!(r["""")!(r?1n.e) q
 . . s cname=r,kn=kn+1
 . . s rn=rn+1
 . . s cn=0
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=dbid
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=tname
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=cname
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=kn
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=pk
 . . q
 . q
pky1 ; send result
 d send^%mgsqln(cols,$l(cols),0,"k",1) ; send data
 q
pkye ; error
 s error=$$error^%mgsqls()
 d logerror^%mgsqls("MGSQL:pky: "_error,"M Exception")
 d send^%mgsqln(error,$l(error),0,"e",0)
 q
 ;
fky ; table foreign key
 n %ind,%ref,a,n,tname,r,rc,sn,kn,sc,rn,cn,nv,cols,dtyp,pk,i,ino,x,n,r,cname,kn
 new $ztrap set $ztrap="zgoto "_$zlevel_":fkye^%mgsqln1"
 d nv^%mgsqln(data,.nv)
 s dbid=$$schema^%mgsql($g(nv("SchemaName")))
 k ^mgsqls($j,stmt)
 ;d logarray^%mgsqls(.nv,"fky() array","ODBC")
 s error=""
 s tname="TABLE_PRIMARY_KEY"
 s cn=0
 s cn=cn+1,a(cn)="PKTABLE_CAT" ; 1
 s cn=cn+1,a(cn)="PKTABLE_SCHEM" ; 2
 s cn=cn+1,a(cn)="PKTABLE_NAME" ; 3
 s cn=cn+1,a(cn)="PKCOLUMN_NAME" ; 4
 s cn=cn+1,a(cn)="FKTABLE_CAT" ; 5
 s cn=cn+1,a(cn)="FKTABLE_SCHEM" ; 6
 s cn=cn+1,a(cn)="FKTABLE_NAME" ; 7
 s cn=cn+1,a(cn)="FKCOLUMN_NAME" ; 8
 s cn=cn+1,a(cn)="KEY_SEQ" ; 9
 s cn=cn+1,a(cn)="UPDATE_RULE" ; 10
 s cn=cn+1,a(cn)="DELETE_RULE" ; 11
 s cn=cn+1,a(cn)="FK_NAME" ; 12
 s cn=cn+1,a(cn)="PK_NAME" ; 13
 s cn=cn+1,a(cn)="DEFERRABILITY" ; 14
 s cols="" f cn=1:1 q:'$d(a(cn))  s cols=cols_cn_"~"_a(cn)_"~"_a(cn)_"~"_tname_$c(13,10)
 s cols=cols_$c(13,10)
 ;
 s tname=$g(nv("TableName"))
 i tname'="" d  g fky1
 . s n=0
 . s pk=$$pkey^%mgsqld(dbid,tname)
 . s sc=$$ind^%mgsqld(dbid,tname,.%ind)
 . s sc=$$key^%mgsqld(dbid,tname,pk,.%ind)
 . s rn=0,kn=0
 . s n="" f  s n=$o(%ind(pk,n)) q:n=""  d
 . . s r=$g(%ind(pk,n)) i r=""!(r["""")!(r?1n.e) q
 . . s cname=r,kn=kn+1
 . . s rn=rn+1
 . . s cn=0
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=dbid
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=tname
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=cname
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=dbid
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=tname
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=cname
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=kn
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="cascade"
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="cascade"
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=pk
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=pk
 . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
 . . q
 . q
fky1 ; send result
 d send^%mgsqln(cols,$l(cols),0,"m",1) ; send data
 q
fkye ; error
 s error=$$error^%mgsqls()
 d logerror^%mgsqls("MGSQL:fky: "_error,"M Exception")
 d send^%mgsqln(error,$l(error),0,"e",0)
 q
 ;
prc ; procedures
 ; PROCDURE_TYPE:  SQL_PT_UNKNOWN=0, SQL_PT_PROCEDURE=1, SQL_PT_FUNCTION=2
 n a,cname,pname,tname,r,rn,cn,sn,cols,nv,dtyp,i,x,n,desc,r
 new $ztrap set $ztrap="zgoto "_$zlevel_":prce^%mgsqln1"
 d nv^%mgsqln(data,.nv)
 s dbid=$$schema^%mgsql($g(nv("SchemaName")))
 k ^mgsqls($j,stmt)
 ;d logarray^%mgsqls(.nv,"prc() array","ODBC")
 s error=""
 s tname="PROCEDURES"
 s cn=0
 s cn=cn+1,a(cn)="PROCEDURE_CAT"
 s cn=cn+1,a(cn)="PROCEDURE_SCHEM"
 s cn=cn+1,a(cn)="PROCEDURE_NAME"
 s cn=cn+1,a(cn)="NUM_INPUT_PARAMS"
 s cn=cn+1,a(cn)="NUM_OUTPUT_PARAMS"
 s cn=cn+1,a(cn)="NUM_RESULT_SETS"
 s cn=cn+1,a(cn)="REMARKS"
 s cn=cn+1,a(cn)="PROCEDURE_TYPE"
 s cols="" f cn=1:1 q:'$d(a(cn))  s cols=cols_cn_"~"_a(cn)_"~"_a(cn)_"~"_tname_$c(13,10)
 s cols=cols_$c(13,10)
 s pname=$g(nv("ProcName"))
 i pname="" d  g prc1
 . s rn=0
 . s dbid="" f  s dbid=$$nxtdbid^%mgsqld(dbid) q:dbid=""  d
 . . s pname="" f  s pname=$$nxtpname^%mgsqld(dbid,pname) q:pname=""  d
 . . . s r=$$prc^%mgsqld(dbid,pname) i r="" q
 . . . s desc=$p(r,"\",1)
 . . . s rn=rn+1,cn=0
 . . . s cn=0
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=pname
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 . . . s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
 . . . q
 . . q
 . q
 s r=$$prc^%mgsqld(dbid,pname) i r="" g prc1
 s desc=$p(r,"\",1)
 s rn=1
 s cn=0
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=pname
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
prc1 ; send result
 d send^%mgsqln(cols,$l(cols),0,"p",1) ; send data
 q
prce ; error
 s error=$$error^%mgsqls()
 d logerror^%mgsqls("MGSQL:prc: "_error,"M Exception")
 d send^%mgsqln(error,$l(error),0,"e",0)
 q
 ;
pcc ; procedure columns
 ; PROCDURE_TYPE:  SQL_PT_UNKNOWN=0, SQL_PT_PROCEDURE=1, SQL_PT_FUNCTION=2
 n %data,a,cname,cname1,pname,tname,r,rn,sc,sn,cn,col,cols,colx,nv,ord,dtyp,type,i,x,n,desc,r
 new $ztrap set $ztrap="zgoto "_$zlevel_":pcce^%mgsqln1"
 d nv^%mgsqln(data,.nv)
 s dbid=$$schema^%mgsql($g(nv("SchemaName")))
 k ^mgsqls($j,stmt)
 ;d logarray^%mgsqls(.nv,"pcc() array","ODBC")
 s error=""
 s tname="PROCEDURE_COLUMNS"
 s cn=0
 s cn=cn+1,a(cn)="PROCEDURE_CAT"
 s cn=cn+1,a(cn)="PROCEDURE_SCHEM"
 s cn=cn+1,a(cn)="PROCEDURE_NAME"
 s cn=cn+1,a(cn)="COLUMN_NAME"
 s cn=cn+1,a(cn)="COLUMN_TYPE"
 s cn=cn+1,a(cn)="DATA_TYPE"
 s cn=cn+1,a(cn)="TYPE_NAME"
 s cn=cn+1,a(cn)="COLUMN_SIZE"
 s cn=cn+1,a(cn)="BUFFER_LENGTH"
 s cn=cn+1,a(cn)="DECIMAL_DIGITS"
 s cn=cn+1,a(cn)="NUM_PREC_RADIX"
 s cn=cn+1,a(cn)="NULLABLE"
 s cn=cn+1,a(cn)="REMARKS"
 s cn=cn+1,a(cn)="COLUMN_DEF"
 s cn=cn+1,a(cn)="SQL_DATA_TYPE"
 s cn=cn+1,a(cn)="SQL_DATETIME_SUB"
 s cn=cn+1,a(cn)="CHAR_OCTET_LENGTH"
 s cn=cn+1,a(cn)="ORDINAL_POSITION"
 s cn=cn+1,a(cn)="IS_NULLABLE"
 s cols="" f cn=1:1 q:'$d(a(cn))  s cols=cols_cn_"~"_a(cn)_"~"_a(cn)_"~"_tname_$c(13,10)
 s cols=cols_$c(13,10)
 ;
 s pname=$g(nv("ProcName"))
 s cname=$g(nv("ColumnName"))
 s sc=$$pdata^%mgsqld(dbid,pname,.%data)
 s cname1="" f  s cname1=$o(%data(cname1)) q:cname1=""  d
 . s r=$g(%data(cname1))
 . s ord=$p(r,"\",1)
 . s desc=""
 . s type=$p(r,"\",2)
 . s col(ord)=cname1,col(ord,"k")=0,col(ord,"d")=desc,col(ord,"t")=type
 . s colx(cname1)=ord
 . q
 i cname="" d  g pcc1
 . s rn=0
 . f ord=1:1 q:'$d(col(ord))  d
 . . s cname=col(ord)
 . . s rn=rn+1
 . . d pcc2(dbid,tname,cname,rn,ord,.col)
 . . q
 . q
 f ord=1:1 q:'$d(col(ord))  i $g(col(ord))=cname d  g col1
 . s rn=0
 . d pcc2(dbid,pname,cname,rn,ord,.col)
 . q
pcc1 ; send result
 d send^%mgsqln(cols,$l(cols),0,"q",1) ; send data
 q
pcce ; error
 s error=$$error^%mgsqls()
 d logerror^%mgsqls("MGSQL:pcc: "_error,"M Exception")
 d send^%mgsqln(error,$l(error),0,"e",0)
 q
 ;
pcc2(dbid,pname,cname,rn,ord,cdata)
 n cn,type
 s type=$$ucase^%mgsqls($g(col(ord,"t")))
 s cn=0
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=pname
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=cname
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="12"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="VARCHAR"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="256"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="256"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="0"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="12"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)=""
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="1"
 s cn=cn+1,^mgsqls($j,stmt,0,rn,cn)="NO"
 q
 ;
test ; test harness
 k
 s dbid="mgsql"
 s stmt=0
 ;s data="CatalogName="_$c(13,10)_"SchemaName=mgsql"_$c(13,10)_"TableName="_$c(13,10)_"TableType=TABLE"_$c(13,10,13,10) d tab
 ;s data="CatalogName="_$c(13,10)_"SchemaName=mgsql"_$c(13,10)_"TableName=admission"_$c(13,10)_"ColumnName="_$c(13,10,13,10) d col
 ;s data="CatalogName="_$c(13,10)_"SchemaName=mgsql"_$c(13,10)_"TableName=admission"_$c(13,10)_"ColumnName=dadm"_$c(13,10,13,10) d col
 ;s data="CatalogName="_$c(13,10)_"SchemaName=mgsql"_$c(13,10)_"TableName="_$c(13,10,13,10) d stt
 ;s data="CatalogName="_$c(13,10)_"SchemaName=mgsql"_$c(13,10)_"TableName=admission"_$c(13,10,13,10) d pky
 ;s data="CatalogName="_$c(13,10)_"SchemaName=mgsql"_$c(13,10)_"TableName=admission"_$c(13,10,13,10) d fky
 ;s data="CatalogName="_$c(13,10)_"SchemaName=mgsql"_$c(13,10)_"ProcName="_$c(13,10,13,10) d prc
 s data="CatalogName="_$c(13,10)_"SchemaName=mgsql"_$c(13,10)_"ProcName=patient_getdata"_$c(13,10)_"ColumnName="_$c(13,10,13,10) d pcc
 m z=^mgsqls($j,stmt)
 q
 

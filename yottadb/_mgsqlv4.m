%mgsqlv4 ;(CM) sql - validate query part 5 ; 28 Jan 2022  10:03 AM
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2022 M/Gateway Developments Ltd,                      |
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
a d vers^%mgsql("%mgsqlv4") q
 ;
create(dbid,sql,error) ; validate 'create' statement
 n %ind,type,crt,on,ln,idx,tname,alias,i,x,com
 s crt=sql(0,1),type=$$lcase^%mgsqls($p(crt," ",2)) i type="unique" s type=$$lcase^%mgsqls($p(crt," ",3))
 i type'="index",type'="table",type'="procedure" s error="second word in 'create' statement should be 'index', 'table' or 'procedure'",error(5)="HY000" q
 i type="table" d table(dbid,.sql,.error) s error="\ddl\"_error q
 i type="index" d tindex(dbid,.sql,.error) s error="\ddl\"_error q
 i type="procedure" d proc(dbid,.sql,.error) s error="\ddl\"_error q
 s idx=$p(crt," ",3) i idx'?1n.n,idx'?1"q"1n.n s error="invalid query identity in 'create' statement",error(5)="HY000" q
 s on=$p(crt," ",4)
 s ln="" i $d(sql(0,2)) s ln=sql(0,2)
 i on'="on",$p(ln," ",1)'="on" s error="'create' must be followed by 'on' what table",error(5)="HY000" q
 i on="on",$p(ln," ",1)="on" s error="duplication in 'on' statement",error(5)="HY000" q
 i on="on" s on=$p(crt," ",4,999)
 i $p(ln," ",1)="on" s on=ln
 s (tname,alias)=$p(on," ",2) s %d=$$tab^%mgsqld(dbid,tname) i %d="" s error="invalid table in 'on' statement",error(5)="42S02" q
 s index=$p(on," ",3,999) i index'?1"("1e.e1")" s error="invalid index declaration in 'on' statement",error(5)="HY000" q
 s index=$e(index,2,$l(index)-1)
 f i=1:1:$l(index,",") s x=$p(index,",",i),^mgtmp($j,"from","i",i)=x s:$l(x) ^mgtmp($j,"from","i","x",x)="" i '$l(x) s error="unspecified item in index",error(5)="HY000"
 i $l(error) q
 s ino=$$pkey^%mgsqld(dbid,tname) s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) i x?1a.e,'$d(^mgtmp($j,"from","i","x",x)) s error="primary key column '"_x_"' is missing from index",error(5)="HY000" q
 i $l(error) q
 f i=1:1 q:'$d(^mgtmp($j,"from","i",i))  d create1 i $l(error) q
 i $l(error) q
 d index
 s sql(1,1)="select ",com="" f i=1:1 q:'$d(^mgtmp($j,"from","i",i))  s x=^mgtmp($j,"from","i",i) i x?1a.e s sql(1,1)=sql(1,1)_com_alias_"."_x,com=","
 s sql(1,2)="from "_tname_" "_alias
 s ^mgtmp($j,"create","index")=tname_" "_alias_"~"_idx
 q
 ;
create1 ; check individual items in index
 s cname=^mgtmp($j,"from","i",i)
 i cname?1n.n!(at?1""""1e.e1"""")!(wrd[%z("ds")) q
 i cname'?1a.e s error="invalid item '"_cname_"' in index",error(5)="HY000" q
 s %defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname) i '%defk,'%defd s error="column '"_cname_"' not found in table '"_tname_"'",error(5)="42S22" q
 q
 ;
table(dbid,sql,error) ; create a new table
 n crt,tname,i,item,obr,cbr,cols,chr,rc,strt,end,pre,post,opt,name,value,cn
 s crt=sql(0,1)
 s tname=$p(crt," ",3),crt=$p(crt," ",4,999)
 s (strt,end,obr,cbr)=0 f i=1:1 s chr=$e(crt,i) q:chr=""  d  i obr=cbr s end=i q
 . i chr="(" s obr=obr+1 i strt=0 s strt=i
 . i chr=")" s cbr=cbr+1
 . q
 s cols=$e(crt,strt+1,end-1)
 s pre=$e(crt,1,strt-1),post=$e(crt,end+1,9999),crt=pre_post
 s (obr,cbr)=0,item="",cn=0 f i=1:1 s chr=$e(cols,i) q:chr=""  d
 . i chr="(" s obr=obr+1
 . i chr=")" s cbr=cbr+1
 . i chr=",",obr=cbr s cn=cn+1,cols(cn)=$$trim^%mgsqls(item," "),(obr,cbr)=0,item="" q
 . s item=item_chr
 . q
 i item'="" s cn=cn+1,cols(cn)=$$trim^%mgsqls(item," ")
 s opt="" i crt["/*!" s opt=$p($p(crt,"/*!",2,999),"*/",1)
 f i=1:1:$l(opt,",") s item=$p(opt,",",i) d
 . s name=$$trim^%mgsqls($p(item,"=",1)," ")
 . s value=$$trim^%mgsqls($p(item,"=",2)," ")
 . i name'="" s tname($$lcase^%mgsqls(name))=value
 . q
 i '$d(cols(1)) s error="No columns specified" q
 s rc=$$ctable^%mgsqld(dbid,.tname,.cols)
 q
 ;
tindex(dbid,sql,error) ; create a new index for table
 n opt,i,item,name,value,part,x,rc
 s part=0 f i=1:1:$l(crt," ") s item=$p(crt," ",i) d
 . s x=$$lcase^%mgsqls(item) i item="" q
 . i x="index" s part=1 q
 . i x="on" s part=2 q
 . i part=1 s ino=item,part=0
 . i part=2 s tname=item,part=0
 . q
 s cols=$p($p(crt,"(",2),")",1)
 f i=1:1:$l(cols,",") s cols(i)=$p(cols,",",i)
 s opt="" i crt["/*!" s opt=$p($p(crt,"/*!",2,999),"*/",1)
 f i=1:1:$l(opt,",") s item=$p(opt,",",i) d
 . s name=$$trim^%mgsqls($p(item,"=",1)," ")
 . s value=$$trim^%mgsqls($p(item,"=",2)," ")
 . i name'="" s tname($$lcase^%mgsqls(name))=value
 . q
 s rc=$$cindex^%mgsqld(dbid,.tname,ino,.cols)
 q
 ;
proc(dbid,sql,error) ; create a new procedure
 n crt,pname,i,item,obr,cbr,cols,chr,rc
 s crt=sql(0,1)
 s pname=$p(crt," ",3),crt=$p(crt," ",4,999)
 s crt=$e(crt,2,$l(crt)-1)
 s item="",obr=0,cbr=0 f i=1:1 s chr=$e(crt,i) q:chr=""  d
 . i chr="(" s obr=obr+1
 . i chr=")" s cbr=cbr+1
 . i chr=",",obr=cbr s cols($i(cols))=$$trim^%mgsqls(item," "),item="",obr=0,cbr=0 q
 . s item=item_chr
 . q
 i item'="" s cols($i(cols))=$$trim^%mgsqls(item," ")
 s rc=$$cproc^%mgsqld(dbid,pname,.cols)
 q
 ;
drop(dbid,sql,error) ; drop catalogue item
 n crt,type,item
 s error=""
 s crt=sql(0,1),type=$$lcase^%mgsqls($p(crt," ",2)),item=$p(crt," ",3)
 i type'="index",type'="table",type'="procedure" s error="second word in 'drop' statement should be 'index', 'table' or 'procedure'",error(5)="HY000" q
 i type="table" s rc=$$dtable^%mgsqld(dbid,item) s error="\ddl\"_error q
 q
 ;
index ; table index idx for tname in ^mgtmp($j,"from","i",1-n)
 s id=tname k xsub,xcon d indexr^%mgsqld(dbid,tname,ino,.xsub)
 i idx'["q" s ino=$$pkey^%mgsqld(dbid,tname),%ref=$$ref^%mgsqld(dbid,tname,ino) s ref=%ref
 i idx["q" s ref="^qryinx"
 f i=1:1 q:'$d(^mgtmp($j,"from","i",i))
 i idx["q" f ii=i-1:-1:1 s ^mgtmp($j,"from","i",ii+2)=^mgtmp($j,"from","i",ii)
 i idx["q" s ^mgtmp($j,"from","i",1)=$c(34)_tname_$c(34),^mgtmp($j,"from","i",2)=$c(34)_idx_$c(34)
 k xsub(idx) s xsub(idx)=ref
 f i=1:1 q:'$d(^mgtmp($j,"from","i",i))  s xsub(idx,i)=^mgtmp($j,"from","i",i)
 d indexw^%mgsqld(dbid,tname,ino,.xsub) k xsub,xcon,scl
 q
 ;
insert ; validate 'insert' query
 s inse=sql(0,1),into=sql(0,2),valu=$s($d(sql(0,3)):sql(0,3),1:"")
 i $l($p(inse,"insert",2,999)) s error="the 'insert' statement does not have an argument",error(5)="HY000",error(0)="insert",error(1)=0 g insertx
 s tname=$p(into," ",2) i tname="" s error="no table supplied in 'into' statement",error(5)="HY000" g insertx
 s tnamer=tname
 s %d=$$tab^%mgsqld(dbid,tname) i %d="" s error="no such table '"_tname_"'",error(5)="42S02" g insertx
 s ^mgtmp($j,"upd","insert")=tname
 i $p(valu," ",1)="values" d insv i $l(error) g insertx
 i $p(valu," ",1)'="values" d inss i $l(error) g insertx
 s inta=$p(into," ",3,999) i inta'="",inta'?1"("1e.e1")" s error="invalid column declaration list in 'into' statement",error(5)="HY000" g insertx
 i tname?1"{n:"1a.e,inta="" s error="column names must be specified in the 'into' statement for named aggregates",error(5)="HY000" g insertx
 i inta'="" s inta=$e(inta,2,$l(inta)-1)
 i inta'="" f i=1:1:$l(inta,",") s cname=$p(inta,",",i) s:cname="" error=1 q:cname=""  s ^mgtmp($j,"upd","att",i)=cname,^mgtmp($j,"upd","attx",cname)="",^mgtmp($j,"upd","att")=i s %defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname) i '%defk,'%defd s error=2 q
 i $l(error) s error=$s(error=1:"invalid column list in 'into' line",error=2:"column '"_cname_"' not found in table '"_tname_"'",1:""),error(5)="HY000" g insertx
 i $l(error) s error=$s(error=1:"invalid column list in 'into' line",error=2:"column '"_cname_"' not available from aggregates",1:""),error(5)="HY000" g insertx
 s kno=0,ino=$$pkey^%mgsqld(dbid,tname) s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) i x?1a.e s kno=kno+1,key(kno)=x
 s an=0 i tnamer?1"{n:"1a.e f i=1:1 q:'$d(key(i))  s an=an+1,data(an)=key(i) k key(i)
 s sc=$$data^%mgsqld(dbid,tname,.%data) s x="" f  s x=$o(%data(x)) q:x=""  s data(($p(%data(x),"\",2)+an))=x k %data(x)
 i $d(^mgtmp($j,"upd","att")) f i=1:1 q:'$d(key(i))  s x=key(i) i '$d(^mgtmp($j,"upd","attx",x)) s error="key column '"_x_"' not found in 'into' variable list",error(5)="HY000" q
 i $l(error) g insertx
 i $d(^mgtmp($j,"upd","att")),^mgtmp($j,"upd","att")'=^mgtmp($j,"upd","val") s error="the number of columns given is not the same as the number of values",error(5)="HY000" g insertx
 i $d(^mgtmp($j,"upd","att")) g insert1
 f i=1:1 q:'$d(^mgtmp($j,"upd","val",i))!'$d(key(i))  s ^mgtmp($j,"upd","att",i)=key(i)
 i $d(key(i)),'$d(^mgtmp($j,"upd","val",i)) s error="not enough data available to satisfy whole key to table '"_tname_"'",error(5)="HY000" g insertx
 i '$d(^mgtmp($j,"upd","val",i)) g insert1
 s i=i-1
 f ii=1:1 q:'$d(^mgtmp($j,"upd","val",i+ii))!'$d(data(ii))  s ^mgtmp($j,"upd","att",i+ii)=data(ii)
 i tname'?1"{n:"1a.e,$d(^mgtmp($j,"upd","val",i+ii)),'$d(data(ii)) s error="too much data data available for table '"_tname_"'",error(5)="HY000" g insertx
insert1 s tname=^mgtmp($j,"upd","insert")
 s incwhr=0
 s ^mgtmp($j,"upd","insert")=tname
insertx i $l(error),'$d(error(0)) s error(0)="into",error(1)=0
 q
 ;
insv ; validate 'values' line
 s val=$p(valu," ",2,999)
 i val'?1"("1e.e1")" s error="invalid declaration of values in the 'values' statement",error(5)="HY000" g insvx
 s val=$e(val,2,$l(val)-1)
 s pn=0,an=0
insv1 s pn=pn+1 i pn>$l(val,",") q
 s wrd=$p(val,",",pn)
 f  q:($l(wrd,"""")#2)  s pn=pn+1,wrd=wrd_$p(val,",",pn)
 s an=an+1
 i wrd?.1"-".n.1"."1n.n g insv2
 i wrd?1"""".e1""""!(wrd?@("1"""_%z("ds")_""".e1"""_%z("ds")_"""")) g insv2
 i wrd?1"'".e1"'" s wrd=$tr(wrd,"'","""") g insv2
 i wrd?1"{".e1"}" s wrd=$$trx^%mgsqlv(wrd) g insv2
 i wrd?1":"1a.e s inv($p(wrd,":",2))="",wrd=%z("dev")_$p(wrd,":",2)_%z("dev") g insv2
 s error="invalid item '"_wrd_"' in 'values' statement",error(5)="HY000" g insvx
insv2 s ^mgtmp($j,"upd","val",an)=wrd,^mgtmp($j,"upd","val")=an
 g insv1
insvx i $l(error) s error(0)="values",error(1)=0
 q
 ;
inss ; validate 'select' line (after 'into')
 s valu="" i $d(sql(1,1)) s valu=sql(1,1)
 i '$l(valu) s error="missing 'values' or query component to 'insert' query",error(5)="HY000" q
 s val=$p(valu," ",2,999)
 i val="*" d inssa g inssx
 s pn=0,an=0
inss1 s pn=pn+1 i pn>$l(val,",") g inssx
 s wrd=$p(val,",",pn)
 i wrd?1"distinct "1a.e s wrd=$p(wrd,"distinct ",2,999)
 s an=an+1
 i wrd?.1"."1a.e g inss2
 i wrd?1":"1a.e s wrd=%z("dev")_$p(wrd,":",2)_%z("dev") g inss2
 i wrd?.1"-".n.1"."1n.n g inss2
 i wrd?1"""".e1""""!(wrd[%z("ds")) g inss2
 s error="invalid item '"_wrd_"' in 'select' statement",error(5)="HY000" g inssx
inss2 s ^mgtmp($j,"upd","val",an)=wrd,^mgtmp($j,"upd","val")=an
 g inss1
inssx i $l(error),'$d(error(0)) s error(0)="select",error(1)=1
 q
 ;
inssa ; select all items from table
 n alias1,tname
 i '$d(sql(1,2)) s error="a 'from' statement should follow the 'select *' statement",error(5)="HY000" q
 s (alias1,tname)=$p(sql(1,2),"from ",2,999)
 i alias1[" " s tname=$p(alias1," ",1),alias1=$p(alias1," ",2)
 i '$l(alias1) s error="invalid 'from' statement",error(5)="HY000",error(0)="from",error(1)=1 q
 s ino=$$pkey^%mgsqld(dbid,tname) s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) s an=0 f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) i x?1a.e s an=an+1,^mgtmp($j,"upd","val",an)=alias1_"."_x,^mgtmp($j,"upd","val")=an
 s sc=$$data^%mgsqld(dbid,tname,.%data) s x="" f i=1:1 s x=$o(%data(x)) q:x=""  s y=$p(%data(x),"\",2),^mgtmp($j,"upd","val",y+an)=alias1_"."_x,^mgtmp($j,"upd","val")=i+an k %data(x)
 q
 ;

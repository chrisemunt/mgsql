%mgsqlv3 ;(CM) sql - validate query part 4 ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlv3") q
 ;
update ; validate 'update' query
 n ln
 s upd=sql(0,1),set=sql(0,2),ats=""
 s tname=$p(upd," ",2),alias=$p(upd," ",3) i tname="" s error="no table supplied in 'update' statement",error(5)="HY000" g updatex
 s updidx="" i alias?.e1":"1n.n s updidx=":"_$p(alias,":",2),alias=$p(alias,":",1)
 i '$l(alias) s alias=tname
 i $l(alias),alias'?1a.e s error="invalid alias '"_alias_"'",error(5)="HY000" g updatex
 s %d=$$tab^%mgsqld(dbid,tname) i %d="" s error="no such table '"_tname_"'",error(5)="42S02" g updatex
 s incwhr=0
 s scmnd=$p(set," ",1),set=$p(set," ",2,999)
 i scmnd="columns" d at i $p(sql(0,1)," ",1)="insert" q
 i scmnd="set" d set i $l(error) g updatex
 s (x,sel,com)="" k y
 f i=0:0 s x=$o(update("set",x)) q:x=""  s sel=sel_com_x,com=",",y(x)="",y="" f i=0:0 s y=$o(update("set",x,"i",y)) q:y=""  i '$d(y(y)) s sel=sel_com_y,y(y)=""
 k y
 s sql(1,1)="select "_sel,sql(1,2)="from "_tname i $l(alias) s sql(1,2)=sql(1,2)_" "_alias_updidx
 i '$l(ats) d update1 k wrd,wrdx i ins q
 s update("update")=tname,update("set")=set i $l(alias) s update("update")=update("update")_" "_alias
updatex i $l(error),'$d(error(0)) s error(0)="update",error(1)=0
 k upd,set
 q
 ;
at ; validate 'columns' line and transform to 'insert' if neccessary
 s ats=set i ats'?1"("1a.e1")" s error="invalid 'columns' statement",error(5)="HY000" g atx
 s ats=$e(ats,2,$l(ats)-1)
 s tnamer=tname
 k pkey s ino=$$pkey^%mgsqld(dbid,tname) s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) i x?1a.e s pkey(x)=""
 f i=1:1:$l(ats,",") s xc=$p(ats,",",i) d at1 i $l(error) q
 i $l(error) g atx
 s (x,com,pkey)="" f i=0:0 s x=$o(pkey(x)) q:x=""  s pkey=pkey_com_x
 i $l(pkey) s error="key column(s) "_pkey_" not found in 'columns' statement",error(5)="HY000" g atx
 i $d(sql(1,3)) g atx
 k sql
 s qnummax=0
 s sql(0,1)="insert"
 s sql(0,2)="into "_tname_" ("
 s sql(0,3)="values ("
 s x="",com="" f i=0:0 s x=$o(update("set",x)) q:x=""  s sql(0,2)=sql(0,2)_com_x,sql(0,3)=sql(0,3)_com_update("set",x),com=","
 f i=2,3 s sql(0,i)=sql(0,i)_")"
atx i $l(error) s error(0)="columns",error(1)=0
 q
 ;
at1 ; validate column
 i xc="" s error="syntax error in 'columns' statement",error(5)="HY000" q
 i xc'?1a.e!($l(xc,",")>2) s error="invalid column '"_xc_"' in 'columns' statement",error(5)="HY000" q
 s cname=$p(xc,";",1)
 s %defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname) i '%defk,'%defd s error="column '"_cname_"' not found in table '"_tname_"'",error(5)="42S22" q
 i tname?@("1"""_%z("dq")_"""1n.n1"""_%z("dq")_"""") d  q:$l(error)  g at11
 . n qnum
 . ;b
 . s qnum=$p(tname,%z("dq"),2)
 . i '$d(^mgtmp($j,"vx",qnum,cname)) s error="column '"_cname_"' is found in derived table "_alias,error(5)="42S22" q
 . q
at11 k pkey(cname) s update("set",cname)=":"_xc,update("set",cname,"zcode",1)=" s "_%z("dsv")_cname_"**set**"_%z("dsv")_"="_%z("dev")_xc_%z("dev"),inv(xc)=""
 q
 ;
set ; validate 'set' statement
 n arg,args
 s arg=set s arg=$$arg^%mgsqle(arg,.args)
 f i=1:1:args s x=args(i) d set1 i $l(error) q
 i $l(error) s error(0)="set",error(1)=0
 q
 ;
set1 ; validate individual 'set' in 'set' statement
 n i,outv,zcode,sqlex
 s to=$p(x," ",3,999),outv=$p(x," ",1)
 s cname=outv i outv?1a.e1"."1a.e s cname=$p(outv,".",2) i $p(outv,".",1)'=alias s error="'set' statement: incorrect alias in '"_outv_"'",error(5)="HY000" q
 i $p(x," ",2)'="="!(cname="")!(to="") s error="invalid assignment: '"_x_"'",error(5)="HY000" q
 i tname?@("1"""_%z("dq")_"""1n.n1"""_%z("dq")_"""") d  q:$l(error)  g set11
 . n qnum
 . ;b
 . s qnum=$p(tname,%z("dq"),2)
 . i '$d(^mgtmp($j,"vx",qnum,cname)) s error="column '"_cname_"' in 'set' statement not found in derived table "_alias,error(5)="42S22" q
 . q
 s %defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname) i '%defk,'%defd s error="column '"_cname_"' in 'set' statement not found in table '"_tname_"'",error(5)="42S22" q
set11 d set2 i $l(error) q
 s update("set",cname)=to
 f i=1:1 q:'$d(zcode(i))  s update("set",cname,"zcode",i)=zcode(i)
 s x="" f i=0:0 s x=$o(sqlex("x",x)) q:x=""  s update("set",cname,"i",x)=""
 q
 ;
set2 ; compile set assignment
 ; cm: add %z
 n (%z,dbid,qid,error,to,outv,inv,entpar,del,zcode,sqlex)
 k zcode,sqlex
 s outv=outv_"**set**"
 s l=1,ex(1)=to d ex^%mgsqle(outv,.ex,.word,.code,.fun,.error)
 q
 ;
update1 ; determine if transformation into 'insert' is necessary
 s ins=1
 i '$d(sql(1,3)) s ins=0 q
 f i=1:1:$l(set,",") s x=$p(set,",",i),cname=$p(x," ",1) s:cname?1a.e1"."1a.e cname=$p(cname,".",2) i $l(cname) s wrdx(cname)=$p(x," ",3,999),ino=$$pkey^%mgsqld(dbid,tname) s %def=$$defkdi^%mgsqld(dbid,tname,cname,ino) i %def s ins=0 q
 i 'ins q
 s ln=$p(sql(1,3)," ",2,999)
 d update2 k pkey i 'uni!'uni(0) s ins=0 q
 k sql
 s qnummax=0
 s sql(0,1)="insert"
 s sql(0,2)="into "_tname_" ("
 s sql(0,3)="values ("
 s com="",x="" f i=0:0 s x=$o(wrdx(x)) q:x=""  s sql(0,2)=sql(0,2)_com_x,sql(0,3)=sql(0,3)_com_wrdx(x),com=","
 f i=2,3 s sql(0,i)=sql(0,i)_")"
 q
 ;
update2 ; determine unique restriction for table tname (on primary key)
 n exp,eq,pkeyn
 s uni=1,uni(0)=0 i '$l(ln) s uni=0 q
 k pkey s ino=$$pkey^%mgsqld(dbid,tname),pkeyn=0 s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) i x?1a.e s pkeyn=pkeyn+1,pkey(x)=""
 s exp=ln d eq
 s x="" f i=1:1 s x=$o(eq(x)) q:x=""  s wrdx(x)=eq(x) k pkey(x)
 i pkeyn=(i-1) s uni(0)=1
 i $d(pkey) s (uni,uni(0))=0
 q
 ;
delete ; delete records
 n %om,exp,eq
 s dele=sql(0,1),frm=sql(1,2),exp=$s($d(sql(1,3)):sql(1,3),1:"")
 i $l($p(dele,"delete",2,999)) s error="the 'delete' statement does not take an argument",error(5)="HY000",error(0)="delete",error(1)=0 q
 s tname=$p(frm," ",2),alias=$p(frm," ",3) i tname="" s error="no table supplied in 'from' statement",error(5)="HY000",error(0)="from",error(1)=0 q
 i alias="" s alias=tname
 i $l(exp),exp'?1"where ".e s error="invalid 'where' statement following the 'from' statement",error(5)="HY000",error(0)="from",error(1)=0 q
 i $l(exp) s exp=$p(exp,"where ",2,999)
 i $l(alias),alias'?1a.e s error="invalid alias '"_alias_"'",error(5)="HY000",error(0)="from",error(1)=0 q
 s %d=$$tab^%mgsqld(dbid,tname) i %d="" s error="no such table '"_tname_"'",error(5)="42S02",error(0)="from",error(1)=0 q
 s incwhr=0
 i tname?1a.e s rc=$$ind^%mgsqld(dbid,tname,.%ind) s ino="" f i=0:0 s ino=$o(%ind(ino)) q:ino=""  s sc=$$key^%mgsqld(dbid,tname,ino,.%ind)
 d delete1 i $l(error) q
 i hilev k sql(1) g deletex
 s (com,sel)="",ino=$$pkey^%mgsqld(dbid,tname)
 f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) i x?1a.e s sel=sel_com_x,com=","
 i sel="" s error="no key columns found in table '"_tname_"'",error(5)="HY000",error(0)="from",error(1)=0 q
 s sql(1,1)="select "_sel
 s update("key")=sel
deletex s update("delete")=tname i $l(alias) s update("delete")=update("delete")_" "_alias
 k dele,frm,whe,x,sel,tname,com
 q
 ;
delete1 ; assess possibility of doing high level kill
 s hilev=0 q  ; don't do this for now
 i '$l(exp) s hilev=1 q
 d eq i $l(error) s error="",hilev=0 q
 i 'eq q
 s hilev=1,ino="" f i=0:0 s ino=$o(%ind(ino)) q:ino=""  d delete2 i 'hilev q
 i 'hilev q
 s cname="" f i=0:0 s cname=$o(eq(cname)) q:cname=""  s update("attx",cname)=eq(cname,"c")
 q
 ;
delete2 ; each index must conform to hilev criteria
 s kno=0 f i=1:1 q:'$d(%ind(ino,i))  s cname=%ind(ino,i) i cname?1a.e q:'$d(eq(cname))  s kno=kno+1
 i kno'=eq s hilev=0 q
 q
 ;
eq ; extract contiguous equivalence table
 n word,ex
 k eq s eq=0
 s ex(1)=exp d where^%mgsqle(.ex,.word,.error) i $l(error) k eq s eq=0 q
 k eq s eq=0
 s ok=1 f wn=1:1 q:'$d(word(0,wn))  s wrd=word(0,wn) d eq1 i 'ok k eq s eq=0 q
 q
 ;
eq1 ; verify each word
 n obr,cbr,set,setc,to,alias
 i wrd="or"!(wrd="!") s ok=0 q
 i wrd[%z("df") s ok=0 q
 i wrd'[%z("dsv") q
 s wrd=$p(wrd,%z("dsv"),2),alias="" i wrd["." s alias=$p(wrd,".",1),wrd=$p(wrd,".",2)
 i '$d(word(0,wn+1))!'$d(word(0,wn+2)) s ok=0 q
 i word(0,wn+1)'="=" s ok=0 q
 s to=word(0,wn+2) i to'="(" s (set,setc)=to s:set[%z("dev") set=":"_$p(set,%z("dev"),2) g eq2
 s (obr,cbr)=0,(set,setc)="" f wn1=wn+2:1 q:'$d(word(0,wn1))  s (x,y)=word(0,wn1) s:x="(" obr=obr+1 s:x=")" cbr=cbr+1 s:x[%z("dev") x=":"_$p(x,%z("dev"),2) s set=set_x,setc=setc_y i obr=cbr q
 i set[%z("dsv") s ok=0 q
eq2 s eq(wrd)=set,eq(wrd,"c")=setc,eq(wrd,"f")=alias,eq=eq+1,wn=wn+2
 q
 ;
asn ; extract universal statement assignments
 n dead,word,ex
 k eq1 s eq1=0 ; equals + others - or
 s ex(1)=exp d where^%mgsqle(.ex,.word,.error) i $l(error) q
 f wn=1:1 q:'$d(word(0,wn))  s wrd=word(0,wn) i wrd="!" d asn1
 f wn=1:1 q:'$d(word(0,wn))  s wrd=word(0,wn) i wrd="=",'$d(dead(wn)) d asn2
 q
 ;
asn1 ; remove or + affected variables
 n strt,end,i,obr,cbr,x
 s strt=wn,(obr,cbr)=0 f i=wn-1:-1 q:'$d(word(0,i))  s x=word(0,i),strt=i s:x="(" obr=obr+1 s:x=")" cbr=cbr+1 i obr=(cbr+1) q
 s end=wn,(obr,cbr)=0 f i=wn+1:1 q:'$d(word(0,i))  s x=word(0,i),end=i s:x="(" obr=obr+1 s:x=")" cbr=cbr+1 i cbr=(obr+1) q
 f i=strt:1:end s dead(i)=""
 q
 ;
asn2 ; extract assignment
 n obr,cbr,set,setc,to,alias,wrd
 i '$d(word(0,wn-1)) q
 s wrd=word(0,wn-1) i wrd'[%z("dsv") q
 s wrd=$p(wrd,%z("dsv"),2),alias="" i wrd["." s alias=$p(wrd,".",1),wrd=$p(wrd,".",2)
 i '$d(word(0,wn+1)) q
 s to=word(0,wn+1) i to'="(" s (set,setc)=to s:set[%z("dev") set=":"_$p(set,%z("dev"),2) g asn21
 s (obr,cbr)=0,(set,setc)="" f wn1=wn+1:1 q:'$d(word(0,wn1))  s (x,y)=word(0,wn1) s:x="(" obr=obr+1 s:x=")" cbr=cbr+1 s:x[%z("dev") x=":"_$p(x,%z("dev"),2) s set=set_x,setc=setc_y i obr=cbr q
 i set[%z("dsv") q
asn21 s eq1(wrd)=set,eq1(wrd,"c")=setc,eq1(wrd,"f")=alias,eq1=eq1+1
 q
 ;

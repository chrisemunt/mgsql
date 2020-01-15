%mgsqlo ;(CM) query optimisation procedure ; 12 feb 2002  02:10pm
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2020 M/Gateway Developments Ltd,                      |
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
a d vers^%mgsql("%mgsqlo") q
 ;
main ; optimiser
 n qnum,ord,l,sys,eq,rstr,ord,null,rf,file,tname1,r,f,join,joins,lead,trail,rec,wher
 s qnum=0
opt1 s qnum=qnum+1 i '$d(^mgtmp($j,"from",qnum)) d rec g exit
 s wo="",spc="",index=^mgtmp($j,"from","i","x",qnum)
 f i=1:1 q:'$d(^mgtmp($j,"where",qnum,i))  s wrd=^mgtmp($j,"where",qnum,i) s:wrd[%z("dsv") wrd=$p(wrd,%z("dsv"),2) s wo=wo_spc_wrd,spc=" "
 d word
 d ent
 s sqlman=0
 d opt^%mgsqlo1
 k jn,rstr,rstrcv,join,file
 g opt1
exit ; exit
 q
 ;
word ; generate word array for sub-query
 f i=1:1 q:'$d(^mgtmp($j,"where",qnum,i))  s wrd=^mgtmp($j,"where",qnum,i),word(i)=wrd
 k wrd
 q
 ;
ent ; generate ent array for sub-query
 n alias,slot,done
 k ent,entord
 f i=1:1 q:'$d(^mgtmp($j,"from",qnum,i))  s x=$p(^mgtmp($j,"from",qnum,i),"~",2) i '$d(^mgtmp($j,"from","i",0,x)) s ^mgtmp($j,"from","i",0,x)=0
 f i=1:1 q:'$d(^mgtmp($j,"from",qnum,i))  s alias=$p(^mgtmp($j,"from",qnum,i),"~",2),alias(alias)=i,ent(i)=^mgtmp($j,"from",qnum,i)_"~"_^mgtmp($j,"from","i",0,$p(^mgtmp($j,"from",qnum,i),"~",2))
 s slot=0,alias="" f i=0:0 s alias=$o(%link("ord",qnum,alias)) q:alias=""  s slot=slot+1
 i slot s alias="" f i=0:0 s alias=$o(%link("ord",qnum,alias)) q:alias=""  f i=1:1:slot s entord(i,alias(alias))=""
 f i=1:1 q:'$d(^mgtmp($j,"from","z",qnum,"ord",i))  s alias=^mgtmp($j,"from","z",qnum,"ord",i) i '$d(done(alias)) s slot=slot+1,entord(slot,alias(alias))="",done(alias)=""
 q
 ;
rec ; record optimisation details for user
 n qnum,fct,key,ino,tname,alias,i,ii
 s ref="^mgsqlx(1,dbid,qid,""opt"""
 k @(ref_")")
 f qnum=1:1 q:'$d(^mgtmp($j,"from",qnum))  d rec11
 q
 ;
rec11 ; process sub-query
 s cum=1 f tnum=1:1 q:'$d(^mgtmp($j,"from",qnum,tnum))  s r=^mgtmp($j,"from",qnum,tnum) d rec1
 q
 ;
rec1 ; return full optimisation details for alias
 n kno,x,y,z,i,nds,nds1,nds2,ndst,pnds,com
 s tname=$p(r,"~",1),alias=$p(r,"~",2),ino=^mgtmp($j,"from","i",0,alias) i ino="" s ino=$$pkey^%mgsqld(dbid,tname)
 s alias(alias)=""
 s kno=0,key="",com="",ndst=1 s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) i x?1a.e s kno=kno+1 d rec2
 s @(ref_",qnum,tnum)")=tname_"#"_alias_"#"_ino_"#"_key
 q
 ;
rec2 ; record work involved at each level
 s y=%z("dsv")_alias_"."_x_%z("dsv")
 s (nds,nds1,nds2)=$s($d(^mgsqldbs("e",dbid,tname,ino,kno)):$p(^(kno),"~",1),1:0) i kno>1 s nds1=nds,(nds,nds2)=$s(nds>0:$j(nds/pnds,0,0),1:nds)
 s pnds=nds1,nds="~"_nds
 i $d(rec(y)) s:rec(y)="=" nds="[1]",nds2=1 s:rec(y)'="=" nds="[>"_nds_"<]",nds2=nds2
 i $e(nds)="~" s nds="["_nds_"]"
 s ndst=$s(nds2=1:ndst+1,nds2>1:ndst*nds2,1:ndst),cum=$s(nds2=1:cum+1,nds2>1:cum*nds2,1:cum),key=key_com_x_"#"_cum_"#"_ndst_"#"_nds,com=","
 q
 ;
 
 

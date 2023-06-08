%mgsqlo ;(CM) query optimisation procedure ; 28 Jan 2022  10:01 AM
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2023 MGateway Ltd                                     |
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
main(dbid,qid,sql,error) ; optimiser
 n qnum,word,table,rec
 s qnum=0
opt1 s qnum=qnum+1 i '$d(^mgtmp($j,"from",qnum)) g exit
 d word(dbid,qnum,.word)
 d table(dbid,qnum,.table)
 d opt^%mgsqlo1(dbid,qnum,.word,.table,.rec)
 k word,table
 g opt1
exit ; exit
 d rec(dbid,qid,.rec)
 q
 ;
word(dbid,qnum,word) ; generate word array for sub-query
 n i,wrd
 f i=1:1 q:'$d(^mgtmp($j,"where",qnum,i))  s wrd=^mgtmp($j,"where",qnum,i),word(i)=wrd
 q
 ;
table(dbid,qnum,table) ; generate ent array for sub-query
 n i,x,alias,slot,done
 s slot=0
 f i=1:1 q:'$d(^mgtmp($j,"from",qnum,i))  s x=$p(^mgtmp($j,"from",qnum,i),"~",2) i '$d(^mgtmp($j,"from","i",0,x)) s ^mgtmp($j,"from","i",0,x)=0
 f i=1:1 q:'$d(^mgtmp($j,"from",qnum,i))  d
 . s alias=$p(^mgtmp($j,"from",qnum,i),"~",2),alias(alias)=i
 . s table(0,i)=^mgtmp($j,"from",qnum,i)_"~"_^mgtmp($j,"from","i",0,$p(^mgtmp($j,"from",qnum,i),"~",2))
 f i=1:1 q:'$d(^mgtmp($j,"from","z",qnum,"ord",i))  d
 . s alias=^mgtmp($j,"from","z",qnum,"ord",i) i $d(done(alias)) q
 . s slot=slot+1,table("ord",slot,alias(alias))="",done(alias)=""
 q
 ;
rec(dbid,qid,rec) ; record optimisation details for user
 n ref,qnum
 s ref="^mgsqlx(1,dbid,qid,""opt"""
 k @(ref_")")
 f qnum=1:1 q:'$d(^mgtmp($j,"from",qnum))  d rec1(dbid,qid,qnum,ref,.rec)
 q
 ;
rec1(dbid,qid,qnum,ref,rec) ; process sub-query
 n cum,tnum,cum
 s cum=1 f tnum=1:1 q:'$d(^mgtmp($j,"from",qnum,tnum))  d rec2(dbid,qid,qnum,tnum,ref,.rec,.cum)
 q
 ;
rec2(dbid,qid,qnum,tnum,ref,rec,cum) ; return full optimisation details for alias
 n %ind,r,tname,alias,ino,kno,key,com,sc,i,x
 s r=^mgtmp($j,"from",qnum,tnum)
 s tname=$p(r,"~",1),alias=$p(r,"~",2),ino=^mgtmp($j,"from","i",0,alias) i ino="" s ino=$$pkey^%mgsqld(dbid,tname)
 s kno=0,key="",com="",cum("ndst")=1,sc=$$key^%mgsqld(dbid,tname,ino,.%ind)
 f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) i x?1a.e s kno=kno+1 d rec3(dbid,tname,alias,x,ino,kno,.rec,.cum)
 s @(ref_",qnum,tnum)")=tname_"#"_alias_"#"_ino_"#"_key
 q
 ;
rec3(dbid,tname,alias,cname,ino,kno,rec,cum) ; record work involved at each level
 n y,nds,nds1,nds2
 s y=%z("dsv")_alias_"."_cname_%z("dsv")
 s (nds,nds1,nds2)=$s($d(^mgsqldbs("e",dbid,tname,ino,kno)):$p(^(kno),"~",1),1:0) i kno>1 s nds1=nds,(nds,nds2)=$s(nds>0:$j(nds/cum("pnds"),0,0),1:nds)
 s cum("pnds")=nds1,nds="~"_nds
 i $d(rec(y)) s:rec(y)="=" nds="[1]",nds2=1 s:rec(y)'="=" nds="[>"_nds_"<]",nds2=nds2
 i $e(nds)="~" s nds="["_nds_"]"
 s cum("ndst")=$s(nds2=1:cum("ndst")+1,nds2>1:cum("ndst")*nds2,1:cum("ndst")),cum=$s(nds2=1:cum+1,nds2>1:cum*nds2,1:cum),key=key_com_cname_"#"_cum_"#"_cum("ndst")_"#"_nds,com=","
 q
 ;

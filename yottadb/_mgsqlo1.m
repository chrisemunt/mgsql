%mgsqlo1 ;(CM) query optimisation procedure ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlo1") q
 ;
opt ; optimise sub query
 s bdel="{b}"
 s ops=$$oper^%mgsqle(.ops,.props,.neops)
 d blks i $l(error) q
 d rstr
 d join
 d indx
 d vrfy
 d optim^%mgsqlo2
 q
 ;
blks ; break where statement into blocks by combinational operators
 n i,no,no1,ln,ln1,wrd,wrd1,op,obr,cbr,ok
 k whr
 s no1=0 f i=1:1 q:'$d(word(i))  s whr(no1,i)=word(i)
 s no=""
blks1 s no=$o(whr(no)) i no="" g blks3
 s ln=""
blks2 s ln=$o(whr(no,ln)) i ln="" g blks1
 s wrd=whr(no,ln) i wrd'="&",wrd'="!" g blks2
 s ln1=$o(whr(no,ln),-1) i '$l(ln1) s error="error in structure of the 'where' statement",error(5)="HY000" q
 s wrd1=whr(no,ln1) i wrd1[bdel g blks21
 s no1=no1+1,whr(no,ln1)=bdel_no1_bdel
 i wrd1'=")" s whr(no1,ln1)=wrd1 g blks21
 s obr=0,cbr=1 f  s ln1=$o(whr(no,ln1),-1) q:ln1=""  s wrd1=whr(no,ln1) s:wrd1="(" obr=obr+1 s:wrd1=")" cbr=cbr+1 k whr(no,ln1) q:obr=cbr  s whr(no1,ln1)=wrd1
blks21 s ln1=$o(whr(no,ln)) i '$l(ln1) s error="error in structure of the 'where' statement",error(5)="HY000" q
 s wrd1=whr(no,ln1) i wrd1[bdel g blks2
 s no1=no1+1,whr(no,ln1)=bdel_no1_bdel
 i wrd1'="(" s whr(no1,ln1)=wrd1 g blks2
 s obr=1,cbr=0 f  s ln1=$o(whr(no,ln1)) q:ln1=""  s wrd1=whr(no,ln1) s:wrd1="(" obr=obr+1 s:wrd1=")" cbr=cbr+1 k whr(no,ln1) q:obr=cbr  s whr(no1,ln1)=wrd1
 g blks2
blks3 ; recombine parts to eliminate branches caused by useless brackets
 s no=""
blks4 s no=$o(whr(no)) i no="" g blksx
 s ln=""
blks5 s ln=$o(whr(no,ln)) i ln="" g blks4
 s wrd=whr(no,ln) i wrd'[bdel g blks5
 s no1=$p(wrd,bdel,2)
 s op="",ln1=$o(whr(no,ln),-1) i $l(ln1) s op=whr(no,ln1)
 i op'="&",op'="!" s ln1=$o(whr(no,ln)) i $l(ln1) s op=whr(no,ln1)
 i op'="&",op'="!" g blks5
 s ok=1,ln1="" f  s ln1=$o(whr(no1,ln1)) q:ln1=""  s wrd1=whr(no1,ln1) i wrd1'[bdel,wrd1'=op s ok=0 q
 i 'ok g blks5
 k whr(no,ln)
 s ln1="" f  s ln1=$o(whr(no1,ln1)) q:ln1=""  s whr(no,ln1)=whr(no1,ln1)
 k whr(no1)
 s ln=""
 g blks5
blksx ;
 q
 ;
rstr ; find useful restrictions
 n orbrn,orn
 s orbrn=0
 s root=$o(whr("")) i '$l(root) q
 s no=root d op i '$l(op) q
 i op="&" s orn=1 d and q
 i op="!" d or q
 s orn=1 d rstr1 q
 q
 ;
rstr1 ; process individual restriction
 n tmp
 d op i '$l(op) q
 i op="&"!(op="!") q
 s (obr,cbr)=0,x=opn f  s x=$o(whr(no,x),-1) q:x=""  s wrd=whr(no,x) s:wrd="(" obr=obr+1 s:wrd=")" cbr=cbr+1 q:obr>cbr  s tmp(0,x)=wrd i obr=cbr q
 s n=0,x="" f  s x=$o(tmp(0,x)) q:x=""  s wrd=tmp(0,x) k tmp(0,x) s n=n+1 s tmp(0,n)=wrd
 s (obr,cbr)=0,n=0,x=opn f  s x=$o(whr(no,x)) q:x=""  s wrd=whr(no,x) s:wrd="(" obr=obr+1 s:wrd=")" cbr=cbr+1 q:cbr>obr  s n=n+1,tmp(1,n)=wrd i obr=cbr q
 s vn=0,cn=1,opc=op d rstr2
 i $d(ops(op)) s vn=1,cn=0,opc=ops(op) d rstr2
 q
 ;
rstr2 ; resolve expression into functional restriction wrt 1 variable
 k tmp(5) f i=1:1 q:'$d(tmp(cn,i))  s tmp(5,i)=tmp(cn,i)
 i neops[(":"_op_":") d rstr4 q
 i $d(tmp(vn,1)),'$d(tmp(vn,2)) s sqvar=tmp(vn,1) i sqvar[%z("dsv") d rstr3 q
 q
 ;
rstr3 ; find dependancies in constant
 s sqvar=$p(sqvar,%z("dsv"),2) i sqvar'?1a.e1"."1a.e q
 f andn=1:1 q:'$d(rstr(orbrn,sqvar,orn,andn))
 s n="",cnst=""
rstr31 s n=$o(tmp(5,n)) i n="" g rstr32
 s (wrd,wrd1)=tmp(5,n)
 s var="" i wrd[%z("dsv") s var=$p(wrd,%z("dsv"),2)
 i var?1a.e1"."1a.e s rstr(orbrn,sqvar,orn,andn,"dep",var)=""
 s cnst=cnst_wrd
 g rstr31
rstr32 ; file restriction
 s rstr(orbrn,sqvar,orn,andn,"op")=opc
 s rstr(orbrn,sqvar,orn,andn,"cnst")=cnst
 i cnst'[%z("dev") q
 s (alias,tname)=$p(sqvar,".",1),cname=$p(sqvar,".",2)
 i alias'="" s tno=$g(^mgtmp($j,"from","x",qnum,alias)) i tno'="" s tname=$p($g(^mgtmp($j,"from",qnum,tno)),"~",1)
 s ^mgtmp($j,"in",$p(cnst,%z("dev"),2))="~"_tname_"~"_cname
 q
 ;
rstr4 ; evaluate possible not-null restriction
 i orbrn'=0 q
 i '$d(tmp(vn,1))!'$d(tmp(5,1)) q
 i $d(tmp(vn,2))!$d(tmp(5,2)) q
 s sqvar=tmp(vn,1) i sqvar'[%z("dsv") q
 s sqvar=$p(sqvar,%z("dsv"),2) i sqvar'?1a.e1"."1a.e q
 s cnst=tmp(5,1)
 i op="'=",cnst="""""" s notnull(sqvar)=""
 i op="[",cnst?1""""1e.e1"""" s notnull(sqvar)=""
 q
 ;
and ; process and conditions
 s x=""
and1 s x=$o(whr(no,x)) i x="" q
 s wrd=whr(no,x) i wrd'[bdel g and1
 s no1=$p(wrd,bdel,2)
 d and2
 g and1
 ;
and2 ; branch beneath and combination
 n no,x
 s no=no1 d op
 i op="&" q
 i op="!" d or
 d rstr1
 q
 ;
or ; process or conditions
 s orbrn=orbrn+1,orn=0,x=""
or1 s x=$o(whr(no,x)) i x="" q
 s wrd=whr(no,x) i wrd'[bdel g or1
 s no1=$p(wrd,bdel,2)
 d or2
 g or1
 ;
or2 ; branch beneath or combination
 n no,x
 s orn=orn+1
 s no=no1 d op
 i op="&" d and
 i op="!" q
 d rstr1
 q
 ;
op ; extract combinational or comparison operator for group
 n x,wrd,wrd1
 s (op,opn)=""
 s x="" f  s x=$o(whr(no,x)) q:x=""  s wrd=whr(no,x),wrd1=":"_wrd_":" i wrd="!"!(wrd="&")!(neops[wrd1)!(props[wrd1) s op=wrd,opn=x q
 q
 ;
join ; make comprehensive join index
 n jn,cname,alias,sqvar
 s jn=0
 s cname="" f  s cname=$o(^mgtmp($j,"from","z",qnum,"join",cname)) q:cname=""  d
 . s jn=jn+1
 . s alias="" f  s alias=$o(^mgtmp($j,"from","z",qnum,"join",cname,alias)) q:alias=""  d
 . . s sqvar=alias_"."_cname
 . . s jnx(jn,sqvar)=""
 . . q
 . q
 q
 ;
indx ; get all index information
 f i=1:1 q:'$d(ent(i))  s tname=ent(i),alias=$p(tname,"~",2),tname=$p(tname,"~",1) d indx1
 s nofid=i-1
 q
 ;
indx1 ; retrieve index data for file tname
 n i,pkey
 s rc=$$ind^%mgsqld(dbid,tname,.%ind)
 s ino=""
indx2 s ino=$o(%ind(ino)) i ino="" g indxx
 i $d(^mgtmp($j,"create","index")),ino=$p(^mgtmp($j,"create","index"),"~",2) g indx2
 s sc=$$key^%mgsqld(dbid,tname,ino,.%ind)
 s kno=0,ano=0,pnds=0
indx3 s kno=kno+1 i '$d(%ind(ino,kno)) g indx2
 s cname=%ind(ino,kno) i cname'?1a.e g indx3
 s ano=ano+1,sqvar=alias_"."_cname
 i ino=$$pkey^%mgsqld(dbid,tname) s pkey(cname)=""
 s keyat=$d(pkey(cname))
 s notnl=0,%d=$$item^%mgsqld(dbid,tname,cname) i %d'="",$p(%d,"\",4) s notnl=1
 i keyat s notnl=1
 i notnl s notnull(sqvar)=""
 s (nds,nnds)=0 i $d(^mgsqldbs("e",dbid,tname,ino,ano)) s (nds,nnds)=$p(^(ano),"~",1) s:pnds>0 nnds=$j(nds/pnds,0,0) s pnds=nds
 s indxa("e",alias,ino)=ano,indxa("e",alias,ino,ano)=cname_"~"_keyat_"~"_notnl_"~"_""_"~"_nds_"~"_nnds
 g indx3
indxx k %ind,ino,ano,kno,cname,keyat,notnl,nds,nnds,pnnds
 q
 ;
vrfy ; verify indices for usage
 n alias,cname,sqvar,sqvar1,notnul,ino,kno,jn
 s alias=""
vrfy1 s alias=$o(indxa("e",alias)) i alias="" g vrfyx
 s ino=""
vrfy2 s ino=$o(indxa("e",alias,ino)) i ino="" g vrfy1
 i $d(cuse(alias,ino)) g vrfy2 ; index disqualified already
 s ano=0
vrfy3 s ano=ano+1 i '$d(indxa("e",alias,ino,ano)) g vrfy2
 s r=indxa("e",alias,ino,ano)
 s cname=$p(r,"~",1),notnl=$p(r,"~",3),sqvar=alias_"."_cname
 i notnl g vrfy4
 i $d(notnull(sqvar)) s notnl=1 g vrfy4
 s jn="" f  s jn=$o(jnx(jn)) q:jn=""!notnl  i $d(jnx(jn,sqvar)) s sqvar1=""  f  s sqvar1=$o(jnx(jn,sqvar1)) q:sqvar1=""  i sqvar1'=sqvar,$d(notnull(sqvar1)) s notnl=1 q
vrfy4 i 'notnl s duse(alias,ino)="" g vrfy2
 s $p(indxa("e",alias,ino,ano),"~",3)=notnl,notnull(sqvar)=""
 g vrfy3
vrfyx ;
 q
 ;
 

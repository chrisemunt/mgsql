%mgsqlo1 ;(CM) query optimisation procedure ; 28 Jan 2022  10:01 AM
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
a d vers^%mgsql("%mgsqlo1") q
 ;
opt(dbid,qnum,word,table,rec) ; optimise sub query
 n ops,props,neops,whr,rstr,notnull,join,indxa
 s ops=$$oper^%mgsqle(.ops,.props,.neops)
 d blks(.word,.whr) i $l(error) q
 d rstr(.whr,.ops,neops,props,.rstr,.notnull)
 d join(qnum,.join)
 d indx(dbid,.table,.indxa)
 d vrfy(.join,.indxa,.notnull)
 d optimise^%mgsqlo2(dbid,qnum,.table,.rstr,.join,.indxa,.rec)
 q
 ;
blks(word,whr) ; break where statement into blocks by combinational operators
 n i,no,no1,ln,ln1,wrd,wrd1,op,obr,cbr,ok
 k whr
 s no1=0 f i=1:1 q:'$d(word(i))  s whr(no1,i)=word(i)
 s no=""
blks1 s no=$o(whr(no)) i no="" g blks3
 s ln=""
blks2 s ln=$o(whr(no,ln)) i ln="" g blks1
 s wrd=whr(no,ln) i wrd'="&",wrd'="!" g blks2
 s ln1=$o(whr(no,ln),-1) i '$l(ln1) s error="error in structure of the 'where' statement",error(5)="HY000" q
 s wrd1=whr(no,ln1) i wrd1[%z("db") g blks21
 s no1=no1+1,whr(no,ln1)=%z("db")_no1_%z("db")
 i wrd1'=")" s whr(no1,ln1)=wrd1 g blks21
 s obr=0,cbr=1 f  s ln1=$o(whr(no,ln1),-1) q:ln1=""  s wrd1=whr(no,ln1) s:wrd1="(" obr=obr+1 s:wrd1=")" cbr=cbr+1 k whr(no,ln1) q:obr=cbr  s whr(no1,ln1)=wrd1
blks21 s ln1=$o(whr(no,ln)) i '$l(ln1) s error="error in structure of the 'where' statement",error(5)="HY000" q
 s wrd1=whr(no,ln1) i wrd1[%z("db") g blks2
 s no1=no1+1,whr(no,ln1)=%z("db")_no1_%z("db")
 i wrd1'="(" s whr(no1,ln1)=wrd1 g blks2
 s obr=1,cbr=0 f  s ln1=$o(whr(no,ln1)) q:ln1=""  s wrd1=whr(no,ln1) s:wrd1="(" obr=obr+1 s:wrd1=")" cbr=cbr+1 k whr(no,ln1) q:obr=cbr  s whr(no1,ln1)=wrd1
 g blks2
blks3 ; recombine parts to eliminate branches caused by useless brackets
 s no=""
blks4 s no=$o(whr(no)) i no="" g blksx
 s ln=""
blks5 s ln=$o(whr(no,ln)) i ln="" g blks4
 s wrd=whr(no,ln) i wrd'[%z("db") g blks5
 s no1=$p(wrd,%z("db"),2)
 s op="",ln1=$o(whr(no,ln),-1) i $l(ln1) s op=whr(no,ln1)
 i op'="&",op'="!" s ln1=$o(whr(no,ln)) i $l(ln1) s op=whr(no,ln1)
 i op'="&",op'="!" g blks5
 s ok=1,ln1="" f  s ln1=$o(whr(no1,ln1)) q:ln1=""  s wrd1=whr(no1,ln1) i wrd1'[%z("db"),wrd1'=op s ok=0 q
 i 'ok g blks5
 k whr(no,ln)
 s ln1="" f  s ln1=$o(whr(no1,ln1)) q:ln1=""  s whr(no,ln1)=whr(no1,ln1)
 k whr(no1)
 s ln=""
 g blks5
blksx ; exit
 q
 ;
recomb(whr,stat)
 n n,bn,pre,pst
 f  q:stat'[%z("db")  d
 . s bn=$p(stat,%z("db"),2)
 . s pre=$p(stat,%z("db"),1)
 . s pst=$p(stat,%z("db"),3,999)
 . s n="" f  s n=$o(whr(bn,n)) q:n=""  s pre=pre_whr(bn,n)
 . s stat=pre_pst
 . q
 q stat
 ;
rstr(whr,ops,neops,props,rstr,notnull) ; find useful restrictions
 n orbrn,orn,root,no,op,opn
 s orbrn=0,orn=0
 s root=$o(whr("")) i '$l(root) q
 s no=root,op=$$op(.whr,no,neops,props,.opn) i '$l(op) q
 i op="&" s orn=1 d and(.whr,no,.ops,neops,props,.opn) q
 i op="!" d or(.whr,no,.orbrn,.orn,.rstr,.notnull,.ops,neops,props,.opn) q
 s orn=1 d rstr1(.whr,no,.orbrn,.orn,.rstr,.notnull,.ops,neops,props) q
 q
 ;
rstr1(whr,no,orbrn,orn,rstr,notnull,ops,neops,props) ; process individual restriction
 n tmp,op,obr,cbr,x,wrd,n,vn,cn,opc,opn
 s op=$$op(.whr,no,neops,props,.opn) i '$l(op) q
 i op="&"!(op="!") q
 s (obr,cbr)=0,x=opn f  s x=$o(whr(no,x),-1) q:x=""  s wrd=whr(no,x) s:wrd="(" obr=obr+1 s:wrd=")" cbr=cbr+1 q:obr>cbr  s tmp(0,x)=wrd i obr=cbr q
 s n=0,x="" f  s x=$o(tmp(0,x)) q:x=""  s wrd=tmp(0,x) k tmp(0,x) s n=n+1 s tmp(0,n)=wrd
 s (obr,cbr)=0,n=0,x=opn f  s x=$o(whr(no,x)) q:x=""  s wrd=whr(no,x) s:wrd="(" obr=obr+1 s:wrd=")" cbr=cbr+1 q:cbr>obr  s n=n+1,tmp(1,n)=wrd i obr=cbr q
 s vn=0,cn=1,opc=op d rstr2(.whr,.tmp,cn,vn,opc,.orbrn,.orn,.rstr,.notnull,neops)
 i $d(ops(op)) s vn=1,cn=0,opc=ops(op) d rstr2(.whr,.tmp,cn,vn,opc,.orbrn,.orn,.rstr,.notnull,neops)
 q
 ;
rstr2(whr,tmp,cn,vn,opc,orbrn,orn,rstr,notnull,neops) ; resolve expression into functional restriction wrt 1 variable
 n i
 k tmp(5) f i=1:1 q:'$d(tmp(cn,i))  s tmp(5,i)=tmp(cn,i)
 i neops[(":"_op_":") d rstr4(.tmp,vn,op,.orbrn,.notnull) q
 i $d(tmp(vn,1)),'$d(tmp(vn,2)) d rstr3(.whr,.tmp,vn,opc,.orbrn,.orn,.rstr) q
 q
 ;
rstr3(whr,tmp,vn,opc,orbrn,orn,rstr) ; find dependancies in constant
 n sqvar,andn,n,cnst,wrd,wrd1,var,alias,tname,tno
 s sqvar=tmp(vn,1) i sqvar'[%z("dsv") q
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
 s rstr(orbrn,sqvar,orn,andn,"cnst")=$$recomb(.whr,cnst)
 i cnst'[%z("dev") q
 s (alias,tname)=$p(sqvar,".",1),cname=$p(sqvar,".",2)
 i alias'="" s tno=$g(^mgtmp($j,"from","x",qnum,alias)) i tno'="" s tname=$p($g(^mgtmp($j,"from",qnum,tno)),"~",1)
 s ^mgtmp($j,"in",$p(cnst,%z("dev"),2))="~"_tname_"~"_cname
 q
 ;
rstr4(tmp,vn,op,orbrn,notnull) ; evaluate possible not-null restriction
 n sqvar,cnst
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
and(whr,no,ops,neops,props,opn) ; process and conditions
 n x,wrd,no1
 s x=""
and1 s x=$o(whr(no,x)) i x="" q
 s wrd=whr(no,x) i wrd'[%z("db") g and1
 s no1=$p(wrd,%z("db"),2)
 d and2(.whr,no1,.orbrn,.orn,.rstr,.notnull,.ops,neops,props,.opn)
 g and1
 ;
and2(whr,no,orbrn,orn,rstr,notnull,ops,neops,props,opn) ; branch beneath and combination
 n op
 s op=$$op(.whr,no,neops,props,.opn)
 i op="&" q
 i op="!" d or(.whr,no,.orbrn,.orn,.rstr,.notnull,.ops,neops,props,.opn)
 d rstr1(.whr,no,.orbrn,.orn,.rstr,.notnull,.ops,neops,props)
 q
 ;
or(whr,no,orbrn,orn,rstr,notnull,ops,neops,props,opn) ; process or conditions
 n x,wrd
 s orbrn=orbrn+1,orn=0,x=""
or1 s x=$o(whr(no,x)) i x="" q
 s wrd=whr(no,x) i wrd'[%z("db") g or1
 s no1=$p(wrd,%z("db"),2)
 d or2(.whr,no1,.orbrn,.orn,.rstr,.notnull,.ops,neops,props,.opn)
 g or1
 ;
or2(whr,no,orbrn,orn,rstr,notnull,ops,neops,props,opn) ; branch beneath or combination
 n op
 s orn=orn+1
 s op=$$op(.whr,no,neops,props,.opn)
 i op="&" d and(.whr,no,.ops,neops,props,.opn)
 i op="!" q
 d rstr1(.whr,no,.orbrn,.orn,.rstr,.notnull,.ops,neops,props)
 q
 ;
op(whr,no,neops,props,opn) ; extract combinational or comparison operator for group
 n x,wrd,wrd1
 s (op,opn)=""
 s x="" f  s x=$o(whr(no,x)) q:x=""  s wrd=whr(no,x),wrd1=":"_wrd_":" i wrd="!"!(wrd="&")!(neops[wrd1)!(props[wrd1) s op=wrd,opn=x q
 q op
 ;
join(qnum,join) ; make comprehensive join index
 n jn,cname,alias,sqvar
 s jn=0
 s cname="" f  s cname=$o(^mgtmp($j,"from","z",qnum,"join",cname)) q:cname=""  d
 . s jn=jn+1
 . s alias="" f  s alias=$o(^mgtmp($j,"from","z",qnum,"join",cname,alias)) q:alias=""  d
 . . s sqvar=alias_"."_cname
 . . s join(jn,sqvar)=""
 . . q
 . q
 q
 ;
indx(dbid,table,indxa) ; get all index information
 n i
 f i=1:1 q:'$d(table(0,i))  d indx1(dbid,.table,i,.indxa)
 ;s nofid=i-1
 q
 ;
indx1(dbid,table,no,indxa) ; retrieve index data for file tname
 n %ind,%d,tname,cname,alias,rc,ino,kno,ano,pnds,sqvar,pkey,keyat,notnl,nds,nnds
 s tname=table(0,no),alias=$p(tname,"~",2),tname=$p(tname,"~",1)
 s rc=$$ind^%mgsqld(dbid,tname,.%ind)
 ; get primary key
 s ino=$$pkey^%mgsqld(dbid,tname),rc=$$key^%mgsqld(dbid,tname,ino,.%ind)
 f kno=1:1 q:'$d(%ind(ino,kno))  s cname=%ind(ino,kno) i cname?1a.e s pkey(cname)=""
 s ino=""
indx2 s ino=$o(%ind(ino)) i ino="" g indxx
 i $d(^mgtmp($j,"create","index")),ino=$p(^mgtmp($j,"create","index"),"~",2) g indx2
 s rc=$$key^%mgsqld(dbid,tname,ino,.%ind)
 s kno=0,ano=0,pnds=0
indx3 s kno=kno+1 i '$d(%ind(ino,kno)) g indx2
 s cname=%ind(ino,kno) i cname'?1a.e g indx3
 s ano=ano+1,sqvar=alias_"."_cname
 s keyat=$d(pkey(cname))
 s notnl=0,%d=$$item^%mgsqld(dbid,tname,cname) i %d'="",$p(%d,"\",4) s notnl=1
 i keyat s notnl=1
 i notnl s notnull(sqvar)=""
 s (nds,nnds)=0 i $d(^mgsqldbs("e",dbid,tname,ino,ano)) s (nds,nnds)=$p(^(ano),"~",1) s:pnds>0 nnds=$j(nds/pnds,0,0) s pnds=nds
 s indxa("e",alias,ino)=ano,indxa("e",alias,ino,ano)=cname_"~"_keyat_"~"_notnl_"~"_""_"~"_nds_"~"_nnds
 g indx3
indxx ; exit
 q
 ;
vrfy(join,indxa,notnull) ; verify indices for usage
 n alias,cname,sqvar,sqvar1,notnl,ino,kno,ano,r,jn
 s alias=""
vrfy1 s alias=$o(indxa("e",alias)) i alias="" g vrfyx
 s ino=""
vrfy2 s ino=$o(indxa("e",alias,ino)) i ino="" g vrfy1
 i $d(indxa("cuse",alias,ino)) g vrfy2 ; index disqualified already
 s ano=0
vrfy3 s ano=ano+1 i '$d(indxa("e",alias,ino,ano)) g vrfy2
 s r=indxa("e",alias,ino,ano)
 s cname=$p(r,"~",1),notnl=$p(r,"~",3),sqvar=alias_"."_cname
 i notnl g vrfy4
 i $d(notnull(sqvar)) s notnl=1 g vrfy4
 s jn="" f  s jn=$o(join(jn)) q:jn=""!notnl  i $d(join(jn,sqvar)) s sqvar1=""  f  s sqvar1=$o(join(jn,sqvar1)) q:sqvar1=""  i sqvar1'=sqvar,$d(notnull(sqvar1)) s notnl=1 q
vrfy4 i 'notnl s indxa("duse",alias,ino)="" g vrfy2
 s $p(indxa("e",alias,ino,ano),"~",3)=notnl,notnull(sqvar)=""
 g vrfy3
vrfyx ; exit
 q
 ;

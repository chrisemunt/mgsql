%mgsqlo2 ;(CM) query optimisation procedure ; 28 Jan 2022  10:01 AM
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
 s ordn=0,ordm=3 f iii=1:1:20000 s ordn=$$ord(ordm,ordn,.ord) q:ord=""  w !,ordn," ",ord
 q
a d vers^%mgsql("%mgsqlo2") q
 ;
optimise(dbid,qnum,table,rstr,join,indxa,rec) ; optimise sub query
 n ord
 s ord=$$comb(dbid,qnum,.table,.rstr,.join,.indxa)
 d compapi(dbid,qnum,.table,.rstr,.join,.indxa,.rec,ord)
 q
 ;
comb(dbid,qnum,table,rstr,join,indxa) ; look at combinations
 n optim,wkfct2,nofid,ordn,ordm,ord,ok,nrun,rec,comb,r,i,wkfct,wkfct2,wkfctb,nodes,nds,ino,inos,tname
 s optim=1,wkfct2=0
 s nofid=$o(table(0,""),-1)
 s ordn=0,ordm=nofid
comb1 s ordn=$$ord(ordm,ordn,.ord) i ord="" g combx
 s ok=1 f ordn=1:1:nofid i $d(table("ord",ordn)) s nrun=$p(ord,"#",ordn) i '$d(table("ord",ordn,nrun)) s ok=0 q
 i 'ok g comb1
 d comb2(dbid,qnum,ord,nofid,.table,.rstr,.join,.indxa,.comb,.rec,optim)
 g comb1
combx ; exit
 s wkfct2=$g(comb("wkfct2"))+0
 s ord="" f  s ord=$o(comb(0,ord)) q:ord=""  s r=comb(0,ord),wkfct=$p(r,"~",1),wkfctb=$p(r,"~",2),nodes=$p(r,"~",3) i wkfct=wkfct2 s nds(nodes,wkfctb,ord)=""
 s nodes=$o(nds("")) i $l(nodes) s wkfctb=$o(nds(nodes,""),-1) i $l(wkfctb) s ord=$o(nds(nodes,wkfctb,""))
 s inos=""
 i ord'="",$d(comb(0,ord)) s inos=$p(comb(0,ord),"~",4)
 i ord="" s ordn=$$ord(ordm,0,.ord)
 f ordn=1:1:ordm s nrun=$p(ord,"#",ordn) d
 . s tname=$p(table(0,nrun),"~",1)
 . s ino=$p(inos,"#",ordn)
 . i ino="" s ino=$$pkey^%mgsqld(dbid,tname)
 . s $p(table(0,nrun),"~",3)=ino
 . q
 q ord
 ;
comb2(dbid,qnum,ord,nofid,table,rstr,join,indxa,comb,rec,optim) ; evaluate combination
 n inos,wkfcts,nodess,dlms,nord,nodes,nodes1,wkfct,wkfct1,wkfct2,wkfcts,wkfctb1,wkfctb2,wkfctbn1,nord,nrun,tname,alias,ino,inos,got
 s (inos,wkfcts,nodess,dlms)=""
 s nord=0,nodes1=0,wkfct1=0,wkfct2=0,wkfctb1=0,wkfctbn1=0
comb21 s nord=nord+1,nrun=$p(ord,"#",nord)
 s alias=table(0,nrun),tname=$p(alias,"~",1),alias=$p(alias,"~",2)
 s ino=$$idx(dbid,qnum,tname,alias,.rstr,.join,.indxa,.got,.nodes,.wkfct,.rec,optim),got("f",alias)=""
 s nodes1=nodes1+nodes,wkfct1=wkfct1+(wkfct/nofid)
 s wkfctb1=wkfctb1+(wkfct/nord),wkfctbn1=wkfctbn1+(1/nord)
 s inos=inos_dlms_ino,wkfcts=wkfcts_dlms_wkfct,nodess=nodess_dlms_nodes,dlms="#"
 i nord<nofid g comb21
comb22 s wkfctb2=$j(wkfctb1/wkfctbn1,"",12)+0
 s wkfct1=$j(wkfct1,"",12)+0
 i wkfct1>wkfct2 s wkfct2=wkfct1
 s comb(0,ord)=wkfct1_"~"_wkfctb2_"~"_nodes1_"~"_inos_"~"_wkfcts_"~"_nodess
 s comb("wkfct2")=wkfct2
 q
 ;
idx(dbid,qnum,tname,alias,rstr,join,indxa,got,nodes,wkfct,rec,optim) ; select best index (output: ino, dep, sat, nodes, wkfct)
 n ino,inop,maxdep,maxsat,maxscr,ano,nnodes,rstrto,rstrn,dep,sat,scr,r,cname,nnodes,sqvar,orn,andn,use,idx,nds
 s ino="",maxdep=0,maxsat=0,maxscr=0
idx1 s ino=$o(indxa("e",alias,ino)) i ino="" g idxx
 i $d(indxa("cuse",alias,ino)) g idx1
 i optim,$d(indxa("duse",alias,ino)) g idx1
 k got("a",alias)
 s ano=0,nodes=0,rstrto=-1,rstrn=0
idx2 s ano=ano+1 i '$d(indxa("e",alias,ino,ano)) g idx2x
 s r=indxa("e",alias,ino,ano)
 s cname=$p(r,"~",1),nnodes=$p(r,"~",6),sqvar=alias_"."_cname
 d idx3(sqvar,ino,.rstr,.join,.use,.got)
 s got("a",alias,cname)=""
 i '$d(use(ino,sqvar)) s:rstrto=-1 rstrto=ano-1 s nodes=nodes+nnodes
 i $d(use(ino,sqvar)) s rstrn=rstrn+1
 g idx2
idx2x ; index processed
 s ano=ano-1
 s dep=rstrto/ano,sat=rstrn/ano
 i dep>maxdep s maxdep=dep
 i sat>maxsat s maxsat=sat
 s idx(ino)=dep_"~"_sat_"~"_(nodes+0)_"~"_(dep+sat)
 g idx1
idxx ; choose best index
 ; eliminate useless indices
 s ino="" f  s ino=$o(idx(ino)) q:ino=""  s r=idx(ino),dep=$p(r,"~",1),sat=$p(r,"~",2) i dep<maxdep,sat<maxsat k idx(ino)
 ; eliminate indices with sub-optimal scores
 s ino="" f  s ino=$o(idx(ino)) q:ino=""  s r=idx(ino),scr=$p(r,"~",4) i scr>maxscr s maxscr=scr
 s ino="" f  s ino=$o(idx(ino)) q:ino=""  s r=idx(ino),scr=$p(r,"~",4) i scr<maxscr k idx(ino)
 s ino="" f  s ino=$o(idx(ino)) q:ino=""  s nodes=$p(idx(ino),"~",3),nds(nodes,ino)=""
 s inop=$$pkey^%mgsqld(dbid,tname)
 ; look at node counts, if available
 s nodes=$o(nds("")) i nodes'="" d
 . i $d(nds(nodes,inop)) s ino=inop q
 . s ino=$o(nds(nodes,""))
 . q
 i ino="" s ino=inop
 i nodes="" s nodes=0
 s (dep,sat)=0
 i $d(idx(ino)) s r=idx(ino),dep=$p(r,"~",1),sat=$p(r,"~",2)
 s wkfct=(dep+sat)/2
 i optim q ino
 s sqvar="" f  s sqvar=$o(use(ino,sqvar)) q:sqvar=""  d
 . s orn="" f  s orn=$o(use(ino,sqvar,orn)) q:orn=""  d
 . . s andn="" f  s andn=$o(use(ino,sqvar,orn,andn)) q:andn=""  d idx4(qnum,sqvar,ino,orn,andn,.use,.rec)
 . . q
 . q
 q ino
 ;
idx3(sqvar,ino,rstr,join,use,got) ; find/join to a restriction
 n jn,ok,sqvar1,orbrn,orn,andn
 s jn="",ok=0 f  s jn=$o(join(jn)) q:jn=""  i $d(join(jn,sqvar)) d  i ok q
 . s sqvar1="" f  s sqvar1=$o(join(jn,sqvar1)) q:sqvar1=""  i sqvar1'=sqvar s ok=$$gotat(sqvar1,.got) i ok q
 . q
 i ok s use(ino,sqvar,1,1,"op")="=",use(ino,sqvar,1,1,"cnst")=%z("dsv")_sqvar1_%z("dsv") g idx3x
 s orbrn=""
idx31 i $d(use(sqvar)) g idx3x
 s orbrn=$o(rstr(orbrn)) i orbrn="" g idx3x
 s orn=""
idx32 s orn=$o(rstr(orbrn,sqvar,orn)) i orn="" g idx31
 s andn=""
idx33 s andn=$o(rstr(orbrn,sqvar,orn,andn)) i andn="" g idx32
 s ok=1,sqvar1="" f  s sqvar1=$o(rstr(orbrn,sqvar,orn,andn,"dep",sqvar1)) q:sqvar1=""  s ok=$$gotat(sqvar1,.got) i 'ok q
 i 'ok,orbrn'=0 k use(sqvar) g idx31
 i 'ok g idx33
 s use(ino,sqvar,orn,andn,"op")=rstr(orbrn,sqvar,orn,andn,"op")
 s use(ino,sqvar,orn,andn,"cnst")=rstr(orbrn,sqvar,orn,andn,"cnst")
 g idx33
idx3x ; exit
 q
 ;
idx4(qnum,sqvar,ino,orn,andn,use,rec) ; file restriction for compiler to use
 s (^mgtmp($j,"pre",qnum,%z("dsv")_sqvar_%z("dsv"),orn,andn,"op"),rec(%z("dsv")_sqvar_%z("dsv")))=use(ino,sqvar,orn,andn,"op")
 s ^mgtmp($j,"pre",qnum,%z("dsv")_sqvar_%z("dsv"),orn,andn,"cnst")=use(ino,sqvar,orn,andn,"cnst")
 q
 ;
gotat(sqvar,got) ; determine whether sqvar1 is available at this point
 n alias,cname,ok
 s ok=0,alias=$p(sqvar,".",1),cname=$p(sqvar,".",2)
 i alias=""!(cname="") q ok
 s ok=0 i $d(got("a",alias,cname)) s ok=1 q ok
 q ok
 ;
ord(ordm,ordn,ord) ; get next running order
 n i,j,x,y,ok
 s ordn=ordn+1 i ordn=1 g ord1
 s ok=0 f i=ordm:-1:1 s x=$$ord2(i,.ord) i x'="" s $p(ord,"#",i)=x q
 i x="" s ord="" q ordn
 f j=1:1:i s y($p(ord,"#",j))=""
 f i=i+1:1:ordm f j=1:1 i '$d(y(j)) s $p(ord,"#",i)=j,y(j)="" q
 q ordn
ord1 ; first pass
 f i=1:1:ordm s $p(ord,"#",i)=i
 q ordn
 ;
ord2(no,ord) ; get next allowed number in series
 n j,y,x,ok
 f j=1:1:no-1 s y($p(ord,"#",j))=""
 s x=$p(ord,"#",no),ok=0 f j=x+1:1 s:'$d(y(j)) x=j,ok=1 i ok q
 i x>ordm s ok=0
 i 'ok s x=""
 q x
 ;
compapi(dbid,qnum,table,rstr,join,indxa,rec,ord) ; interface to compiler
 n optim,nofid,ordn,comb,nord,nino,i,tname,alias
 s optim=0
 s nofid=$o(table(0,""),-1)
 s table("ordx")=ord
 ; process opimisation hints
 i $d(^mgtmp($j,"from","i","f")) d
 . s nord=""
 . i '$d(table("ord")) f i=1:1:nofid s nord=nord_$s(i>1:"#",1:"")_i
 . f i=1:1:nofid d
 . . s tname=$p(table(0,i),"~",1),alias=$p(table(0,i),"~",2),nino=""
 . . i alias'="" s nino=$g(^mgtmp($j,"from","i","f",alias))
 . . i nino="" s nino=$g(^mgtmp($j,"from","i","f",tname))
 . . i nino'="" s $p(table(0,i),"~",3)=nino
 . . q
 . s ord=nord,table("ordx")=ord
 . q
 ; optimisation complete and hints acknowledged
 k ^mgtmp($j,"from",qnum),^mgtmp($j,"from","x",qnum)
 f ordn=1:1:nofid d compapi1(dbid,qnum,.table,.rstr,.join,.indxa,ord,ordn)
 d comb2(dbid,qnum,ord,nofid,.table,.rstr,.join,.indxa,.comb,.rec,optim)
 q
 ;
compapi1(dbid,qnum,table,rstr,join,indxa,ord,ordn) ; disallow all indices except chosen one
 n nrun,alias,tname,ino,ino1
 s nrun=$p(ord,"#",ordn)
 s alias=table(0,nrun),tname=$p(alias,"~",1),ino=$p(alias,"~",3),alias=$p(alias,"~",2)
 k indxa("cuse",alias,ino)
 s ino1="" f  s ino1=$o(indxa("e",alias,ino1)) q:ino1=""  i ino1'=ino s indxa("cuse",alias,ino1)=""
 s ^mgtmp($j,"from",qnum,ordn)=tname_"~"_alias,(^mgtmp($j,"from","x",qnum,tname),^mgtmp($j,"from","x",qnum,alias))=ordn,^mgtmp($j,"from","i",0,alias)=ino
 q
 ;

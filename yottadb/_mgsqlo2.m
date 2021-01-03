%mgsqlo2 ;(CM) query optimisation procedure ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlo2") q
 ;
optim ; optimise sub query
 d comb
 d comp
 q
 ;
comb ; look at combinations
 s optim=1,wkfct2=0
 s ordn=0,ordm=nofid
comb1 d ord i ord="" g combx
 s ok=1 f ordn=1:1:nofid i $d(entord(ordn)) s nrun=$p(ord,"#",ordn) i '$d(entord(ordn,nrun)) s ok=0 q
 i 'ok g comb1
 d comb2
 g comb1
combx s ord="" f  s ord=$o(comb(ord)) q:ord=""  s r=comb(ord),wkfct=$p(r,"~",1),wkfctb=$p(r,"~",2),nodes=$p(r,"~",3) i wkfct=wkfct2 s nds(nodes,wkfctb,ord)=""
 s nodes=$o(nds("")) i $l(nodes) s wkfctb=$o(nds(nodes,""),-1) i $l(wkfctb) s ord=$o(nds(nodes,wkfctb,""))
 i $l(ord),$d(comb(ord)) s inos=$p(comb(ord),"~",4)
 i '$l(ord) s ordn=0 d ord
 i '$l(inos) s dlm="" f i=1:1:ordm s ord=ord_dlm_"0",dlm="#"
 q
 ;
comb2 ; evaluate combination
 n nord,nrun,tname,alias,got
 s (inos,wkfcts,nodess,dlms)=""
 s nord=0,nodes1=0,wkfct1=0,wkfct2=0,wkfctb1=0,wkfctbn1=0
comb21 s nord=nord+1,nrun=$p(ord,"#",nord)
 s alias=ent(nrun),tname=$p(alias,"~",1),alias=$p(alias,"~",2)
 d idx s got("f",alias)=""
 s nodes1=nodes1+nodes,wkfct1=wkfct1+(wkfct/nofid)
 s wkfctb1=wkfctb1+(wkfct/nord),wkfctbn1=wkfctbn1+(1/nord)
 s inos=inos_dlms_ino,wkfcts=wkfcts_dlms_wkfct,nodess=nodess_dlms_nodes,dlms="#"
 i nord<nofid g comb21
comb22 s wkfctb2=$j(wkfctb1/wkfctbn1,"",12)+0
 s wkfct1=$j(wkfct1,"",12)+0
 i wkfct1>wkfct2 s wkfct2=wkfct1
 s comb(ord)=wkfct1_"~"_wkfctb2_"~"_nodes1_"~"_inos_"~"_wkfcts_"~"_nodess
 q
 ;
idx ; select best index (output: ino, dep, sat, nodes, wkfct)
 n use,idx,nds,inop
 s ino="",maxdep=0,maxsat=0
idx1 s ino=$o(indxa("e",alias,ino)) i ino="" g idxx
 i $d(cuse(alias,ino)) g idx1
 i optim,$d(duse(alias,ino)) g idx1
 k got("a",alias)
 s ano=0,nodes=0,rstrto=-1,rstrn=0
idx2 s ano=ano+1 i '$d(indxa("e",alias,ino,ano)) g idx2x
 s r=indxa("e",alias,ino,ano)
 s cname=$p(r,"~",1),nnodes=$p(r,"~",6),sqvar=alias_"."_cname
 d idx3
 s got("a",alias,cname)=""
 i '$d(use(ino,sqvar)) s:rstrto=-1 rstrto=ano-1 s nodes=nodes+nnodes
 i $d(use(ino,sqvar)) s rstrn=rstrn+1
 g idx2
idx2x ; index processed
 s ano=ano-1
 s dep=rstrto/ano,sat=rstrn/ano
 i dep>maxdep s maxdep=dep
 i sat>maxsat s maxsat=sat
 s idx(ino)=dep_"~"_sat_"~"_(nodes+0)
 g idx1
idxx s ino="" f  s ino=$o(idx(ino)) q:ino=""  s r=idx(ino),dep=$p(r,"~",1),sat=$p(r,"~",2) i dep<maxdep,sat<maxsat k idx(ino)
 s ino="" f  s ino=$o(idx(ino)) q:ino=""  s nodes=$p(idx(ino),"~",3),nds(nodes,ino)=""
 s inop=$$pkey^%mgsqld(dbid,tname)
 s nodes=$o(nds("")) i $l(nodes) d
 . i $d(nds(nodes,inop)) s ino=inop q
 . s ino=$o(nds(nodes,""))
 . q
 i ino="" s ino=inop
 i nodes="" s nodes=0
 s (dep,sat)=0
 i $d(idx(ino)) s r=idx(ino),dep=$p(r,"~",1),sat=$p(r,"~",2)
 s wkfct=(dep+sat)/2
 i optim q
 s sqvar="" f  s sqvar=$o(use(ino,sqvar)) q:sqvar=""  s orn="" f  s orn=$o(use(ino,sqvar,orn)) q:orn=""  s andn="" f  s andn=$o(use(ino,sqvar,orn,andn)) q:andn=""  d idx4
 q
 ;
idx3 ; find/join to a restriction
 n jn
 s jn="",ok=0 f  s jn=$o(jnx(jn)) q:jn=""!ok  i $d(jnx(jn,sqvar)) s sqvar1="" f  s sqvar1=$o(jnx(jn,sqvar1)) q:sqvar1=""  i sqvar1'=sqvar d gotat i ok q
 i ok s use(ino,sqvar,1,1,"op")="=",use(ino,sqvar,1,1,"cnst")=%z("dsv")_sqvar1_%z("dsv") g idx3x
 s orbrn=""
idx31 i $d(use(sqvar)) g idx3x
 s orbrn=$o(rstr(orbrn)) i orbrn="" g idx3x
 s orn=""
idx32 s orn=$o(rstr(orbrn,sqvar,orn)) i orn="" g idx31
 s andn=""
idx33 s andn=$o(rstr(orbrn,sqvar,orn,andn)) i andn="" g idx32
 s ok=1,sqvar1="" f  s sqvar1=$o(rstr(orbrn,sqvar,orn,andn,"dep",sqvar1)) q:sqvar1=""  d gotat i 'ok q
 i 'ok,orbrn'=0 k use(sqvar) g idx31
 i 'ok g idx33
 s use(ino,sqvar,orn,andn,"op")=rstr(orbrn,sqvar,orn,andn,"op")
 s use(ino,sqvar,orn,andn,"cnst")=rstr(orbrn,sqvar,orn,andn,"cnst")
 g idx33
idx3x ;
 q
 ;
idx4 ; file restriction for compiler to use
 s (^mgtmp($j,"pre",qnum,%z("dsv")_sqvar_%z("dsv"),orn,andn,"op"),rec(%z("dsv")_sqvar_%z("dsv")))=use(ino,sqvar,orn,andn,"op")
 s ^mgtmp($j,"pre",qnum,%z("dsv")_sqvar_%z("dsv"),orn,andn,"cnst")=use(ino,sqvar,orn,andn,"cnst")
 q
 ;
gotat ; determine whether sqvar1 is available at this point
 n alias,cname
 s ok=0,alias=$p(sqvar1,".",1),cname=$p(sqvar1,".",2)
 i '$l(alias),'$l(cname) q
 s ok=0 i $d(got("a",alias,cname)) s ok=1 q
 q
 ;
ord ; get next running order
 n i,j,x,y,ok
 s ordn=ordn+1 i ordn=1 g ord1
 s ok=0 f i=ordm:-1:1 d ord2 i ok s $p(ord,"#",i)=x q
 i 'ok s ord="" q
 f j=1:1:i s y($p(ord,"#",j))=""
 f i=i+1:1:ordm f j=1:1 i '$d(y(j)) s $p(ord,"#",i)=j,y(j)="" q
 q
ord1 ; first pass
 f i=1:1:ordm s $p(ord,"#",i)=i
 q
 ;
ord2 ; get next allowed number in series
 n j,y
 f j=1:1:i-1 s y($p(ord,"#",j))=""
 s x=$p(ord,"#",i),ok=0 f j=x+1:1 s:'$d(y(j)) x=j,ok=1 i ok q
 i x>ordm s ok=0
 q
 ;
comp ; interface to compiler
 s optim=0
 k ^mgtmp($j,"from",qnum),^mgtmp($j,"from","x",qnum)
 f ordn=1:1:nofid d comp1
 d comb2
 q
 ;
comp1 ; disallow all indices except chosen one
 n i,r,ino,ino1,alias,tname,nrun,agg,cname
 s nrun=$p(ord,"#",ordn),ino=$p(inos,"#",ordn)
 s alias=ent(nrun),tname=$p(alias,"~",1),alias=$p(alias,"~",2)
 k cuse(alias,ino)
 s ino1="" f  s ino1=$o(indxa("e",alias,ino1)) q:ino1=""  i ino1'=ino s cuse(alias,ino1)=""
 s ^mgtmp($j,"from",qnum,ordn)=tname_"~"_alias,(^mgtmp($j,"from","x",qnum,tname),^mgtmp($j,"from","x",qnum,alias))=ordn,^mgtmp($j,"from","i",0,alias)=ino
 q
 ;
 

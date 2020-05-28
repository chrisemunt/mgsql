%mgsqld ;(CM) data model access points ; 14 aug 2002  4:08 pm
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
a d vers^%mgsql("%mgsqld") q
 ;
dbid(dbid) ; schema list
 k dbid
 s dbid="" f  s dbid=$$nxtdbid(dbid) q:dbid=""  s dbid(dbid)=""
 q 1
 ;
nxtdbid(dbid) ; next schema
 n dbid1
 s dbid1=$o(^mgsqld(0,dbid))
 q dbid1
 ;
nxttname(dbid,tname) ; next table
 s tname=$o(^mgsqld(0,dbid,"t",tname))
 q tname
 ;
col(dbid,tname,cname) ; column details
 n %d,type,mtype,ano,sm
 s %d=$g(^mgsqld(0,dbid,"t",tname,"tc",cname))
 s type=$p(%d,"\",2)
 s mtype="num" i type["varchar" s mtype="str"
 s $p(%d,"\",11)=mtype
 q %d
 ;
dtype(dbid,tname,cname)
 n %d,type
 i dbid=""!(tname="")!(cname="") q ""
 s %d=$g(^mgsqld(0,dbid,"t",tname,"tc",cname))
 s type=$p(%d,"\",2)
 q type
 ;
tab(dbid,tname) ; table details
 n %d
 s %d=$g(^mgsqld(0,dbid,"t",tname,"t")) i %d="" q %d
 q %d
 ;
pkey(dbid,tname) ; primary key name
 n %d,%pkey
 s %d=$g(^mgsqld(0,dbid,"t",tname,"t"))
 s %pkey=$p(%d,"\",2)
 q %pkey
 ;
ind(dbid,tname,%ind) ; entity indices
 k %ind
 s ino="" f  s ino=$o(^mgsqld(0,dbid,"t",tname,"ti",ino)) q:ino=""  s rc=$$ind1(dbid,tname,ino,.%ind)
 q 1
 ;
ind1(dbid,tname,ino,%ind) ; entity index
 k %ind(ino)
 s %ind(ino)=$$ref(dbid,tname,ino)
 q 1
 ;
ref(dbid,tname,ino) ; entity physical reference for index
 s %ref=$g(^mgsqld(0,dbid,"t",tname,"ti",ino))
 q %ref
 ;
key(dbid,tname,ino,%ind) ; entity index key
 n i
 f i=1:1 q:'$d(^mgsqld(0,dbid,"t",tname,"ti",ino,i))  s %ind(ino,i)=$p(^(i),"\",1)
 q 1
 ;
data(dbid,tname,%data) ; entity data
 n %d,cname
 k %data
 s cname="" f  s cname=$o(^mgsqld(0,dbid,"t",tname,"tc",cname)) q:cname=""  s %d=$$item(dbid,tname,cname) s %data(cname)=%d
 q 1
 ;
item(dbid,tname,cname) ; entity data item
 n %d,sm,cno,nnull
 s %d=$g(^mgsqld(0,dbid,"t",tname,"tc",cname)) i %d="" q %d
 q %d
 ;
seps(dbid,tname,cname) ; trailing keys for separately subscripted items
 n pce,smeth,ssubs
 s %d=$$item(dbid,tname,cname),smeth=$p(%d,"\",3),pce=$p(%d,"\",1)
 s ssubs="" i smeth="s" s ssubs=$g(^mgsqld(0,dbid,"t",tname,"tc",cname,"s"))
 i ssubs="" s ssubs=pce
 q ssubs
 ;
derv(dbid,tname,cname) ; derived columns
 n derv
 s derv=$g(^mgsqld(0,dbid,"t",tname,"tc",cname,"d"))
 q derv
 ;
defk(dbid,tname,cname) ; item defined in entity primary key
 n i,ino
 s %defk=0
 s ino=$$pkey(dbid,tname) i ino="" q
 f i=1:1 q:'$d(^mgsqld(0,dbid,"t",tname,"ti",ino,i))  i $g(^(i))=cname s %defk=1 q
 q %defk
 ;
defd(dbid,tname,cname) ; item defined in entity data
 n %defd
 s %defd=$d(^mgsqld(0,dbid,"t",tname,"tc",cname))
 q %defd
 ;
defkdi(dbid,tname,cname,ino) ; item defined in specific entity index
 n i
 s %def=0
 f i=1:1 q:'$d(^mgsqld(0,dbid,"t",tname,"ti",ino,i))  i $g(^(i))=cname s %def=1 q
 q %def
 ;
indexr(dbid,tname,ino,xsub) ; retrieve index details
 k xsub
 s tname=id
 s rc=$$ind1(dbid,tname,ino,.%ind) s ino=0 f  s ino=$o(%ind(ino)) q:ino=""  s xsub(ino)=%ind(ino) d indexr1
 q 1
 ;
indexr1 ; key + aggregates
 n y,z
 s rc=$$key(dbid,tname,ino,.%ind)
 s (xsub(ino,"k"),com)="" f i=1:1 q:'$d(%ind(ino,i))  s y=%ind(ino,i),xsub(ino,i)=y,xsub(ino,"k")=xsub(ino,"k")_com_y,com=","
 q 1
 
indexw(dbid,tname,ino,%ind)   ; write index details
 n i,%indo
 k ^mgsqld(0,dbid,"t",tname,"ti",ino)
 s ^mgsqld(0,dbid,"t",tname,"ti",ino)=%ind(ino)
 f i=1:1 q:'$d(%ind(ino,i))  s ^mgsqld(0,dbid,"t",tname,"ti",ino,i)=%ind(ino,i)
 q 1
 ;
nxtpname(dbid,pname) ; next proedure
 s pname=$o(^mgsqld(0,dbid,"p",pname))
 q pname
 ;
prc(dbid,pname) ; process details
 n %d
 s %d=$g(^mgsqld(0,dbid,"p",pname,"p")) i %d="" q %d
 q %d
 ;
pdata(dbid,pname,%data) ; process data
 n %d,cname
 k %data
 s cname="" f  s cname=$o(^mgsqld(0,dbid,"p",pname,"pc",cname)) q:cname=""  s %d=$$pitem(dbid,pname,cname) s %data(cname)=%d
 q 1
 ;
pitem(dbid,pname,cname) ; process data item
 n %d,sm,cno,nnull
 s %d=$g(^mgsqld(0,dbid,"p",pname,"pc",cname)) i %d="" q %d
 q %d
 ;
ctable(dbid,tname,cols) ; create table
 n idx,idxx,col,i,ii,in,cname,ano,ano1,atu,pk,glo,dlm,olddata,cno,sm,type,typeu,nnull,cons,consu,subs
 s glo=$g(tname("global")) i $e(glo,1)'="^" s glo="^"_glo
 s dlm=$g(tname("delimiter")) s dlm=$a(dlm)
 i glo="" s glo="^"_tname
 i dlm="" s dlm=35
 s rc=$$data(0,tname,.olddata)
 s rc=$$dtable(dbid,tname)
 f i=1:1 q:'$d(cols(i))  d
 . s cname=$p(cols(i)," ",1),atu=$$lcase^%mgsqls(cname) i atu="constraint" d  q
 . . s pk=$p(cols(i)," ",2),idx=$p($p(cols(i),"(",2),")",1)
 . . s idx(pk)=glo
 . . f ii=1:1:$l(idx,",") s cname=$p(idx,",",ii),idx(pk,ii)=cname,idxx(pk,cname)=ii
 . . q
 . q
 s ano=0
 f i=1:1 q:'$d(cols(i))  d
 . s nnull=0
 . s cname=$p(cols(i)," ",1),atu=$$lcase^%mgsqls(cname) i atu="constraint" q
 . s type=$p(cols(i)," ",2),typeu=$$lcase^%mgsqls(type)
 . f ii=3:1:$l(cols(i)," ") s name=$p(cols(i)," ",ii) d
 . . i name="" q
 . . s name=$$lcase^%mgsqls(name)
 . . i name="not",$$lcase^%mgsqls($p(cols(i)," ",ii+1))="null" s nnull=1
 . . i name="separate" s cols(i,name)="" d  i ($l(subs,"""")#2) s cols(i,name)=$$rstring^%mgsqlp(subs)
 . . . n n,x
 . . . s subs=""
 . . . s x=$p(cols(i)," ",ii+1,999)
 . . . i $e(x)="(" s x=$e(x,2,999) f n=1:1 s subs=$p(x,")",1,n) q:($l(subs,"""")#2)
 . . . i subs'="" q
 . . . f n=1:1 s subs=$p(x," ",1,n) q:($l(subs,"""")#2)
 . . . q
 . . i name="derived" s cols(i,name)=$p(cols(i)," ",ii+1)
 . . q
 . s cons=$p(cols(i)," ",3,999),consu=$$lcase^%mgsqls(cons)
 . s nnull=0 i consu["not null" s nnull=1
 . s ano1=0 i '$d(idxx(pk,cname)) s ano=ano+1,ano1=ano
 . s cno=$p($g(olddata(cname)),"\",5)+0 i 'cno s cno=$$cno()
 . s sm="d" i $d(cols(i,"separate")) s sm="s"
 . s col(cname)=ano1_"\"_typeu_"\"_sm_"\"_nnull_"\"_cno
 . s name="" f  s name=$o(cols(i,name)) q:name=""  s col(cname,name)=cols(i,name)
 . q
 ;b
 s ^mgsqld(0,dbid,"t",tname,"t")=dlm_"\"_pk
 s cname="" f  s cname=$o(col(cname)) q:cname=""  d
 . s ^mgsqld(0,dbid,"t",tname,"tc",cname)=col(cname)
 . s name="" f  s name=$o(col(cname,name)) q:name=""  s ^mgsqld(0,dbid,"t",tname,"tc",cname,$e(name,1))=$$rstring^%mgsqlp(col(cname,name))
 . q
 s in="" f i=1:1 s in=$o(idx(in)) q:in=""  d
 . s ^mgsqld(0,dbid,"t",tname,"ti",in)=idx(in)
 . f i=1:1 q:'$d(idx(in,i))  s ^mgsqld(0,dbid,"t",tname,"ti",in,i)=$$rstring^%mgsqlp(idx(in,i))
 q 1
 ;
dtable(dbid,tname) ; delete table
 k ^mgsqld(0,dbid,"t",tname)
 q 1
 ;
cindex(dbid,tname,ino,cols) ; create index
 n %ind
 s glo=$g(tname("global")) i $e(glo,1)'="^" s glo="^"_glo
 i glo="" s glo="^"_tname_ino
 s %ind(ino)=glo
 f i=1:1 q:'$d(cols(i))  s %ind(ino,i)=$$rstring^%mgsqlp(cols(i))
 s rc=$$indexw^%mgsqld(dbid,tname,ino,.%ind)
 q 1
 ;
cproc(dbid,pname,cols) ; create procedure
 n idx,idxx,col,i,ii,in,cname,ano,ano1,atu,pk,rou,dlm,olddata,cno,sm,type,typeu,nnull,cons,consu
 s rou=$p(pname,"_",2)_"^"_$p(pname,"_",1),dlm=35
 s rc=$$dproc(dbid,pname)
 s ano=0
 f i=1:1 q:'$d(cols(i))  d
 . s cname=$p(cols(i)," ",1),atu=$$lcase^%mgsqls(cname) i atu="constraint" q
 . s type=$p(cols(i)," ",2),typeu=$$lcase^%mgsqls(type)
 . s cons=$p(cols(i)," ",3,999),consu=$$lcase^%mgsqls(cons)
 . s nnull=0 i consu["not null" s nnull=1
 . s ano=ano+1
 . s cno=0
 . s sm="d"
 . s col(cname)=ano_"\"_typeu_"\"_sm_"\"_nnull_"\"_cno
 . q
 s ^mgsqld(0,dbid,"p",pname,"p")=dlm_"\"_rou
 s cname="" f  s cname=$o(col(cname)) q:cname=""  s ^mgsqld(0,dbid,"p",pname,"pc",cname)=col(cname)
 q 1
 ;
dproc(dbid,tname) ; delete table
 k ^mgsqld(0,dbid,"p",pname)
 q 1
 ;
cno() ; next column name number
 l +^mgsqld(0)
 s x=$g(^mgsqld(0))+1,^mgsqld(0)=x
 l -^mgsqld(0)
 q x
 ;
 

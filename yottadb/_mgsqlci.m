%mgsqlci ;(CM) sql compiler - insert ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlci") q
 ;
main ; start
 s %tagz=$s('$d(sql(1,1)):%zq("tagout"),1:%zq("tag",1))
 s (tname,alias)=^mgtmp($j,"upd","insert")
 k dtyp d xfid^%mgsqlct
 f i=1:1 q:'$d(^mgtmp($j,"upd","att",i))  d data
 s %refile=1 d set
 i $d(sql(1,1)) s line=" "_"g"_" "_%zq("tag",1) d addline^%mgsqlc(grp,.line)
 ;
exit ; exit
 k upd,null,key,nkey,nkeyt,okey,okeyt,pkey,pref,idx,apc,cde,z
 q
 ;
data ; determine values for update
 s cname=^mgtmp($j,"upd","att",i)
 d dtyp^%mgsqlct
 s (y,var)=^mgtmp($j,"upd","val",i)
 ;i y?.1"."1a.e s var=%z("dsv")_y_%z("dsv")
 i y?1":"1a.e s var=%z("dev")_y_%z("dev")
 i $d(xfidx(cname)) s (key("o",cname),key("n",cname))=var
 i '$d(xfidx(cname)) s dat("n",cname)=var
 q
 ;
 ;  key("o",cname)=val : must supply
 ;  key("n",cname)=val : supply all/partial/none
 ;  dat("o",cname)=val : optional
 ;  dat("n",cname)=val : optional
 ;  %refile         : flag for forced refiling of all indices
 ;  %tagz           : label for exit
 ;
index ; generate physical index references
 s ino=""
index1 s ino=$o(xfid(ino)) i ino="" q
 s pst="",typo="o",typn="n"
 s (zo,to)="" i %set s (zn,tn,zx,tx)=""
 s (com,ando,andn)="" f kno=1:1 q:'$d(xfid(ino,kno))  d index2 s com=","
 s pkey("o",ino)=zo,subt("o",ino)=to
 i %set s pkey("n",ino)=zn,subt("n",ino)=tn,pkey("x",ino)=zx,subt("x",ino)=tx
 g index1
 ;
index2 ; process single key element
 s zo=zo_com i %set s zn=zn_com,zx=zx_com
 s com1="" f ano=1:1 q:'$d(xfid(ino,kno,ano))  d index3 s com1="_"""_","_"""_"
 q
 ;
index3 ; process a single key attribute
 s cname=xfid(ino,kno,ano)
 i cname'?1a.e s pvar=cname g index4
 i '$d(dtyp(cname)) d dtyp^%mgsqlct
 i $d(xfidx(cname)),$d(key(typo,cname)) s pvar=key(typo,cname) g index4
 i '$d(dat(typo,cname)) s dat(typo,cname)="%d"_pst_"("_dtyp(cname)_")"
 s pvar=dat(typo,cname)
index4 s zo=zo_com1_pvar
 i cname?1a.e,'$d(xfidx(cname)) s to=to_ando_"$l"_"("_pvar_")",ando=","
 i '%set q
 i cname'?1a.e s pvar=cname g index5
 i $d(xfidx(cname)) s:'$d(key(typn,cname)) key(typn,cname)=key(typo,cname) s pvar=key(typn,cname) g index5
 i '$d(dat(typn,cname)) s dat(typn,cname)=dat(typo,cname)
 s pvar=dat(typn,cname)
index5 s xvar=$s(cname?1a.e&'$d(xfidx(cname)):"%dx"_pst_"("_dtyp(cname)_")",1:pvar)
 s zn=zn_com1_pvar,zx=zx_com1_xvar
 i cname?1a.e,'$d(xfidx(cname)) s tn=tn_andn_"$l"_"("_pvar_")",tx=tx_andn_"$l"_"("_xvar_")",andn=","
 q
 ;
elim ; eliminate indices not affected by update
 s ino=$$pkey^%mgsqld(dbid,tname) f  s ino=$o(pkey("n",ino)) q:ino=""  i pkey("n",ino)=pkey("o",ino) k pkey("n",ino),pkey("o",ino)
 s cname="" f  s cname=$o(dat("n",cname)) q:cname=""  i $d(dat("o",cname)),dat("n",cname)=dat("o",cname) k dat("n",cname),dat("o",cname)
 q
 ;
getold ; get old data
 n agg,or,getno
 k out
 k ^mgtmp($j,"got")
 s get="y" ;$p(^%mguser("sys"),"~",10)
 s line="",or="",cname="" f  s cname=$o(key("o",cname)) q:cname=""  i cname?1a.e s or(key("o",cname))="",line=line_or_"'"_"$l"_"("_key("o",cname)_")",or="!"
 i %set s cname="" f  s cname=$o(key("n",cname)) q:cname=""  i cname?1a.e,'$d(or(key("n",cname))) s line=line_or_"'"_"$l"_"("_key("n",cname)_")",or="!"
 i $l(line) s line=" "_"i"_" "_line_" "_"g"_" "_%tagz d addline^%mgsqlc(grp,.line)
 d getold2
 s getno=0
 s inop=$$pkey^%mgsqld(dbid,tname),ino="" f  s ino=$o(pkey("o",ino)) q:ino=""  i ino'=inop d getold0
 q
 ;
getold0 ; get all attibutes involved in indices
 f i=1:1 q:'$d(xfid(ino,i))  f ii=1:1 q:'$d(xfid(ino,i,ii))  s cname=xfid(ino,i,ii) i cname?1a.e d getold1
 ;f i=1:1 q:'$d(xfid(ino,"a",i))  s cname=$p(xfid(ino,"a",i),"~",2) i cname?1a.e d getold1
 q
 ;
getold1 ; get all old attribute values
 n i,ii
 i $d(xfidx(cname))!$d(^mgtmp($j,"got",cname)) q
 s ^mgtmp($j,"got",cname)=""
 i '$d(dtyp(cname)) d dtyp^%mgsqlct
 s pvar="%d("_dtyp(cname)_")"
 i '$d(dtyp(cname,"e")) q
 s r=dtyp(cname,"e"),smeth=$p(r,"\",3),pce=$p(r,"\",1)
 s out(pce,pvar)=""
 s ino=$$pkey^%mgsqld(dbid,tname)
 i smeth="d" s line=" "_"s"_" "_pvar_"="_"$p"_"(%d,"_dlm_","_pce_")"
 i smeth="s" s line=" "_"s"_" "_pvar_"="_"$g"_"("_xfid(ino)_"("_pkey("o",ino)_","_$$seps^%mgsqld(dbid,tname,cname)_"))"
 d addline^%mgsqlc(grp,.line)
 q
 ;
getold2 ; get old data record
 s ino=$$pkey^%mgsqld(dbid,tname)
 i get="n" s line=" "_"s"_" %def="_"$d"_"("_xfid(ino)_"("_pkey("o",ino)_"))" d addline^%mgsqlc(grp,.line) s line=" "_"s"_" %d="""" "_"i"_" %def#10 "_"s"_" %d="_xfid(ino)_"("_pkey("o",ino)_")" d addline^%mgsqlc(grp,.line)
 i get="y" s line=" "_"s"_" %d="_"$g"_"("_xfid(ino)_"("_pkey("o",ino)_"))" d addline^%mgsqlc(grp,.line)
 q
 ;
killold ; kill old data record for index
 i '$d(pkey("o",ino)) q
 s subt="" i $l(subt("o",ino)) s subt=subt("o",ino)
 s glo=xfid(ino),key=pkey("o",ino)
 d k(grp,subt,glo,key)
 i '%set q
 i '%upd!(ino=$$pkey^%mgsqld(dbid,tname)) q
 s subt="" i $l(subt("x",ino)) s subt=subt("x",ino)
 s glo=xfid(ino),key=pkey("x",ino)
 d k(grp,subt,glo,key)
 q
 ;
getnew ; get indexed data associated with new keys
 n inop
 k ^mgtmp($j,"got")
 s inop=$$pkey^%mgsqld(dbid,tname)
 s subt="",dat="%dx",glo=xfid(inop),key=pkey("n",inop),zgloz="",fail="" d g(grp,subt,dat,glo,key,zgloz)
 f  s ino=$o(pkey("o",ino)) q:ino=""  i ino'=inop f i=1:1 q:'$d(xfid(ino,i))  f ii=1:1 q:'$d(xfid(ino,i,ii))  s cname=xfid(ino,i,ii) i cname?1a.e d getnew1
 q
 ;
getnew1 ; get individual data item
 n i,ii,inop
 s inop=$$pkey^%mgsqld(dbid,tname)
 i $d(xfidx(cname))!$d(^mgtmp($j,"got",cname)) q
 s ^mgtmp($j,"got",cname)=""
 i '$d(dtyp(cname)) d dtyp^%mgsqlct
 s pvar="%dx("_dtyp(cname)_")"
 i '$d(dtyp(cname,"e")) q
 s r=dtyp(cname,"e"),smeth=$p(r,"\",3),pce=$p(r,"\",1)
 i smeth="d" s line=" "_"s"_" "_pvar_"="_"$p"_"(%dx,"_dlm_","_pce_")"
 i smeth="s" s line=" "_"s"_" "_pvar_"="_"$g"_"("_xfid(inop)_"("_pkey("n",inop)_","_$$seps^%mgsqld(dbid,tname,cname)_"))"
 d addline^%mgsqlc(grp,.line)
 q
 ;
setnew ; set new record for data/index
 n setdstr
 s setdstr=1
 i '$d(pkey("n",ino)) q
 i inop=$$pkey^%mgsqld(dbid,tname)
 i ino=inop s setdstr=0,cname="" f  s cname=$o(dat("n",cname)) q:cname=""  d setnew1
 i ino=inop,%upd k out d setnew2
 s subt="" i $l(subt("o",ino)) s subt=subt("n",ino)
 s glo=xfid(ino),key=pkey("n",ino),dat=$s(ino=$$pkey^%mgsqld(dbid,tname):"%d",1:"""""")
 i setdstr d s(grp,subt,dat,glo,key)
 q
 ;
setnew1 ; set all new attribute values
 i '$d(dtyp(cname)) d dtyp^%mgsqlct
 s var=dat("n",cname)
 i '$d(dtyp(cname,"e")) q
 s r=dtyp(cname,"e"),smeth=$p(r,"\",3),pce=$p(r,"\",1)
 i $l(var)<250,$d(out(pce,var)) q
 i smeth="d" s line=" "_"s"_" $p(%d,"_dlm_","_pce_")="_var,setdstr=1
 i smeth="s" s line=" "_"s"_" "_xfid(ino)_"("_pkey("n",ino)_","_$$seps^%mgsqld(dbid,tname,cname)_")="_var
 d addline^%mgsqlc(grp,.line)
 q
 ;
setnew2 ; for cases where primary key has potentially changed
 s cname="",com="" f  s cname=$o(key("o",cname)) q:cname=""  s line=line_com_key("n",cname)_"="_key("o",cname),com=","
 i $l(line) s line=" "_"i"_" "_line_" "_"g"_" "_%tagz d addline^%mgsqlc(grp,.line)
 s line=" k %xx" d addline^%mgsqlc(grp,.line)
 s subt="",glo=xfid(inop),key=pkey("o",inop),dvar="%xx" d gm(grp,subt,dvar,glo,key)
 s subt="",glo=xfid(inop),key=pkey("n",inop),dat="%xx" d m(grp,subt,dat,glo,key)
 s line=" k %xx" d addline^%mgsqlc(grp,.line)
 s subt="",glo=xfid(inop),key=pkey("o",inop) d k(grp,subt,glo,key)
 q
 ;
set ; set a file reference
 s %set=1,^mgtmp($j,"sqlupd",tname)="~1"
 d index
 s ino=$$pkey^%mgsqld(dbid,tname)
 s %upd=($g(pkey("o",ino))'=$g(pkey("n",ino)))
 i '%upd,'%refile d elim
sete ; set new
 d getold
 i %upd d getnew
 s inop=$$pkey^%mgsqld(dbid,tname)
 s ino=inop d setnew
 s ino="" f  s ino=$o(pkey("n",ino)) q:ino=""  i ino'=inop d killold,setnew
 k %data,data,pkey,subt,zn,zo,tn,to,andn,ando,com,com1,out,ltst
 q
 ;
kill ; kill an entity reference
 s %set=0,^mgtmp($j,"sqlupd",tname)="~1"
 d index
kille ; exit
 d getold
 s ino="" f  s ino=$o(pkey("o",ino)) q:ino=""  d killold
 k %data,data,pkey,subt,zn,zo,tn,to,andn,ando,com,com1,out,ltst
 q
 ;
g(grp,test,dvar,glo,key,default) ; get command
 n line
 s line=$s($l(test):" i "_test,1:"")_" "_"s"_" "_dvar_"="_"$g"_"("_glo_"("_key_")"_default_")" d addline^%mgsqlc(grp,.line)
 q
 ;
gm(grp,test,dvar,glo,key) ; get via merge command
 n line
 s line=$s($l(test):" i "_test,1:"")_" "_"m"_" "_dvar_"="_glo_"("_key_")" d addline^%mgsqlc(grp,.line)
 q
 ;
gd(grp,test,dvar,glo,key,default,fail) ; get command with failed definition rejection
 s line=" "_"s"_" "_%z("vdef")_"="_"$d"_"("_glo_"("_key_")"_default_")" s:$l(fail) line=line_" "_"i"_" '"_%z("vdef")_fail d addline^%mgsqlc(grp,.line)
 s line=" "_"s"_" "_dvar_"="""" "_"i"_" "_%z("vdef")_"#10 "_"s"_" "_dvar_"="_glo_"("_key_")"_default d addline^%mgsqlc(grp,.line)
 q
 ;
s(grp,test,dvar,glo,key) ; set command
 s line=$s($l(test):" "_"i"_" "_test,1:"")_" "_"s"_" "_glo_"("_key_")="_dvar d addline^%mgsqlc(grp,.line)
 q
 ;
m(grp,test,dvar,glo,key) ; merge command
 s line=$s($l(test):" "_"i"_" "_test,1:"")_" "_"m"_" "_glo_"("_key_")="_dvar d addline^%mgsqlc(grp,.line)
 q
 ;
k(grp,test,glo,key) ; kill command
 s line=$s($l(test):" "_"i"_" "_test,1:"")_" "_"k"_" "_glo_"("_key_")" d addline^%mgsqlc(grp,.line)
 q
 ;
dbg ; set up referential actions audit trail
 n arg,args,i
 s line=""
 i '$d(^mgtmp($j,"ra-audit")) q
 s line=^("ra-audit")
 s line=line_",%k(0)="""_glo_""""
 s arg=key s args=$$arg^%mgsqle(arg,.args)
 f i=1:1:args s line=line_",%k("_i_")="_args(i)
 q
 ;
 

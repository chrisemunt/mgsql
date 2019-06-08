%mgsqlci ;(CM) sql compiler - insert ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlci") q
 ;
main ; start
 s %tagz=$s('$d(sql(1,1)):tagout,1:tag(1)),%tagi=%z("pt")_"i" ;,%tdlm=%z("dl")
 s (tname,alias)=update("insert")
 k dtyp d xfid^%mgsqlct
 f i=1:1 q:'$d(update("att",i))  d data
 s %refile=1 d set
 i $d(sql(1,1)) s line=" "_"g"_" "_tag(1) d addline^%mgsqlc(grp,.line)
 ;
exit ; exit
 k upd,null,key,nkey,nkeyt,okey,okeyt,pkey,pref,idx,apc,cde,z
 q
 ;
data ; determine values for update
 s cname=update("att",i)
 d dtyp^%mgsqlct
 s (y,var)=update("val",i)
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
 ;  %tagi           : reserved label prefix for indices etc
 ;  %tdlm           : reserved label delimiter
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
 i $d(xfidx(cname)) s pvar=key(typo,cname) g index4
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
char ; get file characteristics
 s %retr=1,%onel=0 q
 i %upd q
 s sc=$$data^%mgsqld(dbid,tname,.%data)
 s %sep=0,%all=1 s cname="" f  s cname=$o(%data(cname)) q:cname=""  s %d=%data(cname) s:'$d(dat("n",cname)) %all=0 s ano=ano+1,data($p(%d,"\",2))=cname i $p(%d,"\",1)="s" s %sep=1
 i '$l($o(xfid(0))),%all,'%sep s %retr=0
 i ano<10,%all,'%sep s %onel=1
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
 s r=dtyp(cname,"e"),typ=$p(r,"~",1),pce=$p(r,"~",2)
 s out(pce,pvar)=""
 s ino=$$pkey^%mgsqld(dbid,tname)
 i typ="d" s line=" "_"s"_" "_pvar_"="_"$p"_"(%d,"_dlm_","_pce_")"
 i typ'="d" s line=" "_"s"_" "_pvar_"="""" "_"i"_" "_"$d"_"("_xfid(ino)_"("_pkey("o",ino)_","_pce_")) "_"s"_" "_pvar_"="_$s(xfid(ino)="^":"^("_pce_")",1:xfid(ino)_"("_pkey("o",ino)_","_pce_")")
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
 i $d(xfid(ino,"t")) q
 s subt="" i $l(subt("o",ino)) s subt=subt("o",ino)
 s glo=xfid(ino),key=pkey("o",ino)
 i '$d(xfid(ino,"t")) d k
 i $d(xfid(ino,"t")) s dat="""""" d s
 i '%set q
 i '%upd!(ino=$$pkey^%mgsqld(dbid,tname)) q
 s subt="" i $l(subt("x",ino)) s subt=subt("x",ino)
 s glo=xfid(ino),key=pkey("x",ino)
 i '$d(xfid(ino,"t")) d k
 i $d(xfid(ino,"t")) s dat="""""" d s
 q
 ;
getnew ; get indexed data associated with new keys
 k ^mgtmp($j,"got")
 s subt="",dat="%dx",glo=xfid(0),key=pkey("n",0),zgloz="",fail="" d g
 s ino=$$pkey^%mgsqld(dbid,tname) f  s ino=$o(pkey("o",ino)) q:ino=""  f i=1:1 q:'$d(xfid(ino,i))  f ii=1:1 q:'$d(xfid(ino,i,ii))  s cname=xfid(ino,i,ii) i cname?1a.e d getnew1
 q
 ;
getnew1 ; get individual data item
 n i,ii
 i $d(xfidx(cname))!$d(^mgtmp($j,"got",cname)) q
 s ^mgtmp($j,"got",cname)=""
 i '$d(dtyp(cname)) d dtyp^%mgsqlct
 s pvar="%dx("_dtyp(cname)_")"
 i '$d(dtyp(cname,"e")) q
 s r=dtyp(cname,"e"),typ=$p(r,"~",1),pce=$p(r,"~",2)
 i typ="d" s line=" "_"s"_" "_pvar_"="_"$p"_"(%dx,"_dlm_","_pce_")"
 i typ'="d" s line=" "_"s"_" "_pvar_"="""" "_"i"_" "_"$d"_"("_xfid(0)_"("_pkey("n",0)_","_pce_")) "_"s"_" "_pvar_"="_$s(xfid(0)="^":"^("_pce_")",1:xfid(0)_"("_pkey("n",0)_","_pce_")")
 d addline^%mgsqlc(grp,.line)
 q
 ;
setnew ; set new record for data/index
 i '$d(pkey("n",ino)) q
 i $d(xfid(ino,"t")) q
 i inop=$$pkey^%mgsqld(dbid,tname)
 i ino=inop,%onel d setnew3 q
 i ino=inop s cname="" f  s cname=$o(dat("n",cname)) q:cname=""  d setnew1
 i ino=inop,%upd k out d setnew2
 s subt="" i $l(subt("o",ino)) s subt=subt("n",ino)
 s glo=xfid(ino),key=pkey("n",ino),dat=$s(ino=$$pkey^%mgsqld(dbid,tname):"%d",1:"""""")
 d s
 q
 ;
setnew1 ; set all new attribute values
 i '$d(dtyp(cname)) d dtyp^%mgsqlct
 s var=dat("n",cname)
 i '$d(dtyp(cname,"e")) q
 s r=dtyp(cname,"e"),typ=$p(r,"~",1),pce=$p(r,"~",2),smeth="d"
 i $l(var)<250,$d(out(pce,var)) q
 i smeth="d" s line=" "_"s"_" $p(%d,"_dlm_","_pce_")="_var
 i smeth="s" s line=" "_"s"_" "_xfid(0)_"("_pkey("n",0)_","_pce_")="_var
 d addline^%mgsqlc(grp,.line)
 q
 ;
setnew2 ; for cases where primary key has potentially changed
 s cname="",com="" f  s cname=$o(key("o",cname)) q:cname=""  s line=line_com_key("n",cname)_"="_key("o",cname),com=","
 i $l(line) s line=" "_"i"_" "_line_" "_"g"_" "_%tdlm_%tagi_%tdlm d addline^%mgsqlc(grp,.line)
 s line=" "_"s"_" %s=""""" d addline^%mgsqlc(grp,.line)
 s line=%tdlm_%tagi_1_%tdlm_" "_"s"_" %s=$o("_xfid(0)_"("_pkey("o",0)_",%s)) "_"i"_" %s="""" "_"g"_" "_%tdlm_%tagi_2_%tdlm d addline^%mgsqlc(grp,.line)
 s line=" "_"s"_" %xx="_xfid(0)_"("_pkey("o",0)_",%s)" d addline^%mgsqlc(grp,.line)
 s subt="",glo=xfid(0),key=pkey("o",0)_",%s" d k
 s subt="",glo=xfid(0),key=pkey("n",0)_",%s",dat="%xx" d s
 s line=" "_"g"_" "_%tdlm_%tagi_1_%tdlm d addline^%mgsqlc(grp,.line)
 s line=%tdlm_%tagi_2_%tdlm_" ;" d addline^%mgsqlc(grp,.line)
 d killold
 s line=%tdlm_%tagi_%tdlm_" ;" d addline^%mgsqlc(grp,.line)
 q
 ;
setnew3 ; cram entire update into one line
 s (line,com)="" f  s cname=$o(key("o",cname)) q:cname=""  i cname?1a.e s line=line_com_"$l"_"("_key("o",cname)_")",com=","
 i $l(line) s line=" "_"i"_" "_line
 s line=line_" "_"s"_" "_xfid(0)_"("_pkey("n",0)_")="
 i '$d(dat("n")) s line=line_"""""" d addline^%mgsqlc(grp,.line)
 s com="" f i=1:1 q:'$d(data(i))  s cname=data(i),line=line_com_$s($d(dat("n",cname)):dat("n",cname),1:""""""),com="_"_dlm_"_"
 d addline^%mgsqlc(grp,.line)
 q
 ;
set ; set a file reference
 s %set=1,^mgtmp($j,"sqlupd",tname)="~1"
 d index
 s ino=$$pkey^%mgsqld(dbid,tname)
 s %upd=($g(pkey("o",ino))'=$g(pkey("n",ino)))
 i '%upd,'%refile d elim
 d char
sete ; set new
 i %retr d getold
 i %upd d getnew
 s inop=$$pkey^%mgsqld(dbid,tname)
 s ino=inop d setnew
 f  s ino=$o(pkey("n",ino)) q:ino=""  i ino'=inop d killold,setnew
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
g ; get command
 s line=$s($l(subt):" i "_subt,1:"")_" "_"s"_" "_dat_"="_"$g"_"("_glo_"("_key_")"_zgloz_")" d addline^%mgsqlc(grp,.line)
 q
 ;
gd ; get command with failed definition rejection
 s line=" "_"s"_" "_%z("vdef")_"="_"$d"_"("_glo_"("_key_")"_zgloz_")" s:$l(fail) line=line_" "_"i"_" '"_%z("vdef")_fail d addline^%mgsqlc(grp,.line)
 s line=" "_"s"_" "_dat_"="""" "_"i"_" "_%z("vdef")_"#10 "_"s"_" "_dat_"="_glo_"("_key_")"_zgloz d addline^%mgsqlc(grp,.line)
 q
 ;
s ; set command
 s line=$s($l(subt):" "_"i"_" "_subt,1:"")_" "_"s"_" "_glo_"("_key_")="_dat d addline^%mgsqlc(grp,.line)
 q
 ;
k ; kill command
 s line=$s($l(subt):" "_"i"_" "_subt,1:"")_" "_"k"_" "_glo_"("_key_")" d addline^%mgsqlc(grp,.line)
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
 

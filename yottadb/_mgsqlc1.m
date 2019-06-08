%mgsqlc1 ; was 2 (CM) sql compiler - parse files ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlc1") q
 ;
subq ; compile sub-query data extraction
 k got
 d getf^%mgsqlct i $l(error) q
 d temps
 s nxtun="" i $d(sql("union",qnum)) s nxtun=$o(sql("union",qnum))
 f tnum=1:1 q:'$d(^mgtmp($j,"from",qnum,tnum))  s tname=$p(^mgtmp($j,"from",qnum,tnum),"~",1),alias=$p(^mgtmp($j,"from",qnum,tnum),"~",2) d pass,data^%mgsqlc5 s got("f",alias)="" d corel^%mgsqlc5,kill
 d output^%mgsqlc2
exit ; exit
 q
 ;
dist() ; optimize select distinct
 n done,x,got,ii
 s done=0
 i $g(^mgtmp($j,"sel",qnum))'="distinct" q done
 i $d(^mgtmp($j,"from",qnum,2)) q done
 f ii=1:1:i s x=$p(z,",",i) i x'="" s got(x)=""
 s done=1 f ii=1:1 q:'$d(^mgtmp($j,"sel",qnum,ii))  s x=$g(^(ii)) i x'="",'$d(got(x)) s done=0 q
 i done s ^mgtmp($j,"dontgetdata",qnum,tnum)=1
 q done
 ;
pass ; pass file
 s keyd=","
 s tag=%z("dl")_%z("pt")_qnum_tnum,tags=%z("dl")_%z("pt")_qnum_"s"_%z("dl")
 ; cmtaaa
 ;i $d(^mgtmp($j,"from","z",qnum)) d
 ;. s ^mgtmp($j,"from","z",qnum,"def",tnum)=%z("dsv")_"\#jndef\"_qnum_"\"_tnum_%z("dsv")
 ;. s line=" "_"s"_" "_^mgtmp($j,"from","z",qnum,"def",tnum)_"=0" d addline^%mgsqlc(grp,.line)
 ;. q
 ;
 i tnum=1 k ctag d
 . s line=tags_" ;"
 . s ^mgtmp($j,"s",qnum)=grp_"~"_$s($d(grpm(grp)):grpm(grp),1:1)
 . d addline^%mgsqlc(grp,.line)
 . i $d(^mgtmp($j,"v",qnum)) s line=" s "_%z("dsv")_$g(^(qnum))_"."_"line-no"_%z("dsv")_"=0" d addline^%mgsqlc(grp,.line)
 . d prefun^%mgsqlc6
 . q
 s z=^mgtmp($j,"key",qnum,tnum),zglo=glb(qnum,tnum),zgloz=$s(zglo[%z("dev"):""")",1:"")
 ;;i $d(seq(alias)) d sqseq^%mgsqlc4 i $d(seq(alias,"zcode","pre")) f i=1:1 q:'$d(seq(alias,"zcode","pre",i))  s line=seq(alias,"zcode","pre",i) d addline^%mgsqlc(grp,.line) s seq(alias,"il")=grp_"~"_(grpm(grp)-1)
 d order^%mgsqlc2
 i tnum=1 d endsq s tagx=$s($d(endsq(qnum))&'$d(sql("union",qnum)):%z("dl")_%z("pt")_qnum_"x"_%z("dl"),$l(nxtun):%z("dl")_%z("pt")_nxtun_"s"_%z("dl"),$d(sql("union",1))&($d(gvar(1))!$d(ord)):%z("dl")_%z("pt")_1_"x"_%z("dl"),1:tagout)
 k got("a") f i=1:1:$l(z,keyd) s y=$p(z,keyd,i) i y[%z("dsv") s dir="$o" s:$d(dir(y)) dir=dir(y) d pre^%mgsqlc4 s y=$p($p(z,keyd,i),%z("dsv"),2) i $l(y) s got("a",y)=""
 i qnum=1,tnum=1,$g(^mgtmp($j,"sel",qnum))="distinct" d dist^%mgsqlc2
 s key="",com="",ptagn="",tagn=1 i tnum=1,'$d(tag(qnum)) s tag(qnum)=tagx
 i $d(^mgtmp($j,"from","z",qnum,"pass",alias)) d oj
 s tagxx=tag(qnum)
 k ctag,got("a") f i=1:1:$l(z,keyd) s y=$p(z,keyd,i) d pass1,gota s:$d(ctag) tag(qnum)=ctag i $$dist() q
 i '$d(ctag) s ctag=tagx
 i ctag'=tagx s tag(qnum)=ctag
pass4 ; set start pointer for sequence
 g passx
 ;i '$d(seq(alias,"il")) g passx
 ;n r,grp,grpm,line,x,or
 ;s (x,or)="" f i=1:1:$l(z,keyd) s y=$p(z,keyd,i) i y[%z("dsv") i $d(nopas(y)),'$d(pre(y,"pre",2)) s x=x_or_"'$l("_y_")",or="!"
 ;i $l(x) s x=" "_"g"_":"_x_" "_tagxx
 ;s r=seq(alias,"il"),grp=$p(r,"~",1),grpm(grp)=$p(r,"~",2),line=@(code_",grp,grpm(grp))")_x_" g "_$s(seq(alias,"ivt")[%z("dsv"):tag(qnum),1:seq(alias,"ivt"))
 ;d addline^%mgsqlc(grp,.line)
passx ; clean-up
 k pre,nopas
 q
 ;
pass1 ; set up line(s) of code for this level of subscript
 s key=key_com_y,com=keyd
 i y'[%z("dsv") q
 s dir=$s($d(dir(y)):dir(y),1:"$o") d dir
 s ptag=tag(qnum)
 i $d(sqin(y)),$d(pre(y,"pre","nostrt")),'$d(corel(qnum)) g pass3
 i $d(nopas(y)),'$d(pre(y,"pre",2)) d nopas q
 i $d(seq(alias,"x",y,"pre")) g passeq
 ;
 ; i $d(pre(y,"pre",2)) d passor g pass2 q
 i $d(pre(y,"pre",2)),'$d(seq(alias)) d passor g pass2 q
 ;
 i $d(pre(y,"pre",2)),$d(seq(alias)) d
 . k pre(y,"pre"),nopas(y)
 . s pre(y,"pre",1)=" "_"s"_" "_y_"="""""
 . s pre(y)=1
 . q
 ;
 s line=pre(y,"pre",1) d addline^%mgsqlc(grp,.line)
passeq s ctag=tag_tagn_%z("dl")
 s (reset,comr)="" i qnum=1,unique(qnum),ptag=tagout d reset i $l(reset) s reset=" s "_reset
 s line=ctag_" "_"s"_" "_y_"="_dirf_"("_zglo_"("_key_")"_zgloz_dirp_") "_"i"_" "_y_"="_$c(34)_$c(34)_reset_" "_"g"_" "_ptag d addline^%mgsqlc(grp,.line)
 i $d(seq(alias,"ivt")),seq(alias,"ivt")=y s seq(alias,"ivt")=ctag
 i $d(pre(y,"post",1)) s line=pre(y,"post",1)_" "_"g"_" "_ptag d addline^%mgsqlc(grp,.line)
 i $d(seq(alias,"x",y,"post")) s line=seq(alias,"x",y,"post") i $l(line) s line=line_" "_"g"_" "_tagxx d addline^%mgsqlc(grp,.line)
pass2 s ptagn=tagn,tagn=tagn+1
 q
 ;
pass3 ; generate optimal code for 'in' clause
 s ctag=tag_tagn_%z("dl")
 s line=pre(y,"pre",1) d addline^%mgsqlc(grp,.line)
 s line=ctag_" "_"s"_" "_y_"="_dirf_"("_%z("ctg")_"("_%z("cts")_","_sqin(y)_","_y_")"_dirp_") "_"i"_" "_y_"="""""_" "_"g"_" "_ptag d addline^%mgsqlc(grp,.line)
 s line=" "_"i"_" '"_"$d"_"("_zglo_"("_key_")"_zgloz_") "_"g"_" "_ctag d addline^%mgsqlc(grp,.line)
 g pass2
 ;
passor ; generate code to handle 'or' predicate for subscript
 s lcase="abcdefghijklmnopqrstuvwxyz"
 s orn=0,tagv=%z("pv")_"("_tnum_","_i_")",tagvp=%z("pv")_"("_tnum_","_i_",""p"")",datag=tag_tagn_"x"_%z("dl")
 s ^mgtmp($j,"passor","tagv",tagv)=""
passor1 s orn=orn+1 i '$d(pre(y,"pre",orn)) g passorx
 s pretag=tag_tagn_"or"_orn_%z("dl"),pastag=tag_tagn_"or"_$e(lcase,orn)_%z("dl")
 s nxtag=$s($d(pre(y,"pre",orn+1)):tag_tagn_"or"_(orn+1)_%z("dl"),1:ptag)
 i $d(nopas(y,orn)) g passor2
 ; generate code to pass on subscript
 s line="" i orn>1 s line=pretag_" ;" d addline^%mgsqlc(grp,.line)
 s line=line_pre(y,"pre",orn)_" s "_tagv_"="""_pastag_"""" d addline^%mgsqlc(grp,.line)
 s line=pastag_" s "_y_"="_dirf_"("_zglo_"("_key_")"_zgloz_dirp_") i "_y_"="_$c(34)_$c(34)_" g "_nxtag d addline^%mgsqlc(grp,.line)
 i $d(pre(y,"post",orn)) s line=pre(y,"post",orn)_" g "_nxtag d addline^%mgsqlc(grp,.line)
 i $d(pre(y,"pre",orn+1)) s line=" g "_datag d addline^%mgsqlc(grp,.line)
 g passor1
passor2 ; generate code for definition test on subscript only
 s line="" i orn>1 s line=pretag_" ;" d addline^%mgsqlc(grp,.line)
 s line=line_pre(y,"pre",orn)_","_tagv_"="""_nxtag_"""" d addline^%mgsqlc(grp,.line)
 s line=" i '$l("_y_") g "_nxtag d addline^%mgsqlc(grp,.line)
 s line=" i '$d("_zglo_"("_key_")"_zgloz_") g "_nxtag d addline^%mgsqlc(grp,.line)
 i $d(pre(y,"pre",orn+1)) s line=" g "_datag d addline^%mgsqlc(grp,.line)
 g passor1
passorx s line=datag_" ;" d addline^%mgsqlc(grp,.line)
 s ctag="@"_tagv
 k nxtag,pretag,pastag,datag,lcase,orn,tagv
 q
 ;
nopas ; generate definition test for non-passed subscript(s)
 s (reset,comr)="" i qnum=1,unique(qnum) d reset
 s mxi=i,(lines,coms,linet,or)=""
 f npn=i:1:$l(z,keyd) s y=$p(z,keyd,npn) q:'$d(nopas(y))!$d(pre(y,"pre",2))  s mxi=npn d nopas1
 s def=1 i qnum=1,unique(1)=2,'$l(reset) s def=0
 s def=1 ;i def,$l(z,keyd)>mxi s def=0
 s qual="",goto=1 i qnum=1,unique(1)=2 s lines=lines_coms_%z("vdef")_"=1,%d=""""",reset=reset_comr_%z("vdef")_"=0",qual=%z("vdef")_",",goto=0
 i $l(lines) s lines=" "_"s"_" "_lines
 i $l(linet) s linet=" "_"i"_" "_linet
 i $l(reset) s reset=" "_"s"_" "_reset
 s line=lines s:$l(linet) line=line_linet_reset_$s(goto:" "_"g"_" "_ptag,1:"") i $l(line) d addline^%mgsqlc(grp,.line)
 i def s line=" "_"i"_" "_qual_"'"_"$d"_"("_zglo_"("_$p(z,keyd,1,mxi)_")"_zgloz_")"_reset_$s(goto:" "_"g"_" "_ptag,1:"") d addline^%mgsqlc(grp,.line)
nopasx s i=mxi
 k npn,mxi,coms,and,or,lines,linet
 q
 ;
nopas1 ; build key and null subscript tests
 s sub=y,set=$p(pre(y,"pre",1)," ",3,999),to=$p(set,"=",2,999)
 s trans=0 i '$d(^mgtmp($j,"from",2)),to'["(",to'[")",$l(to,%z("dsv"))'>3,$l(to,%z("dev"))'>3,'$d(^mgtmp($j,"outselx",1,y)),'$d(^mgtmp($j,"from","z",qnum,"pass",alias)) s trans=1,(sub,^mgtmp($j,"trans",$p(y,%z("dsv"),2)))=to
 i npn>i s key=key_com_sub
 i 'trans s lines=lines_coms_set,coms=","
 i to'[%z("dsv"),to'[%z("dev"),to?1""""1e.e1""""!(to?1n.n) q
 s linet=linet_or_"'$l("_sub_")",or="!"
 q
 ;
reset ; check for need to reset unique key outputs on failure
 n %noinc,line,lvar,pvar
 s %noinc=1
 s outsel=$g(^mgtmp($j,"sel",qnum))
 f j=1:1:outsel s x1=^mgtmp($j,"sel",qnum,j) d reset1
 i $l(reset) s line=reset d subvar^%mgsqlc s reset="("_line_")="""""
 k j,x1
 q
 ;
reset1 ; determine whether data item needs to be reset
 n tnum,alias
 i x1["("!(x1'[%z("dsv")) q
 s xx1=$p(x1,%z("dsv"),2),alias=$p(xx1,".",1) i alias="" q
 s tnum=^mgtmp($j,"from","x",qnum,alias)
 i $d(data(qnum,tnum,xx1)),^mgtmp($j,"key",qnum,tnum)'[x1 q
 s reset=reset_comr_x1,comr=","
 q
 ;
endsq ; determine whether an end-of-subquery subroutine needed
 k endsq(qnum)
 i qnum'=1,$d(sql("union",qnum)) q
 i qnum'=1 s endsq(qnum)="" q
 s endsq(qnum)="" q
 i $d(gvar(qnum))!$d(ord) s endsq(qnum)="" q
 q
 ;
dir ; determine physical parse direction parameters
 i dir="$o" s dirf=dir,dirp="" q
 ;i dir="$zp" s dirf=dir,dirp="" q
 i dir="$zp" s dirf="$o",dirp=",-1" q
 q
 ;
oj ; outer join
 n i,taga,tagz,cname,kno
 s ojcnt=%z("dsv")_"\#oj\"_qnum_"\"_tnum_%z("dsv"),ojcnt(0)=1,ojcnt(1)=%z("dsv")_"\#ojcnt\"_qnum_"\"_tnum_%z("dsv")
 s ojtagbp=tag_"\ojbp"_%z("dl"),ojtagxx=tag_"\ojxx"_%z("dl"),ojtagbxx=tag_"\ojbxx"_%z("dl"),ojtagpxx=tag(qnum)
 s taga=tag_"\oja"_%z("dl"),tagz=tag_"\ojz"_%z("dl")
 s line=" "_"s"_" "_ojcnt_"=0"_","_ojcnt(1)_"=1"_" "_"g"_" "_tagz d addline^%mgsqlc(grp,.line)
 s line=taga_" "_"i"_" "_ojcnt_">0 "_"g"_" "_tag(qnum) d addline^%mgsqlc(grp,.line)
 s tag(qnum)=taga
 s line=" "_"s"_" "_ojcnt(1)_"=0" d addline^%mgsqlc(grp,.line)
 s kno=0 f i=1:1:$l(key0(qnum,tnum)) s cname=$p(key0(qnum,tnum),",",i) i cname[%z("dsv") s kno=kno+1,line=" "_"s"_" "_cname_"=""""" d addline^%mgsqlc(grp,.line) i kno=1 s ojkey1=cname
 s cname="" f  s cname=$o(data(qnum,tnum,cname)) q:cname=""  s line=" "_"s"_" "_%z("dsv")_cname_%z("dsv")_"=""""" d addline^%mgsqlc(grp,.line)
 s line=" "_"g"_" "_ojtagbp d addline^%mgsqlc(grp,.line)
 s line=tagz_" ;" d addline^%mgsqlc(grp,.line)
 q
 ;
ojda ; process at end of parse, before get data
 s line=" g "_ojtagbxx d addline^%mgsqlc(grp,.line)
 s line=ojtagxx_" "_"g"_":'$l("_ojkey1_") "_ojtagpxx_" "_"g"_" "_tag(qnum) d addline^%mgsqlc(grp,.line)
 s line=ojtagbxx_" ;" d addline^%mgsqlc(grp,.line)
 s tag(qnum)=ojtagxx
 q
 ;
ojdz ; process after data retrieval
 n i,cname
 s cname="" f  s cname=$o(joinx(qnum,cname)) q:cname=""  i $d(joinx(qnum,cname,alias)) d ojdz1
 s line=" "_"s"_" "_ojcnt_"="_ojcnt_"+1" d addline^%mgsqlc(grp,.line)
 s line=ojtagbp_" ;" d addline^%mgsqlc(grp,.line)
 q
 ;
ojdz1 ; perform natural inner join on data
 n ii,join2,alias1,y
 s join2="" f ii=tnum-1:-1:1 s alias1=$p(^mgtmp($j,"from",qnum,ii),"~",2) i $d(joinx(qnum,cname,alias1)) s join2=%z("dsv")_alias1_"."_cname_%z("dsv") q
 i '$l(join2) q
 s y=%z("dsv")_alias_"."_cname_%z("dsv"),line=" "_"i"_" "_y_"'="_join2_" "_"g"_" "_tag(qnum) d addline^%mgsqlc(grp,.line)
 s ^mgtmp($j,"wexcl",qnum,y_"="_join2)="",^(join2_"="_y)=""
 q
 ;
gota ; new attribute available from single-level parse
 n j,y,sqvar
 f j=1:1:i s y=$p(z,keyd,j) i y[%z("dsv") s sqvar=$p(y,%z("dsv"),2) i $l(sqvar) s got("a",sqvar)=""
 d corel^%mgsqlc5
 q
 ;
kill k com,contyp,ct,data(qnum,tnum),tname,glb(qnum,tnum),i,ii,j,^mgtmp($j,"key",qnum,tnum),odel(qnum,tnum),p,r,subc,x,y,typ,postest
 q
 ;
temps ; determine subscripts for order/group sort file
 k order,order2
 s sort2=0 i qnum=1,$d(gvar(qnum)),$d(ord),$l(ord) d temps2
 s order=0
 i qnum=1,'sort2 f i=1:1 q:'$d(ord(i))  s lvar=ord(i),orderx(lvar)="" d temps1
 f i=1:1 q:'$d(gvar(qnum,i))  s lvar=gvar(qnum,i) i '$d(orderx(lvar)) d temps1
 k orderx
 q
 ;
temps1 ; determine pseudo-logical variable
 s order=order+1
 s var="\cm"_order
 s var=%z("dsv")_var_%z("dsv")
 s order(order)=lvar_"~"_var
 q
 ;
temps2 ; determine whether two sorts required
 n gvarx
 f i=1:1 q:'$d(gvar(qnum,i))  s gvarx(gvar(qnum,i))=""
 f i=1:1 q:'$d(ord(i))  i '$d(gvarx(ord(i))) s sort2=1 q
 i 'sort2 q
 s order2=0
 f i=1:1 q:'$d(ord(i))  s lvar=ord(i) d temps3
 q
 ;
temps3 ; determine pseudo-logical variable for second parse
 s order2=order2+1
 s var="\\cm"_order2
 s var=%z("dsv")_var_%z("dsv")
 s order2(order2)=lvar_"~"_var
 q
 ;
 
 

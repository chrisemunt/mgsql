%mgsqlc3 ;(CM) sql compiler ; 27 apr 2003  12:14 pm
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
a d vers^%mgsql("%mgsqlc3") q
 ;
endsq ; code to be executed on leaving a sub-query
 s line=%z("dl")_%z("pt")_qnum_"x"_%z("dl")
 i $d(^mgtmp($j,"group",qnum)) d regroup g endsqx
 d endsq1
 i qnum'=1 s line=line_" q" d addline^%mgsqlc(grp,.line) g endsqx
 i qnum=1,$d(^mgtmp($j,"order")) d reorder g endsqx
 s line=line_" g "_%z("dl")_%z("pt")_$s($d(sql("union",qnum)):nxtun_"s",1:"x")_%z("dl") d addline^%mgsqlc(grp,.line)
endsqx i qnum=1,$d(eof("l")) s line=%z("dl")_%z("pt")_"d"_%z("dl")_" ;" d addline^%mgsqlc(grp,.line)
 q
 ;
endsq1 ; unique result but expected as a list
 n com
 i qnum=1,$g(^mgtmp($j,"unique",qnum)) d row(grp,qnum,0,"")
 i qnum=1 q
 i '$g(^mgtmp($j,"unique",qnum)) q
 s com=^mgtmp($j,"sqcom",qnum)
 i com'["in",com'["exists" q
 s line=line_" ;" d addline^%mgsqlc(grp,.line)
 d outrowsq^%mgsqlc2
 q
 ;
regroup ; reorganise data for 'group by' clause
 n i,codezo,x,sort2,funtyp,sort2
 i line'="" s line=line_" ; groups" d addline^%mgsqlc(grp,.line)
 s sort2=0 i qnum=1,$d(^mgtmp($j,"order")) s sort2=1
 i sort2 s line=" k "_%z("ctg")_"("_%z("cts")_","_"""x2"")"_" s "_%z("pv")_"n=0" d addline^%mgsqlc(grp,.line)
 s (keyo,como)="" f i=1:1 q:'$d(^mgtmp($j,"group",qnum,i))  d
 . s x=$g(^mgtmp($j,"group",qnum,i,0))
 . s varo=%z("dsv")_"__order"_i_%z("dsv")
 . s dir=$p(x,"~",2),dir=$s(dir="desc":-1,1:1)
 . s line=" s "_varo_"=""""" d addline^%mgsqlc(grp,.line)
 . d reorder1(grp,qnum,i,.keyo,varo,.como,.tag,sort2,dir)
 . q
 s x="" f  s x=$o(^mgtmp($j,"sqag",qnum,x)) q:x=""  s fun="" f  s fun=$o(^mgtmp($j,"sqag",qnum,x,fun)) q:fun=""  d
 . s funtyp=$p(fun,"_",1)
 . i funtyp'="avg",funtyp'="min" q
 . s line=" s "_%z("vdata")_"=$g("_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_keyo_","_^mgtmp($j,"sqag",qnum,x,fun)_"))" d addline^%mgsqlc(grp,.line)
 . s line=" s "_%z("vdata")_"=$p("_%z("vdata")_",""#"",1)" d addline^%mgsqlc(grp,.line)
 . s line=" s "_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_keyo_","_^mgtmp($j,"sqag",qnum,x,fun)_")="_%z("vdata") d addline^%mgsqlc(grp,.line)
 . q
 i $d(^mgtmp($j,"having",1)) d having(grp,qnum,keyo,tag)
 i sort2 d sort2(grp,qnum,.keyo)
 s codezo=" m "_"%zo("_%z("vrc")_")="_%z("ctg")_"("_%z("cts")_","""_$s(sort2:"x2",1:"x")_""","_qnum_","_keyo_")"
 i qnum=1 s %data=0,%zq("tagp")=tag d row(grp,qnum,1,codezo),top(grp,qnum,1) s line=line_" g "_%zq("tagp") d addline^%mgsqlc(grp,.line) q
 i qnum'=1 d
 . s %zq("tag",qnum)=tag
 . s line=" s "_^mgtmp($j,"sel",qnum,1)_"="_%z("pv")_"d" d addline^%mgsqlc(grp,.line)
 . d outsq^%mgsqlc2
 . q
 q
 ;
having(grp,qnum,keyo,tag) ; set up test for 'having' clause
 n i,x,fun
 s line=""
 f i=1:1 q:'$d(^mgtmp($j,"having",i))  s x=^mgtmp($j,"having",i) d  s line=line_x
 . i x'[%z("dsv") q
 . s x=$p(x,%z("dsv"),2),fun=$p(x,"(",1),x=$p($p(x,"(",2,999),")",1)
 . s x="$g("_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_keyo_","_^mgtmp($j,"sqag",qnum,x,fun)_"))"
 . q
 i line="" q
 s line=" i '("_line_") g "_tag d addline^%mgsqlc(grp,.line)
 q
 ;
reorder ; reorder data for 'order by' clause
 n i,com,como,key0,varo,codezo,x,sort2
 s sort2=0
 s line=line_" s (",com=""
 f i=1:1 q:'$d(^mgtmp($j,"order",i))  s line=line_com_%z("dsv")_"__order"_$p(^mgtmp($j,"order",i,0),"~",1)_%z("dsv"),com=","
 s line=line_","_%z("pv")_"n)=""""" d addline^%mgsqlc(grp,.line)
 s (keyo,como)="" f i=1:1 q:'$d(^mgtmp($j,"order",i))  d
 . s x=$g(^mgtmp($j,"order",i,0))
 . s varo=%z("dsv")_"__order"_$p(x,"~",1)_%z("dsv")
 . s dir=$p(x,"~",2),dir=$s(dir="desc":-1,1:1)
 . d reorder1(grp,qnum,i,.keyo,varo,.como,.tag,sort2,dir)
 . q
 s tag=%z("dl")_%z("pt")_qnum_"o"_(i)_%z("dl"),%zq("tagp")=%z("dl")_%z("pt")_qnum_"o"_(i-1)_%z("dl")
 s line=tag_" s "_%z("pv")_"n=$o("_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_keyo_","_%z("pv")_"n))"_" i "_%z("pv")_"n="""" g "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 s codezo=" m "_"%zo("_%z("vrc")_")="_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_keyo_","_%z("pv")_"n"_")"
 s %data=0,%zq("tagp")=tag d row(grp,qnum,1,codezo),top(grp,qnum,1) s line=line_" g "_%zq("tagp") d addline^%mgsqlc(grp,.line) q
 q
 ;
reorder1(grp,qnum,kno,keyo,varo,como,tago,sort2,dir) ; for each grouped attribute
 s keyo=keyo_como_varo,como=","
 s tago=%z("dl")_%z("pt")_qnum_"o"_kno_%z("dl")
 s %zq("tagp")=$s(kno=1:$s(sort2:%z("dl")_%z("pt")_qnum_"on2"_%z("dl"),1:%zq("tagout")),kno>1:%z("dl")_%z("pt")_qnum_"o"_(kno-1)_%z("dl"),1:"")
 s line=tag_" s "_varo_"="_"$o("_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_keyo_"),"_dir_") i "_varo_"="""""
 i kno=1,qnum'=1 s line=line_" q" d addline^%mgsqlc(grp,.line) q
 s line=line_" g "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 q
 ;
sort2(grp,qnum,keyo) ; perform secondary sort
 n i,x,y,keyn,keyx,varx,com,dir
 s line=" ; secondary sort" d addline^%mgsqlc(grp,.line)
 s line=" m "_%z("vdata")_"="_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_keyo_")" d addline^%mgsqlc(grp,.line)
 s (keyn,com)="" f i=1:1 q:'$d(^mgtmp($j,"order",i))  d
 . s x=$g(^mgtmp($j,"order",i,0)),y=$p(x,"~",1) i y="" s y=1
 . s keyn=keyn_com_"$s("_%z("vdata")_"("_y_")"_"="""":"" "",1:"_%z("vdata")_"("_y_")"_")",com=","
 . q
 s line=" s "_%z("pv")_"n="_%z("pv")_"n+1" d addline^%mgsqlc(grp,.line)
 s line=" m "_%z("ctg")_"("_%z("cts")_","_"""x2"","_qnum_","_keyn_","_%z("pv")_"n)="_%z("vdata") d addline^%mgsqlc(grp,.line)
 s line=" g "_tag d addline^%mgsqlc(grp,.line)
 s line=%z("dl")_%z("pt")_qnum_"on2"_%z("dl")_" ; secondary sort output" d addline^%mgsqlc(grp,.line) ;_" s ("_keyo_","_%z("pv")_"n)=""""" d addline^%mgsqlc(grp,.line)
 s (keyx,com)="" f i=1:1 q:'$d(^mgtmp($j,"order",i))  d
 . s x=$g(^mgtmp($j,"order",i,0))
 . s varx=%z("dsv")_"__order"_$p(x,"~",1)_%z("dsv")
 . s dir=$p(x,"~",2),dir=$s(dir="desc":-1,1:1)
 . s keyx=keyx_com_varx,com=","
 . s tag=%z("dl")_%z("pt")_qnum_"on2"_i_%z("dl")
 . s %zq("tagp")=$s(i=1:%zq("tagout"),i>1:%z("dl")_%z("pt")_qnum_"on2"_(i-1)_%z("dl"),1:"")
 . s line=" s "_varx_"=""""" d addline^%mgsqlc(grp,.line)
 . s line=tag_" s "_varx_"="_"$o("_%z("ctg")_"("_%z("cts")_","_"""x2"","_qnum_","_keyx_"),"_dir_")"_" i "_varx_"="""""
 . i i=1,qnum'=1 s line=line_" q" d addline^%mgsqlc(grp,.line) q
 . s line=line_" g "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 . q
 s line=" s "_%z("pv")_"n=""""" d addline^%mgsqlc(grp,.line)
 s tag=%z("dl")_%z("pt")_qnum_"on2"_(i)_%z("dl"),%zq("tagp")=%z("dl")_%z("pt")_qnum_"on2"_(i-1)_%z("dl")
 s line=tag_" s "_%z("pv")_"n=$o("_%z("ctg")_"("_%z("cts")_","_"""x2"","_qnum_","_keyx_","_%z("pv")_"n))"_" i "_%z("pv")_"n="""" g "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 s keyo=keyx_","_%z("pv")_"n"
 q
 ;
row(grp,qnum,havezo,codezo) ; output a line of sql data
 n outsel,i
 s line=line_" s "_%z("vrc")_"="_%z("vrc")_"+1" d addline^%mgsqlc(grp,.line)
 i codezo'="" s line=codezo d addline^%mgsqlc(grp,.line)
 i $d(^mgtmp($j,"upd")) q
 i 'havezo d
 . s outsel=^mgtmp($j,"outsel",qnum)
 . f i=1:1:outsel s line=line_" s %zo("_%z("vrc")_","_i_")="_^mgtmp($j,"outsel",qnum,i) d addline^%mgsqlc(grp,.line)
 . q
 s line=line_" s "_%z("vok")_"=$$ss^%mgsqlz(.%zi,.%zo,"_%z("vrc")_") i "_%z("vok")_" g "_%zq("tagx") d addline^%mgsqlc(grp,.line)
 q
 ;
top(grp,qnum,sort) ; sql top
 n top
 s top=$g(^mgtmp($j,"sel",qnum,0)) i top'?1"top#"1n.n q
 s top=$p(top,"#",2)
 i sort s line=" i "_%z("vrc")_"'<"_top_" g "_%zq("tagout") d addline^%mgsqlc(grp,.line)
 i 'sort s line=" i "_%z("vrc")_"'<"_top_" g "_%zq("tagx") d addline^%mgsqlc(grp,.line)
 q
 ;
 
 

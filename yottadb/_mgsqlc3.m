%mgsqlc3 ;(CM) sql compiler ; 27 apr 2003  12:14 pm
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
 i qnum=1,$g(^mgtmp($j,"unique",qnum)) d row^%mgsqlc3
 i qnum=1 q
 i '^mgtmp($j,"unique",qnum) q
 s com=^mgtmp($j,"sqcom",qnum)
 i com'["in",com'["exists" q
 s line=line_" ;" d addline^%mgsqlc(grp,.line)
 d outrowsq^%mgsqlc2
 q
 ;
regroup ; reorganise data for 'group by' clause
 s line=line_" s (",com="",i=1
 f i=1:1 q:'$d(order(i))  s line=line_com_$p(order(i),"~",2),com=","
 s line=line_")=""""" d addline^%mgsqlc(grp,.line)
 i sort2 s line=" k "_%z("ctg")_"("_%z("cts")_","_"""x2"")"_" s "_%z("pv")_"n=0" d addline^%mgsqlc(grp,.line)
 s i=0,(keyo,como)=""
 f i=1:1 q:'$d(order(i))  d reorder1
 s line=" s "_%z("vdata")_"="_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_como_keyo_")" d addline^%mgsqlc(grp,.line)
 s x="" f  s x=$o(^mgtmp($j,"sqag",qnum,x)) q:x=""  s fun="" f  s fun=$o(^mgtmp($j,"sqag",qnum,x,fun)) q:fun=""  d regroup1
 i $d(^mgtmp($j,"having",1)) d having
 f i=1:1 q:'$d(^mgtmp($j,"outsel",qnum,i))  s item=^mgtmp($j,"outsel",qnum,i),line=" s "_item_"=$p("_%z("vdata")_",""~"","_i_")" d addline^%mgsqlc(grp,.line)
 i sort2 d sort2
 i qnum=1 s %data=0,%zq("tagp")=tag d row s line=line_" g "_%zq("tagp") d addline^%mgsqlc(grp,.line) q
 i qnum'=1 d
 . s %zq("tag",qnum)=tag
 . s line=" s "_^mgtmp($j,"sel",qnum,1)_"="_%z("pv")_"d" d addline^%mgsqlc(grp,.line)
 . d outsq^%mgsqlc2
 . q
 q
 ;
regroup1 ; set aggregate(s) into their relevant group
 n funtyp
 s funtyp=$p(fun,"_",1)
 i funtyp="avg"!(funtyp="min") s line=" s $p("_%z("pv")_"d,""~"","_^mgtmp($j,"sqag",qnum,x,fun)_")=$p($p("_%z("pv")_"d,""~"","_^mgtmp($j,"sqag",qnum,x,fun)_"),""#"",1)"
 d addline^%mgsqlc(grp,.line)
 q
 ;
having ; set up test for 'having' clause
 s line=""
 f i=1:1 q:'$d(^mgtmp($j,"having",i))  s x=^mgtmp($j,"having",i) d having1 s line=line_x
 i line="" q
 s line=" i '("_line_") g "_tag d addline^%mgsqlc(grp,.line)
 q
 ;
having1 ; process individual element in 'having' clause
 i x'[%z("dsv") q
 s x=$p(x,%z("dsv"),2),fun=$p(x,"(",1),x=$p($p(x,"(",2,999),")",1)
 s x="$p("_%z("vdata")_",""~"","_^mgtmp($j,"sqag",qnum,x,fun)_")"
 q
 ;
reorder ; reorder data for 'order by' clause
 s line=line_" s (",com=""
 f i=1:1 q:'$d(order(i))  s line=line_com_$p(order(i),"~",2),com=","
 s line=line_","_%z("pv")_"n)=""""" d addline^%mgsqlc(grp,.line)
 s (keyo,como)="" f i=1:1:$l(ord,",") d reorder1
 s tag=%z("dl")_%z("pt")_qnum_"o"_(i+1)_%z("dl"),%zq("tagp")=%z("dl")_%z("pt")_qnum_"o"_i_%z("dl")
 s line=tag_" s "_%z("pv")_"n=$o("_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_keyo_","_%z("pv")_"n))"_" i "_%z("pv")_"n="""" g "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("vdata")_"="_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_keyo_","_%z("vdata")_")" d addline^%mgsqlc(grp,.line)
 s %data=0,%zq("tagp")=tag d row s line=line_" g "_%zq("tagp") d addline^%mgsqlc(grp,.line) q
 q
 ;
reorder1 ; for each grouped attribute
 s dir="$o" i qnum=1,$d(^mgtmp($j,"order",i)) s dir=$p(^mgtmp($j,"order",i,0),"~",2),dir=$s(dir="desc":"$zp",1:"$o")
 s x=$p(order(i),"~",2)
 s keyo=keyo_como_x,como=","
 s tag=%z("dl")_%z("pt")_qnum_"o"_i_%z("dl")
 s %zq("tagp")=$s(i=1:$s(sort2:%z("dl")_%z("pt")_qnum_"on2"_%z("dl"),1:%zq("tagout")),i>1:%z("dl")_%z("pt")_qnum_"o"_(i-1)_%z("dl"),1:"")
 s line=tag_" s "_x_"="_dir_"("_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_keyo_")) i "_x_"="""""
 i i=1,qnum'=1 s line=line_" q" d addline^%mgsqlc(grp,.line) q
 s line=line_" g "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 q
 ;
sort2 ; perform secondary sort
 s (keyo,com)=""
 f i=1:1 q:'$d(^mgtmp($j,"order",i))  s seln=$p($p(ord,",",i),"~",1),v1=order2(i),v2=$p(v1,"~",2),v1=$p(v1,"~",1),keyo=keyo_com_v2,com=",",line=" s ("_v1_","_v2_")=$p("_%z("pv")_"d,""~"","_seln_") i "_v2_"="""" s "_v2_"="" """ d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("pv")_"n="_%z("pv")_"n+1" d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("ctg")_"("_%z("cts")_","_"""x2"","_qnum_","_keyo_","_%z("pv")_"n)="_%z("pv")_"d" d addline^%mgsqlc(grp,.line)
 s line=" g "_tag d addline^%mgsqlc(grp,.line)
 s line=%z("dl")_%z("pt")_qnum_"on2"_%z("dl")_" s ("_keyo_","_%z("pv")_"n)=""""" d addline^%mgsqlc(grp,.line)
 s (keyo,como)="" f i=1:1 q:'$d(^mgtmp($j,"order",i))  d sort21
 s tag=%z("dl")_%z("pt")_qnum_"on2"_(i+1)_%z("dl"),%zq("tagp")=%z("dl")_%z("pt")_qnum_"on2"_i_%z("dl")
 s line=tag_" s "_%z("pv")_"n=$o("_%z("ctg")_"("_%z("cts")_","_"""x2"","_qnum_","_keyo_","_%z("pv")_"n))"_" i "_%z("pv")_"n="""" g "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("vdata")_"="_%z("ctg")_"("_%z("cts")_","_"""x2"","_qnum_","_keyo_","_%z("pv")_"n)" d addline^%mgsqlc(grp,.line)
 q
 ;
sort21 ; for each grouped attribute in secondary sort
 s dir="$o" i qnum=1,$d(^mgtmp($j,"order",i)) s dir=$p(^mgtmp($j,"order",i,0),"~",2),dir=$s(dir="desc":"$zp",1:"$o")
 s x=$p(order2(i),"~",2)
 s keyo=keyo_como_x,como=","
 s tag=%z("dl")_%z("pt")_qnum_"on2"_i_%z("dl")
 s %zq("tagp")=$s(i=1:%zq("tagout"),i>1:%z("dl")_%z("pt")_qnum_"on2"_(i-1)_%z("dl"),1:"")
 s line=tag_" s "_x_"="_dir_"("_%z("ctg")_"("_%z("cts")_","_"""x2"","_qnum_","_keyo_"))"_" i "_x_"="""""
 i i=1,qnum'=1 s line=line_" q" d addline^%mgsqlc(grp,.line) q
 s line=line_" g "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 q
 ;
row ; output a line of sql data
 s line=line_" s "_%z("vrc")_"="_%z("vrc")_"+1" d addline^%mgsqlc(grp,.line)
 i $d(^mgtmp($j,"upd")) q
 s outsel=^mgtmp($j,"outsel",qnum)
 f i=1:1:outsel s line=line_" s %zo("_%z("vrc")_","_i_")="_^mgtmp($j,"outsel",qnum,i) d addline^%mgsqlc(grp,.line)
 s line=line_" s "_%z("vok")_"=$$ss^%mgsqlz(.%zi,.%zo,"_%z("vrc")_")" d addline^%mgsqlc(grp,.line)
 q
 ;
 
 

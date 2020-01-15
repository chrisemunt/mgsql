%mgsqlc6 ;(CM) sql compiler - aggregates ; 19 jan 2003  4:34 pm
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
a d vers^%mgsql("%mgsqlc6") q
 ;
aginit(grp,qnum,tnum) ; initialise select functions on data attributes
 n ag,item,kdist
 i qnum=1,$g(^mgtmp($j,"unique",1))=3 d init(grp,qnum)
 i $d(^mgtmp($j,"ktmp",qnum)) s line=" k "_%z("ctg")_"("_%z("cts")_","_qnum_")" d addline^%mgsqlc(grp,.line)
 i $d(^mgtmp($j,"group",qnum)) s ^mgtmp($j,"ktmp")=1,line=" k "_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_")" d addline^%mgsqlc(grp,.line) q
 s kdist=0
 s item="" f  s item=$o(^mgtmp($j,"sqag",qnum,item)) q:item=""  s ag="" f  s ag=$o(^mgtmp($j,"sqag",qnum,item,ag)) q:ag=""  d aginit1(grp,qnum,tnum,item,ag,.kdist)
 q
 ;
aginit1(grp,qnum,tnum,item,ag,kdist) ; generate line of code to initilalise each specific aggregate
 n sqvar,agtyp,notnull
 s agtyp=$p(ag,"_",1)
 s notnull=0 i $p(ag,"_",2)="notnull" s notnull=1
 s sqvar=%z("dsv")_ag_"("_item_")"_%z("dsv")
 i agtyp="count" s:item'["*" line=line_" s "_%z("dsv")_ag_"("_item_")"_%z("dsv")_"=0" i item["*" s line=line_" s "_sqvar_"=0"
 i agtyp="cntd",item'["*",qnum'=1,'kdist s kdist=1,line=" k "_%z("ctg")_"("_%z("cts")_","_"""d"","_qnum_")" d addline^%mgsqlc(grp,.line)
 i agtyp="cntd",item'["*" s line=" s "_%z("dsv")_"cntd("_item_")"_%z("dsv")_"=0" d addline^%mgsqlc(grp,.line)
 i agtyp="sum" s line=line_" s "_%z("dsv")_ag_"("_item_")"_%z("dsv")_"=0"
 i agtyp="avg" s line=line_" s "_%z("dsv")_ag_"avsum("_item_")"_%z("dsv")_"=0,"_%z("dsv")_ag_"avcnt("_item_")"_%z("dsv")_"=0"
 i agtyp="max" s line=line_" s "_%z("dsv")_ag_"("_item_")"_%z("dsv")_"="""""
 i agtyp="min" s line=line_" s "_%z("dsv")_ag_"("_item_")"_%z("dsv")_"="""","_%z("dsv")_ag_"nullindata("_item_")"_%z("dsv")_"=0"
 d addline^%mgsqlc(grp,.line)
 q
 ;
updfun ; update aggregates
 s ordsub=""
 i $d(^mgtmp($j,"group",qnum)) d ggroup
 s x="" f  s x=$o(^mgtmp($j,"sqag",qnum,x)) q:x=""  s fun="" f  s fun=$o(^mgtmp($j,"sqag",qnum,x,fun)) q:fun=""  d updfun1
 i $d(^mgtmp($j,"group",qnum)) d ugroup
 k gvaru
 q
 ;
updfun1 ; generate line of code to update specific aggregate
 n z,funtyp,nulltest
 i $d(^mgtmp($j,"ktmp",qnum)) s line=" k "_%z("ctg")_"("_%z("cts")_","_qnum_")" d addline^%mgsqlc(grp,.line)
 s funtyp=$p(fun,"_",1),nulltest="" i $p(fun,"_",2)="notnull" s nulltest=" "_"i"_" $l("_%z("dsv")_x_%z("dsv")_")"
 s z=%z("dsv")_fun_"("_x_")"_%z("dsv")
 ;
 i funtyp="count",$d(index(0,alias,"a")) s nulltest=""
 ;
 i funtyp="count",$d(index(0,alias,"a")) s line=nulltest_" "_"s"_" "_z_"="_z_"+"_%z("dsv")_x_%z("dsv") d addline^%mgsqlc(grp,.line) q
 i funtyp="count",x'["*" s line=nulltest_" "_"s"_" "_z_"="_z_"+1" d addline^%mgsqlc(grp,.line) q
 i funtyp="count",x["*" s line=" "_"s"_" "_z_"="_z_"+1" d addline^%mgsqlc(grp,.line) q
 i funtyp="cntd",x'["*" s ^mgtmp($j,"ktmp")=1
 i funtyp="cntd",x'["*" d cntd q
 i funtyp="sum" s line=nulltest_" "_"s"_" "_z_"="_z_"+"_%z("dsv")_x_%z("dsv") d addline^%mgsqlc(grp,.line) q
 i funtyp="avg" s line=nulltest_" "_"s"_" "_%z("dsv")_fun_"avcnt("_x_")"_%z("dsv")_"="_%z("dsv")_fun_"avcnt("_x_")"_%z("dsv")_"+1,"_%z("dsv")_fun_"avsum("_x_")"_%z("dsv")_"="_%z("dsv")_fun_"avsum("_x_")"_%z("dsv")_"+"_%z("dsv")_x_%z("dsv")_","_z_"="_%z("dsv")_fun_"avsum("_x_")"_%z("dsv")_"/"_%z("dsv")_fun_"avcnt("_x_")"_%z("dsv") d addline^%mgsqlc(grp,.line)
 i funtyp="max" s line=nulltest_" "_"k"_" %s s:$l("_%z("dsv")_x_%z("dsv")_") %s("_%z("dsv")_x_%z("dsv")_")="""" s:$l("_z_") %s("_z_")="""" s "_z_"=$o(%s(""""),-1) k %s" d addline^%mgsqlc(grp,.line) q
 i funtyp="min" s line=nulltest_" s:'$l("_%z("dsv")_x_%z("dsv")_") "_z_"="""","_%z("dsv")_fun_"nullindata("_x_")"_%z("dsv")_"=1 i '"_%z("dsv")_fun_"nullindata("_x_")"_%z("dsv")_" k %s s %s("_%z("dsv")_x_%z("dsv")_")="""" s:$l("_z_") %s("_z_")="""" s "_z_"=$o(%s("""")) k %s" d addline^%mgsqlc(grp,.line) q
 i $d(^mgtmp($j,"group",qnum)) q
 q
 ;
cntd ; count distinct
 n tag,notnullx
 s notnullx="" i $l(nulltest) s notnullx="{notnull}"
 s tag=ldx_sqt_"cntd"_notnullx_x_ldx
 i $l(nulltest) s line=" i '$l("_%z("dsv")_x_%z("dsv")_") g "_tag d addline^%mgsqlc(grp,.line)
 s ref=%z("ctg")_"("_%z("cts")_","_"""d"","_qnum_$s($l(ordsub):","_ordsub,1:"")_","_""""_%z("dsv")_notnullx_x_%z("dsv")_""""_","_%z("dsv")_x_%z("dsv")_")"
 s line=" s:'$l("_%z("dsv")_x_%z("dsv")_") "_%z("dsv")_x_%z("dsv")_"="" "" i $d("_ref_") g "_tag d addline^%mgsqlc(grp,.line)
 s line=" s "_ref_"=""""" d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("dsv")_fun_"("_x_")"_%z("dsv")_"="_%z("dsv")_fun_"("_x_")"_%z("dsv")_"+1" d addline^%mgsqlc(grp,.line)
 s line=tag_" ;" d addline^%mgsqlc(grp,.line)
 q
 ;
ggroup ; retrieve data for current update on 'grouped' items
 k gvaru s gvaru=0
 s tk0=""",""""x"""","_qnum
 s ordsub="",com=""
 f i=1:1 q:'$d(order(i))  d outrow21^%mgsqlc2
 s line=" s "_%z("vdata")_"=$g("_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_ordsub_"))" d addline^%mgsqlc(grp,.line)
 s x="" f  s x=$o(^mgtmp($j,"sqag",qnum,x)) q:x=""  s fun="" f  s fun=$o(^mgtmp($j,"sqag",qnum,x,fun)) q:fun=""  d ggroup1
 k rec0,rec
 q
 ;
ggroup1 ; retrieve data for specific function
 n z,ref,funtyp
 s funtyp=$p(fun,"_",1)
 s z=%z("dsv")_fun_"("_x_")"_%z("dsv")
 s line=" s "_%z("vdatax")_"=$p("_%z("vdata")_",""~"","_^mgtmp($j,"sqag",qnum,x,fun)_")" d addline^%mgsqlc(grp,.line)
 i funtyp="count"!(funtyp="cntd")!(funtyp="sum")!(funtyp="max") s line=" s "_z_"="_%z("vdatax")_" i "_%z("vdata")_"="""" s "_z_"=0"
 i funtyp="avg" s line=" s:"_%z("vdata")_"'="""" "_%z("dsv")_fun_"avcnt("_x_")"_%z("dsv")_"=$p("_%z("vdatax")_",""#"",2),"_%z("dsv")_fun_"avsum("_x_")"_%z("dsv")_"=$p("_%z("vdatax")_",""#"",3) s:"_%z("vdata")_"="""" "_%z("dsv")_fun_"avcnt("_x_")"_%z("dsv")_"=0,"_%z("dsv")_fun_"avsum("_x_")"_%z("dsv")_"=0"
 i funtyp="min" s line=" s:"_%z("vdata")_"'="""" "_z_"=$p(%d,""#"",1),"_%z("dsv")_fun_"nullindata("_x_")"_%z("dsv")_"=$p(%d,""#"",2) s:"_%z("vdata")_"="""" "_z_"="""","_%z("dsv")_fun_"nullindata("_x_")"_%z("dsv")_"=0"
 d addline^%mgsqlc(grp,.line)
 q
 ;
ugroup ; update goups
 s line=" s "_%z("vdata")_"="_recc d addline^%mgsqlc(grp,.line)
 s x="" f  s x=$o(^mgtmp($j,"sqag",qnum,x)) q:x=""  s fun="" f  s fun=$o(^mgtmp($j,"sqag",qnum,x,fun)) q:fun=""  d ugroup1
 ;s gvaru=gvaru+1,gvaru(gvaru)=$c(1)_tk0_$c(1)_%z("pv")_"d"
 s line=" ; set the record" d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("ctg")_"("_%z("cts")_","_"""x"","_qnum_","_ordsub_")="_%z("vdata") d addline^%mgsqlc(grp,.line)
 q
 ;
ugroup1 ; update group for specific function
 n funtyp,z
 ;s gvaru=gvaru+1
 s funtyp=$p(fun,"_",1)
 s z=%z("dsv")_fun_"("_x_")"_%z("dsv")
 i funtyp="count"!(funtyp="cntd")!(funtyp="sum")!(funtyp="max") s line=" s $p("_%z("vdata")_",""~"","_^mgtmp($j,"sqag",qnum,x,fun)_")="_z
 i funtyp="min" s line=" s $p("_%z("vdata")_",""~"","_^mgtmp($j,"sqag",qnum,x,fun)_")="_z_"_""#""_"_%z("dsv")_fun_"nullindata("_x_")"_%z("dsv")
 i funtyp="avg" s line=" s $p("_%z("vdata")_",""~"","_^mgtmp($j,"sqag",qnum,x,fun)_")="_z_"_""#""_"_%z("dsv")_fun_"avcnt("_x_")"_%z("dsv")_"_""#""_"_%z("dsv")_fun_"avsum("_x_")"_%z("dsv")
 d addline^%mgsqlc(grp,.line)
 q
 ;
init(grp,qnum) ; initialise select statement for unique queries
 n line,outsel,com,i,x
 s outsel=^mgtmp($j,"outsel")
 s (line,com)="" f i=1:1:outsel s x=^mgtmp($j,"sel",qnum,i) i x[%z("dsv"),x'["(" s line=line_com_x,com="," i $l(line)>200 s line=" s ("_line_")=""""",com="" d addline^%mgsqlc(grp,.line)
 i $l(line) s line=" s ("_line_")=""""" d addline^%mgsqlc(grp,.line)
 q
 ;
 

<map version="docear 1.1" project="14FD099F8F985QT959J90Z53U5ZUFPVWENJ2" project_last_home="file:/Users/Nanoq/Documents/Uni/OvGU/DigiEng/Semester3/DigiEngProjekt/Simulation/documentation/projectReport/docear/" dcr_id="1377253696629_575mr2xhasgzy80oz8d2cqhjn">
<!--To view this file, download Docear - The Academic Literature Suite from http://www.docear.org -->
<attribute_registry SHOW_ATTRIBUTES="hide"/>
<node TEXT="Mixed-reality Simulation of Quadcopter-Swarms" FOLDED="false" ID="ID_1723255651" CREATED="1283093380553" MODIFIED="1443465523990" DCR_PRIVACY_LEVEL="DEMO"><hook NAME="MapStyle">
    <properties show_icon_for_attributes="true" show_note_icons="true"/>

<map_styles>
<stylenode LOCALIZED_TEXT="styles.root_node">
<stylenode LOCALIZED_TEXT="styles.predefined" POSITION="right">
<stylenode LOCALIZED_TEXT="default" MAX_WIDTH="600" COLOR="#000000" STYLE="as_parent">
<font NAME="SansSerif" SIZE="10" BOLD="false" ITALIC="false"/>
</stylenode>
<stylenode LOCALIZED_TEXT="defaultstyle.details"/>
<stylenode LOCALIZED_TEXT="defaultstyle.note"/>
<stylenode LOCALIZED_TEXT="defaultstyle.floating">
<edge STYLE="hide_edge"/>
<cloud COLOR="#f0f0f0" SHAPE="ROUND_RECT"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.user-defined" POSITION="right">
<stylenode LOCALIZED_TEXT="styles.topic" COLOR="#18898b" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subtopic" COLOR="#cc3300" STYLE="fork">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.subsubtopic" COLOR="#669900">
<font NAME="Liberation Sans" SIZE="10" BOLD="true"/>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.important">
<icon BUILTIN="yes"/>
</stylenode>
</stylenode>
<stylenode LOCALIZED_TEXT="styles.AutomaticLayout" POSITION="right">
<stylenode LOCALIZED_TEXT="AutomaticLayout.level.root" COLOR="#000000">
<font SIZE="18"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,1" COLOR="#0033ff">
<font SIZE="16"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,2" COLOR="#00b439">
<font SIZE="14"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,3" COLOR="#990000">
<font SIZE="12"/>
</stylenode>
<stylenode LOCALIZED_TEXT="AutomaticLayout.level,4" COLOR="#111111">
<font SIZE="10"/>
</stylenode>
</stylenode>
</stylenode>
</map_styles>
</hook>
<hook NAME="AutomaticEdgeColor" COUNTER="3"/>
<node TEXT="Introduction" POSITION="right" ID="ID_1693751078" CREATED="1344508137611" MODIFIED="1443465524032" DCR_PRIVACY_LEVEL="DEMO">
<edge COLOR="#ff0000" WIDTH="3"/>
<hook NAME="FirstGroupNode"/>
<node TEXT="Motivation" ID="ID_1380533534" CREATED="1344510886390" MODIFIED="1443465524032" DCR_PRIVACY_LEVEL="DEMO">
<node TEXT="project context" ID="ID_1307261470" CREATED="1442919279390" MODIFIED="1442919344967">
<node TEXT="carried out at the swarm lab at the Otto-von-Guericke University Magdeburg" ID="ID_812286036" CREATED="1442919403434" MODIFIED="1442919636509"/>
<node TEXT="research focus on implementing swarm algorithms with quadcopter" ID="ID_518959680" CREATED="1442919636945" MODIFIED="1442920683282"/>
<node TEXT="use of own small and light quadcopters" ID="ID_1535142412" CREATED="1442920683578" MODIFIED="1442921176935"/>
<node TEXT="quadcopters fly without external reference" ID="ID_1373596032" CREATED="1442921151007" MODIFIED="1442921264113"/>
</node>
<node TEXT="what are the problems" ID="ID_1700491931" CREATED="1442919364318" MODIFIED="1442919378219" MOVED="1442921954688">
<node TEXT="as the quadcopter are developed in the group, they are under constant change" ID="ID_563695101" CREATED="1442921264414" MODIFIED="1442921326601" MOVED="1442921977809"/>
<node TEXT="flying multiple quadcopter with new control or beavioural algorithms in a small space is risky and likely to damage the quadcopter" ID="ID_1758534944" CREATED="1442921326791" MODIFIED="1442921394798" MOVED="1442921969132"/>
<node TEXT="a simulation tool to test new algorithms is desirable" ID="ID_807161758" CREATED="1442921413564" MODIFIED="1442921433393" MOVED="1442922031664"/>
<node TEXT="pure simulation is more abstract than a mixed reality simulation where the behaviour of a  real and simulated quadcopter can directly be compared" ID="ID_1004769362" CREATED="1442921433558" MODIFIED="1442921598470" MOVED="1442922038353"/>
</node>
<node TEXT="Idea" ID="ID_942199086" CREATED="1442922075945" MODIFIED="1442922079165" MOVED="1442922081474">
<node TEXT="mixed reality simulation can use one or multiple real quadcopters and upscale it with simulated quadcopters without increasing cost and damaging risk" ID="ID_434822426" CREATED="1442921598788" MODIFIED="1442921839206" MOVED="1442922088572"/>
</node>
<node TEXT="who needs the results" ID="ID_941854880" CREATED="1442919346076" MODIFIED="1442919363994">
<node TEXT="research with new behaviours" ID="ID_386053412" CREATED="1442921923495" MODIFIED="1442925573496"/>
<node TEXT="test copter enhancement, like communication models" ID="ID_857071801" CREATED="1442925549645" MODIFIED="1442925619585"/>
<node TEXT="test control parametes under specified conditions" ID="ID_337831734" CREATED="1442925589070" MODIFIED="1442925662343"/>
</node>
<node TEXT="existing solutions, differences to current approach" ID="ID_333074571" CREATED="1442919379246" MODIFIED="1442919399614">
<node TEXT="in contrast to exisiting approaches \cite{Chen2011}, our focus lies not on hardware development, but on increasing situation complexity by computation power instead of more cost intensive real hardware" ID="ID_717402559" CREATED="1443466339393" MODIFIED="1443509346107"/>
</node>
</node>
<node TEXT="Problem Statement" ID="ID_577115243" CREATED="1344510985951" MODIFIED="1443465524034" DCR_PRIVACY_LEVEL="DEMO">
<node TEXT="simulation that is realisitic, fast and scaleable" ID="ID_1292574069" CREATED="1442926286786" MODIFIED="1442944401667"/>
<node TEXT="communication between real quadcopter and instances in the simulation" ID="ID_553962508" CREATED="1442944402829" MODIFIED="1442944457961"/>
<node TEXT="how are we going to reach these goals?" ID="ID_690565019" CREATED="1442946171244" MODIFIED="1442947670086"/>
</node>
<node TEXT="Outline" ID="ID_1481327252" CREATED="1344511159033" MODIFIED="1443465524034" DCR_PRIVACY_LEVEL="DEMO"/>
</node>
<node TEXT="Theory" POSITION="right" ID="ID_1098134891" CREATED="1344508140609" MODIFIED="1443465524034" DCR_PRIVACY_LEVEL="DEMO">
<edge COLOR="#0000ff" WIDTH="3"/>
<node TEXT="Quadcopter Modelling" ID="ID_512165507" CREATED="1344511282609" MODIFIED="1443465524034" DCR_PRIVACY_LEVEL="DEMO">
<node TEXT="Quadcopter physical model" ID="ID_1047626896" CREATED="1442946037461" MODIFIED="1442946047998">
<node TEXT="quadcopter as one object in 3D space" ID="ID_1575036961" CREATED="1443510297122" MODIFIED="1443510406614">
<node TEXT="position (vector), velocity (vector)" ID="ID_1288946187" CREATED="1443510408610" MODIFIED="1443510438089"/>
<node TEXT="orientation (Vector of angles), change of orientation (vector)" ID="ID_1057526014" CREATED="1443510438199" MODIFIED="1443510524834"/>
<node TEXT="Rotation Matrix" ID="ID_681422982" CREATED="1443510525320" MODIFIED="1443510536576"/>
<node TEXT="Quaternions" ID="ID_1318887103" CREATED="1443510536884" MODIFIED="1443510541714"/>
</node>
<node TEXT="How to move the quadcopter" ID="ID_947269990" CREATED="1443510546150" MODIFIED="1443510602178">
<node TEXT="Quadcopter has 4 rotors, where 2 are turning in the same direction" ID="ID_1587686563" CREATED="1443510603602" MODIFIED="1443510737521">
<node TEXT="Modelling of rotor" ID="ID_1902436064" CREATED="1443510762472" MODIFIED="1443510774101"/>
<node TEXT="torque of e-motor" ID="ID_1262821780" CREATED="1443510774483" MODIFIED="1443510798394"/>
<node TEXT="force on the rotor" ID="ID_1689432542" CREATED="1443510834957" MODIFIED="1443510842261"/>
<node TEXT="movement of the roto" ID="ID_1701742037" CREATED="1443510842702" MODIFIED="1443510850485"/>
<node TEXT="thrust (downforce) of a rotor" ID="ID_1366853837" CREATED="1443510798740" MODIFIED="1443510858902"/>
</node>
<node TEXT="resulting force of 4 rotors on quadcopter" ID="ID_1324212943" CREATED="1443510903025" MODIFIED="1443510913699"/>
<node TEXT="basic pid control algorithm of quadcopter" ID="ID_987114423" CREATED="1443510862583" MODIFIED="1443510938811"/>
</node>
</node>
</node>
<node TEXT="Vrep" ID="ID_972169939" CREATED="1344511369742" MODIFIED="1443465524034" DCR_PRIVACY_LEVEL="DEMO">
<node TEXT="simulationsumgebung f&#xfc;r Roboter" ID="ID_1665593498" CREATED="1442946057787" MODIFIED="1442946087644"/>
<node TEXT="" ID="ID_1652188039" CREATED="1442946088138" MODIFIED="1442946088138"/>
</node>
<node TEXT="Paparazzi" ID="ID_427732587" CREATED="1443438347905" MODIFIED="1443438419043">
<node TEXT="Ground Station" ID="ID_73461531" CREATED="1443438429274" MODIFIED="1443438439036" MOVED="1443438432358"/>
<node TEXT="Quadcopter" ID="ID_739922912" CREATED="1443438439185" MODIFIED="1443438472333"/>
</node>
<node TEXT="Communication/Ivy-Bus" ID="ID_591738915" CREATED="1344511414252" MODIFIED="1443465524035" DCR_PRIVACY_LEVEL="DEMO"/>
</node>
<node TEXT="Implementation" POSITION="right" ID="ID_837868971" CREATED="1344508144956" MODIFIED="1443465524035" DCR_PRIVACY_LEVEL="DEMO">
<hook NAME="FirstGroupNode"/>
<edge COLOR="#00ff00" WIDTH="3"/>
<node TEXT="Simulation Environment" ID="ID_1595771395" CREATED="1344508164522" MODIFIED="1442910547077">
<node TEXT="implementation of quadcopter physics" ID="ID_811795507" CREATED="1443510986742" MODIFIED="1443515650422">
<node TEXT="vrep-model" ID="ID_1749641690" CREATED="1443515652029" MODIFIED="1443515663448"/>
<node TEXT="particle simulation" ID="ID_1166481675" CREATED="1443515663894" MODIFIED="1443515669648">
<node TEXT="noise simulation by particle collision with body" ID="ID_1817615551" CREATED="1443516092458" MODIFIED="1443516107355"/>
</node>
<node TEXT="throttle tuning with logistic curve" ID="ID_600550203" CREATED="1443515670086" MODIFIED="1443516082822"/>
</node>
</node>
<node TEXT="Communication Link" ID="ID_163595282" CREATED="1442910548433" MODIFIED="1442910554748"/>
<node TEXT="Interface Software" ID="ID_44434277" CREATED="1442910555281" MODIFIED="1442910777299"/>
<node TEXT="Quadcopter" ID="ID_1766749105" CREATED="1442910778096" MODIFIED="1442911501552"/>
</node>
<node TEXT="Evaluation" POSITION="right" ID="ID_220604319" CREATED="1344508149448" MODIFIED="1443465524036" DCR_PRIVACY_LEVEL="DEMO">
<edge COLOR="#ff00ff" WIDTH="3"/>
<node TEXT="Speed" ID="ID_1262024868" CREATED="1344508161499" MODIFIED="1442915822138"/>
<node TEXT="Accuracy" ID="ID_344219835" CREATED="1442915822667" MODIFIED="1442915826509"/>
<node TEXT="Stability" ID="ID_879661257" CREATED="1442915827002" MODIFIED="1442915862483"/>
</node>
<node TEXT="Conclusion" POSITION="right" ID="ID_335508516" CREATED="1344508153289" MODIFIED="1443465524036" DCR_PRIVACY_LEVEL="DEMO">
<edge COLOR="#00ffff" WIDTH="3"/>
<node TEXT="todo" ID="ID_183681093" CREATED="1344508158399" MODIFIED="1344508159274"/>
<node TEXT="Future Work" ID="ID_820680482" CREATED="1442915878153" MODIFIED="1442915885133"/>
</node>
<node LOCALIZED_STYLE_REF="defaultstyle.floating" POSITION="left" ID="ID_989309610" CREATED="1344498811808" MODIFIED="1443465524037" HGAP="-47" VSHIFT="-167" DCR_PRIVACY_LEVEL="DEMO"><richcontent TYPE="NODE">

<html>
  <head>
    
  </head>
  <body>
    <p>
      This is an example how a draft of your paper/assignemnt/thesis/book could look like.
    </p>
    <p>
      
    </p>
    <p>
      First, you create nodes for each of your (sub-) chapters such as introduction, related work, etc... Then, create nodes for each sentence you want to write. From your <i>Literature &amp; Annotations</i>&#160;Map you may copy PDFs and annotations you want to cite. In the right panel of Docear (the reference panel), create new references for the PDFs and annotations.
    </p>
  </body>
</html>
</richcontent>
</node>
<node TEXT="Potential Conferences to&#xa;publish the paper" POSITION="left" ID="ID_916121753" CREATED="1344511928953" MODIFIED="1443465524037" DCR_PRIVACY_LEVEL="DEMO">
<edge COLOR="#ff0000" WIDTH="3"/>
<node TEXT="WWW 2013" ID="ID_1266382435" CREATED="1344511967357" MODIFIED="1443465524037" LINK="http://www2013.org/" DCR_PRIVACY_LEVEL="DEMO"/>
<node TEXT="SIGIR 2013" ID="ID_196579720" CREATED="1344511986050" MODIFIED="1443465524037" LINK="http://sigir2013.ie/" DCR_PRIVACY_LEVEL="DEMO"/>
</node>
<node TEXT="todo" POSITION="left" ID="ID_156430450" CREATED="1344512008068" MODIFIED="1443465524038" DCR_PRIVACY_LEVEL="DEMO">
<edge COLOR="#0000ff" WIDTH="3"/>
<node TEXT="talk with supervisor" ID="ID_1086499639" CREATED="1344512010740" MODIFIED="1443465524038" DCR_PRIVACY_LEVEL="DEMO"/>
<node TEXT="ask John to proof-read" ID="ID_624499378" CREATED="1344512015939" MODIFIED="1443465524038" DCR_PRIVACY_LEVEL="DEMO"/>
</node>
<node TEXT="Related Work" POSITION="left" ID="ID_1699562627" CREATED="1344508140609" MODIFIED="1443465524038" DCR_PRIVACY_LEVEL="DEMO">
<edge COLOR="#0000ff" WIDTH="3"/>
<node TEXT="The idea of &quot;optimizing&quot; papers&#xa;for academic search engines&#xa;evolved in 2010" ID="ID_1404643820" CREATED="1344511282609" MODIFIED="1443465524038" DCR_PRIVACY_LEVEL="DEMO">
<node TEXT="ASEO, original paper" ID="ID_1636806351" CREATED="1344508031885" MODIFIED="1443465524038" LINK="project://14FD099F8F985QT959J90Z53U5ZUFPVWENJ2/literature_repository/Example%20PDFs/Academic%20Search%20Engine%20Optimization%20(ASEO)%20--%20Optimizing%20Scholarly%20Literature%20for%20Google%20Scholar%20and%20Co.pdf" DCR_PRIVACY_LEVEL="DEMO">
<pdf_annotation type="COMMENT" page="1" object_number="523"/>
<attribute NAME="year" VALUE="2010"/>
<attribute NAME="title" VALUE="{A}cademic {S}earch {E}ngine {O}ptimization ({ASEO}): {O}ptimizing {S}cholarly {L}iterature for {G}oogle {S}cholar and {C}o."/>
<attribute NAME="authors" VALUE="{J}oeran {B}eel and {B}ela {G}ipp and {E}rik {W}ilde"/>
<attribute NAME="journal" VALUE="Journal of Scholarly Publishing"/>
<attribute NAME="key" VALUE="Beel10"/>
</node>
</node>
<node TEXT="Feedback in the academic&#xa;community was diverse" ID="ID_1102967923" CREATED="1344511369742" MODIFIED="1443465524039" DCR_PRIVACY_LEVEL="DEMO">
<node TEXT="Pro" ID="ID_499059823" CREATED="1344509155557" MODIFIED="1443465524039" DCR_PRIVACY_LEVEL="DEMO">
<node TEXT="&#x201c;In my opinion, being interested in how (academic) &#xd;&#xa;search engines function and how scientific papers are &#xd;&#xa;indexed and, of course, responding to these&#x2026; well&#x2026; &#xd;&#xa;circumstances of the scientific citing business is just &#xd;&#xa;natural.&#x201d;" ID="ID_802523095" CREATED="1344508403924" MODIFIED="1344508403924" LINK="project://14FD099F8F985QT959J90Z53U5ZUFPVWENJ2/literature_repository/Example%20PDFs/Academic%20search%20engine%20spam%20and%20Google%20Scholars%20resilience%20against%20it.pdf">
<pdf_annotation type="HIGHLIGHTED_TEXT" page="3" object_number="746"/>
<attribute NAME="year" VALUE="2010"/>
<attribute NAME="title" VALUE="{A}cademic search engine spam and {G}oogle {S}cholar&apos;s resilience against it"/>
<attribute NAME="authors" VALUE="{J}oeran {B}eel and {B}ela {G}ipp"/>
<attribute NAME="journal" VALUE="Journal of Electronic Publishing"/>
<attribute NAME="key" VALUE="Beel2010"/>
</node>
<node TEXT="&#x201c;ASEO sounds good to me. I think it&#x2019;s a good idea.&#x201d; " ID="ID_635715426" CREATED="1344508403935" MODIFIED="1344508403935" LINK="project://14FD099F8F985QT959J90Z53U5ZUFPVWENJ2/literature_repository/Example%20PDFs/Academic%20search%20engine%20spam%20and%20Google%20Scholars%20resilience%20against%20it.pdf">
<pdf_annotation type="HIGHLIGHTED_TEXT" page="3" object_number="750"/>
<attribute NAME="year" VALUE="2010"/>
<attribute NAME="title" VALUE="{A}cademic search engine spam and {G}oogle {S}cholar&apos;s resilience against it"/>
<attribute NAME="authors" VALUE="{J}oeran {B}eel and {B}ela {G}ipp"/>
<attribute NAME="journal" VALUE="Journal of Electronic Publishing"/>
<attribute NAME="key" VALUE="Beel2010"/>
</node>
<node TEXT="&#x201c;Search engine optimization (SEO) has a golden age in &#xd;&#xa;this internet era, but to use it in academic research, it &#xd;&#xa;sounds quite strange for me. After reading this &#xd;&#xa;publication [&#x2026;] my opinion changed.&#x201d;" ID="ID_1945313483" CREATED="1344508403945" MODIFIED="1344508403945" LINK="project://14FD099F8F985QT959J90Z53U5ZUFPVWENJ2/literature_repository/Example%20PDFs/Academic%20search%20engine%20spam%20and%20Google%20Scholars%20resilience%20against%20it.pdf">
<pdf_annotation type="HIGHLIGHTED_TEXT" page="3" object_number="762"/>
<attribute NAME="year" VALUE="2010"/>
<attribute NAME="title" VALUE="{A}cademic search engine spam and {G}oogle {S}cholar&apos;s resilience against it"/>
<attribute NAME="authors" VALUE="{J}oeran {B}eel and {B}ela {G}ipp"/>
<attribute NAME="journal" VALUE="Journal of Electronic Publishing"/>
<attribute NAME="key" VALUE="Beel2010"/>
</node>
</node>
<node TEXT="Con" ID="ID_715816383" CREATED="1344509156803" MODIFIED="1443465524042" DCR_PRIVACY_LEVEL="DEMO" VSHIFT="10">
<node TEXT="&#x201c;I&#x2019;m not a big fan of this area of research [&#x2026;]. I know &#xd;&#xa;it&#x2019;s in the call for papers, but I think that&#x2019;s a mistake.&#x201d; " ID="ID_1002287656" CREATED="1344508032014" MODIFIED="1443465524042" LINK="project://14FD099F8F985QT959J90Z53U5ZUFPVWENJ2/literature_repository/Example%20PDFs/Academic%20search%20engine%20spam%20and%20Google%20Scholars%20resilience%20against%20it.pdf" DCR_PRIVACY_LEVEL="DEMO">
<pdf_annotation type="HIGHLIGHTED_TEXT" page="3" object_number="662"/>
<attribute NAME="year" VALUE="2010"/>
<attribute NAME="title" VALUE="{A}cademic search engine spam and {G}oogle {S}cholar&apos;s resilience against it"/>
<attribute NAME="authors" VALUE="{J}oeran {B}eel and {B}ela {G}ipp"/>
<attribute NAME="journal" VALUE="Journal of Electronic Publishing"/>
<attribute NAME="key" VALUE="Beel2010"/>
</node>
<node TEXT="Motivation why researchers might do academic search engine spam" ID="ID_83902833" CREATED="1344508032022" MODIFIED="1443465524043" LINK="project://14FD099F8F985QT959J90Z53U5ZUFPVWENJ2/literature_repository/Example%20PDFs/Academic%20search%20engine%20spam%20and%20Google%20Scholars%20resilience%20against%20it.pdf" DCR_PRIVACY_LEVEL="DEMO">
<pdf_annotation type="HIGHLIGHTED_TEXT" page="3" object_id="1334231183826421543" object_number="666"/>
<attribute NAME="year" VALUE="2010"/>
<attribute NAME="title" VALUE="{A}cademic search engine spam and {G}oogle {S}cholar&apos;s resilience against it"/>
<attribute NAME="authors" VALUE="{J}oeran {B}eel and {B}ela {G}ipp"/>
<attribute NAME="journal" VALUE="Journal of Electronic Publishing"/>
<attribute NAME="key" VALUE="Beel2010"/>
</node>
<node TEXT="&#x201c;In my opinion, being interested in how (academic) &#xd;&#xa;search engines function and how scientific papers are &#xd;&#xa;indexed and, of course, responding to these&#x2026; well&#x2026; &#xd;&#xa;circumstances of the scientific citing business is just &#xd;&#xa;natural.&#x201d;" ID="ID_1563404825" CREATED="1344508032030" MODIFIED="1443465524044" LINK="project://14FD099F8F985QT959J90Z53U5ZUFPVWENJ2/literature_repository/Example%20PDFs/Academic%20search%20engine%20spam%20and%20Google%20Scholars%20resilience%20against%20it.pdf" DCR_PRIVACY_LEVEL="DEMO">
<pdf_annotation type="HIGHLIGHTED_TEXT" page="4" object_id="4694565655893184301" object_number="670"/>
<attribute NAME="year" VALUE="2010"/>
<attribute NAME="title" VALUE="{A}cademic search engine spam and {G}oogle {S}cholar&apos;s resilience against it"/>
<attribute NAME="authors" VALUE="{J}oeran {B}eel and {B}ela {G}ipp"/>
<attribute NAME="journal" VALUE="Journal of Electronic Publishing"/>
<attribute NAME="key" VALUE="Beel2010"/>
</node>
</node>
</node>
<node TEXT="{and so on...}" ID="ID_825000868" CREATED="1344511414252" MODIFIED="1443465524044" DCR_PRIVACY_LEVEL="DEMO"/>
</node>
</node>
</map>

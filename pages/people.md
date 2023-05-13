---
title: People
skiph1fortitle: true
permalink: /people/
---

<script type="text/javascript">

// convert Apache IDs for committers into links to their Apache profile on people.apache.org
$(function() {
  $('table.committers tbody tr td:first-child').each(function(i, obj) {
    var apacheid = $(obj).text();
    $(obj).html('<a href="https://people.apache.org/phonebook.html?uid=' + apacheid + '">' + apacheid + '</a>');
  });
});

</script>

## Committers and Current PMC Members

{: .table .table-striped .committers #pmc}
| apache id     | name                                              | organization                           | timezone |
|---------------|---------------------------------------------------|----------------------------------------|----------|
| acordova      | Aaron Cordova                                     | [Koverse][KOVERSE]                     |          |
| adamjshook    | Adam J. Shook                                     | [Datacatessen][DATACATESS]             | [ET][ET] |
| afuchs        | Adam Fuchs                                        | [sqrrl][SQRRL]                         | [ET][ET] |
| alerman       | Adam Lerman                                       | [Applied Technology Group][ATG]        | [ET][ET] |
| bhavanki      | Bill Havanki                                      | [Cloudera][CLOUDERA]                   | [ET][ET] |
| billie        | Billie Rinaldi                                    | [Microsoft][MICROSOFT]                 | [ET][ET] |
| bimargulies   | Benson Margulies                                  | [Basis Technology Corp.][BASISTECH]    | [ET][ET] |
| brianloss     | [Brian Loss](https://github.com/brianloss)        | [Microsoft][MICROSOFT]                 | [ET][ET] |
| busbey        | Sean Busbey                                       | [Cloudera][CLOUDERA]                   | [CT][CT] |
| cawaring      | Chris Waring                                      |                                        |          |
| cjnolet       | Corey J. Nolet                                    | [Tetra Concepts LLC][TETRA]            | [ET][ET] |
| ctubbsii      | [Christopher Tubbs](https://github.com/ctubbsii)  | [NSA][NSA]                             | [ET][ET] |
| dlmarion      | Dave Marion                                       | [Wrench.io, LLC][WRENCH]               | [ET][ET] |
| domgarguilo   | [Dominic Garguilo](https://github.com/DomGarguilo)| [Arctic Slope Regional Corp.][ASRC]    | [ET][ET] |
| drew          | Drew Farris                                       | [Booz Allen Hamilton][BOOZ]            | [ET][ET] |
| ecn           | Eric Newton                                       | [SW Complete Inc.][SWC]                | [ET][ET] |
| edcoleman     | Ed Coleman                                        |                                        | [ET][ET] |
| elserj        | Josh Elser                                        | [Hortonworks][HORTONWORKS]             | [ET][ET] |
| hkeebler      | Holly Keebler                                     | [Arctic Slope Regional Corp.][ASRC]    | [ET][ET] |
| ibella        | Ivan Bella                                        | [Arctic Slope Regional Corp.][ASRC]    | [ET][ET] |
| jmanno        | [Jeffrey Manno](https://github.com/Manno15)       | [Arctic Slope Regional Corp.][ASRC]    | [ET][ET] |
| jmark99       | [Mark Owens](https://github.com/jmark99)          |                                        | [ET][ET] |
| jtrost        | Jason Trost                                       | [Endgame][ENDGAME]                     |          |
| kturner       | [Keith Turner](https://github.com/keith-turner)   | [Wrench.io, LLC][WRENCH]               | [ET][ET] |
| lstavarez     | [Luis Tavarez](https://github.com/lstav)          |                                        | [ET][ET] |
| mdrob         | Mike Drob                                         | [Cloudera][CLOUDERA]                   | [ET][ET] |
| mjwall        | Michael Wall                                      | [Arctic Slope Regional Corp.][ASRC]    | [ET][ET] |
| mmiller       | [Michael Miller](https://github.com/milleruntime) | [Centroid, LLC][CENTROID]              | [ET][ET] |
| mwalch        | [Mike Walch](https://github.com/mikewalch)        | [Peterson Technologies][PETERSON]      | [ET][ET] |
| ngf           | [Nick Felts](https://github.com/pircdef)          | [Praxis Engineering][PRAXIS]           | [ET][ET] |
| phrocker      | [Marc Parisi](https://github.com/phrocker/)       | [Microsoft][MICROSOFT]                 | [ET][ET] |
| rweeks        | Russ Weeks                                        | [PHEMI][PHEMI]                         | [PT][PT] |
| shickey       | Sean Hickey                                       |                                        | [PT][PT] |
| shutchis      | Shana Hutchison                                   | [University of Washington][UW]         | [PT][PT] |
| ujustgotbilld | William Slacum                                    | [Miner &amp; Kasch][MINERKASCH]        | [ET][ET] |
| vikrams       | Vikram Srivastava                                 | [Cloudera][CLOUDERA]                   | [PT][PT] |
| vines         | John Vines                                        | [sqrrl][SQRRL]                         | [ET][ET] |

## Committers Only (PMC Emeritus)

{: .table .table-striped .committers #pmc-emeritus}
| apache id     | name                                              | organization                           | timezone |
|---------------|---------------------------------------------------|----------------------------------------|----------|
| arvindsh      | Arvind Shyamsundar                                | [Microsoft][MICROSOFT]                 | [PT][PT] |
| knarendran    | Karthick Narendran                                | [Microsoft][MICROSOFT]                 |[BST][BST]|
| medined       | David Medinets                                    |                                        |          |

## Contributors

GitHub also has a [contributor list][github-contributors] based on commits.

{: .table .table-striped #contributors}
| name                | organization                                                      | timezone              |
|---------------------|-------------------------------------------------------------------|-----------------------|
| Aaron Glahe         | [Data Tactics][DATATACT]                                          | [ET][ET]              |
| Aishwarya Thangappa | [Microsoft][MICROSOFT]                                            | [PT][PT]              |
| Akshit Mangotra     |                                                                   | [IST][IST-India]      |
| Al Krinker          |                                                                   | [ET][ET]              |
| Alex Moundalexis    | [Cloudera][CLOUDERA]                                              | [ET][ET]              |
| Ali Mustafa         | [FAST-NU][FAST-NU]                                                | [PKT][PKT]            |
| Amisha Sahu         |                                                                   | [IST][IST-India]      |
| Andrew George Wells | [ClearEdgeIT][CLEAREDGE]                                          | [ET][ET]              |
| Arshak Navruzyan    | [Argyle Data][ARGYLE]                                             |                       |
| Ben Kelly           | [Microsoft][MICROSOFT]                                            | [GMT][GMT]/[IST][IST-Ireland] |
| Ben Manes           |                                                                   | [PT][PT]              |
| Benjamin Fach       |                                                                   |                       |
| Bob Thorman         | [AT&amp;T][ATT]                                                   |                       |
| Charles Williams    | [Tiber Technologies][TIBER]                                       | [ET][ET]              |
| Chris Bennight      |                                                                   |                       |
| Chris McCubbin      | [sqrrl][SQRRL]                                                    | [ET][ET]              |
| Chris McTague       | [Peterson Technologies][PETERSON]                                 | [ET][ET]              |
| Christian Rohling   | [Endgame][ENDGAME]                                                | [ET][ET]              |
| Craig Scheiderer    | [Arctic Slope Regional Corp.][ASRC]                               | [ET][ET]              |
| Damon Brown         | [Tetra Concepts LLC][TETRA]                                       | [ET][ET]              |
| Dane Magbuhos       |                                                                   | [ET][ET]              |
| Daniel Roberts      | [Sentinel Solutions][SENTINEL]                                    | [ET][ET]              |
| Dave Wang           | [Cloudera][CLOUDERA]                                              | [PT][PT]              |
| David M. Lyle       |                                                                   |                       |
| David Protzman      |                                                                   |                       |
| Dennis Patrone      | [The Johns Hopkins University Applied Physics Laboratory][JHUAPL] | [ET][ET]              |
| Dima Spivak         | [Cloudera][CLOUDERA]                                              |                       |
| Ed Kohlwey          | [Booz Allen Hamilton][BOOZ]                                       |                       |
| Ed Seidl            | [Lawrence Livermore National Laboratory][LLNL]                    | [PT][PT]              |
| Edward Yoon         |                                                                   |                       |
| Elina Wise          | [Arctic Slope Regional Corp.][ASRC]                               | [ET][ET]              |
| Eugene Cheipesh     |                                                                   |                       |
| Filipe Rodrigues    |                                                                   | [GMT][GMT]            |
| Gary Singh          | [Sabre Engineering][SABRE]                                        | [ET][ET]              |
| Harjit Singh        |                                                                   | [ET][ET]              |
| Hasan Gürcan        |                                                                   | [CEST][CEST]          |
| Hayden Marchant     |                                                                   |                       |
| Hung Pham           | [Cloudera][CLOUDERA]                                              | [ET][ET]              |
| Jacob Meisler       | [Booz Allen Hamilton][BOOZ]                                       | [ET][ET]              |
| James Fiori         | [Flywheel Data][FLYWHEEL]                                         | [ET][ET]              |
| Jared R.            |                                                                   |                       |
| Jared Winick        | [Koverse][KOVERSE]                                                | [MT][MT]              |
| Jason Then          |                                                                   |                       |
| Jay Shipper         |                                                                   |                       |
| Jeff Field          | [Cloudera][CLOUDERA]                                              | [ET][ET]              |
| Jeffrey S. Schwartz |                                                                   |                       |
| Jeffrey Zeiberg     | [Arctic Slope Regional Corp.][ASRC]                               | [ET][ET]              |
| Jenna Huston        |                                                                   | [ET][ET]              |
| Jerry He            | [IBM][IBM]                                                        | [PT][PT]              |
| Jesse Yates         |                                                                   |                       |
| Jessica Seastrom    | [Cloudera][CLOUDERA]                                              | [ET][ET]              |
| Jim Klucar          | [Splyt][SPLYT]                                                    | [ET][ET]              |
| Joe Skora           |                                                                   |                       |
| John McNamee        |                                                                   |                       |
| John Stoneham       |                                                                   | [ET][ET]              |
| Jonathan M. Hsieh   | [Cloudera][CLOUDERA]                                              | [PT][PT]              |
| Jonathan Park       | [sqrrl][SQRRL]                                                    | [ET][ET]              |
| Joseph Koshakow     |                                                                   | [ET][ET]              |
| Josselin Chevalay   |                                                                   | [CEST][CEST]          |
| Kartik Sethi        |                                                                   | [IST][IST-India]      |
| Kenneth McFarland   |                                                                   | [PT][PT]              |
| Kevin Faro          | [Tetra Concepts LLC][TETRA]                                       | [ET][ET]              |
| Kyle Van Gilson     |                                                                   |                       |
| Kylian Meulin       |                                                                   | [GMT][GMT]/[BST][BST] |
| Laura Peaslee       | [Objective Solutions, Inc.][OBJECTIVE]                            | [ET][ET]              |
| Laura Schanno       | [Arctic Slope Regional Corp.][ASRC]                               | [ET][ET]              |
| Luke Brassard       | [sqrrl][SQRRL]                                                    | [ET][ET]              |
| Luke Foster         | [Arctic Slope Regional Corp.][ASRC]                               | [ET][ET]              |
| Mandar Inamdar      | [Microsoft][MICROSOFT]                                            | [PT][PT]              |
| Mario Pastorelli    | [Teralytics AG][TERALYTICS]                                       | [CEST][CEST]          |
| Markus Cozowicz     | [Microsoft][MICROSOFT]                                            | [CET][CEST]           |
| Matt Dailey         |                                                                   |                       |
| Matthew Boehm       | [Novetta][NOVETTA]                                                | [ET][ET]              |
| Matthew Dinep       | [Anavation, LLC] [ANAVATION]                                      | [ET][ET]              |
| Matthew Kirkley     |                                                                   |                       |
| Matthew Peterson    | [Applied Technology Group][ATG]                                   | [ET][ET]              |
| Max Jordan          |                                                                   |                       |
| Michael Allen       | [sqrrl][SQRRL]                                                    | [ET][ET]              |
| Michael Berman      | [sqrrl][SQRRL]                                                    | [ET][ET]              |
| Miguel Pereira      | [SRA International, Inc][SRA]                                     | [ET][ET]              |
| Mike Fagan          | [Arcus Research][ARCUS]                                           | [MT][MT]              |
| Morgan Haskel       |                                                                   |                       |
| Nguessan Kouame     |                                                                   |                       |
| Nicolás Alarcón R.  |                                                                   | [CEST][CEST]          |
| Nikita Sirohi.      | [Ghost Locomotion][GHOST]                                         | [PT][PT]              |
| Oren Falkowitz      | [sqrrl][SQRRL]                                                    | [ET][ET]              |
| Phil Eberhardt      | [sqrrl][SQRRL]                                                    | [ET][ET]              |
| Philip Young        |                                                                   |                       |
| Pushpinder Heer     | [Applied Technical Systems][ATSID]                                | [PT][PT]              |
| Ravi Mutyala        | [Hortonworks][HORTONWORKS]                                        | [CT][CT]              |
| Richard Eggert II   | [MasterPeace Solutions, Ltd][MASTERPEACE]                         | [ET][ET]              |
| Russell Carter Jr   | [Arctic Slope Regional Corp.][ASRC]                               | [ET][ET]              |
| Ryan Fishel         | [Cloudera][CLOUDERA]                                              |                       |
| Ryan Leary          |                                                                   |                       |
| Sapah Shah          |                                                                   |                       |
| Scott Kuehn         |                                                                   |                       |
| Seth Falco          | [Elypia][ELYPIA]                                                  | [GMT][GMT]/[BST][BST] |
| Shawn Walker        |                                                                   |                       |
| Shivakumar Gangamath|                                                                   | [IST][IST-India]      |
| Steve Loughran      | [Hortonworks][HORTONWORKS]                                        | [GMT][GMT]/[BST][BST] |
| Supun Kamburugamuva |                                                                   |                       |
| Swastik Pal         |                                                                   | [IST][IST-India]      |
| Szabolcs Bukros     | [Cloudera][CLOUDERA]                                              | [CEST][CEST]          |
| Takahiko Saito      | [Hortonworks][HORTONWORKS]                                        | [PT][PT]              |
| Tao Xiao            | [Nara Institute of Science and Technology][NAIST]                 |                       |
| Ted Malaska         | [Cloudera][CLOUDERA]                                              |                       |
| Ted Yu              | [Hortonworks][HORTONWORKS]                                        | [PT][PT]              |
| Tim Halloran        |                                                                   |                       |
| Tim Reardon         |                                                                   |                       |
| Toshihiro Suzuki    | [Hortonworks][HORTONWORKS]                                        | [JST][JST]            |
| Travis Pinney       |                                                                   |                       |
| Trent Nadeau        | [Anthem Engineering LLC][ANTHEMENG]                               | [ET][ET]              |
| Tristen Georgiou    | [PHEMI][PHEMI]                                                    | [PT][PT]              |
| Tushar Dhadiwal     | [Microsoft][MICROSOFT]                                            | [PT][PT]              |
| Umang goyal         |                                                                   | [GMT][GMT]            |
| Vicky Kak           |                                                                   |                       |
| Vincent Russell     |                                                                   |                       |
| Volth               |                                                                   |                       |
| Wil Selwood         | [Satellite Applications Catapult][SACAT]                          | [GMT][GMT]/[BST][BST] |
| Xiao Wang           | [Stevens Institute of Technology][SIT]                            | [ET][ET]              |

[github-contributors]: https://github.com/apache/accumulo/graphs/contributors
[ANAVATION]: https://www.anavationllc.com
[ANTHEMENG]: https://www.anthemengineering.com
[ARCUS]: http://www.arcus-research.com
[ARGYLE]: https://mavenir.com
[ASRC]: https://www.asrc.com
[ATG]: https://www.atg-us.com
[ATSID]: https://www.atsid.com
[ATT]: https://www.att.com
[BASISTECH]: https://www.basistech.com
[BOOZ]: https://www.boozallen.com
[CENTROID]: http://www.centroid-llc.com
[CLEAREDGE]: http://clearedgeit.com
[CLOUDERA]: https://www.cloudera.com
[DATATACT]: https://www.data-tactics.com
[DATACATESS]: https://datacatessen.com
[ELYPIA]: https://elypia.org
[ENDGAME]: https://www.endgame.com
[FAST-NU]: https://nu.edu.pk/
[FLYWHEEL]: https://flywheeldata.com
[GHOST]: https://www.driveghost.com/
[HORTONWORKS]: https://hortonworks.com
[IBM]: https://www.ibm.com
[JHUAPL]: https://www.jhuapl.edu
[KOVERSE]: https://www.koverse.com
[LLNL]: https://www.llnl.gov
[MASTERPEACE]: https://www.masterpeaceltd.com
[MICROSOFT]: https://www.microsoft.com
[MINERKASCH]: https://minerkasch.com
[NAIST]: https://www.naist.jp
[NOVETTA]: https://www.novetta.com
[NSA]: https://www.nsa.gov
[OBJECTIVE]: http://www.objectivesolutions.com
[PETERSON]: https://www.ptech-llc.com
[PHEMI]: https://www.phemi.com
[PRAXIS]: https://www.praxiseng.com
[SABRE]: https://www.sabre-eng.com
[SACAT]: https://sa.catapult.org.uk
[SENTINEL]: https://sentinel-corp.com
[SIT]: https://www.stevens.edu
[SPLYT]: https://www.splyt.com
[SQRRL]: http://sqrrl.com
[SRA]: https://sra.com
[SWC]: http://swcomplete.com
[TERALYTICS]: https://www.teralytics.net
[TETRA]: http://www.tetraconcepts.com
[TIBER]: https://www.tibertechnologies.com
[UW]: https://www.washington.edu
[WAVE]: https://www.wavestrike.com
[WRENCH]: https://wrench.io
[BST]: https://www.timeanddate.com/time/zones/bst
[IST-Ireland]: https://www.timeanddate.com/time/zones/ist-ireland
[IST-India]: https://www.timeanddate.com/time/zones/ist
[CT]: https://www.timeanddate.com/time/zones/ct
[ET]: https://www.timeanddate.com/time/zones/et
[GMT]: https://www.timeanddate.com/time/zones/gmt
[JST]: https://www.timeanddate.com/time/zones/jst
[MT]: https://www.timeanddate.com/time/zones/mt
[PT]: https://www.timeanddate.com/time/zones/pt
[PKT]: https://www.timeanddate.com/time/zones/pkt
[CEST]: https://www.timeanddate.com/time/zones/cest

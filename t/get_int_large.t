use warnings;
use strict;

use IO::File 1.03;
use Test::More;

BEGIN {
	eval "use Math::BigInt 1.16; 1" or
		plan skip_all => "Math::BigInt unavailable";
	plan tests => 247;
	use_ok "Data::Entropy::Source";
}

sub match($$) {
	my($a, $b) = @_;
	ok ref($a) eq ref($b) && $a == $b;
}

my $rawsource = IO::File->new("t/test0.entropy", "r") or die $!;
my $source = Data::Entropy::Source->new($rawsource, "getc");
ok $source;

my $limit = Math::BigInt->new("100000000000000000000");

while(<DATA>) {
	while(/([0-9]+)/g) {
		match $source->get_int($limit), Math::BigInt->new($1);
	}
}

eval { $source->get_int($limit); };
like $@, qr/\Aentropy source failed:/;

1;

__DATA__
68807314153453845935 44895925609758693014 91684367776668160563
56108518278522687113 28217278430494290576 71738743512311479074
74386544180255394792 39152281477817113805 90921893246479465065
82620448454531421388 44674519163021046525 84527795945300210520
34360252122495692115 38978214527762911353 79479987427485544715
12061931143224927321 53948765087340844500 80659296157555878729
78427179399174651950 91564990700810876914 61342958431468667976
63611026805453161344 27646495397604287489 00034572888809883207
85168650371487971070 90371971159857598709 88818527526349480067
26775678824341118026 59032056402338073720 55462451824035966722
07313987564148499208 29941741811947925551 19698459122094476687
95965855528171861688 46801408546928950021 86349868852075929586
65884805502039127761 24011972741068099116 46438345741891069952
48962147346469659554 31137929085322331468 51088695252392042559
62111475236908116455 33463759797132938008 60516479594089532156
33153680803275729513 09999846550164285049 39017997357351128052
80212810570948548687 04262634128232560216 50140647929376125828
96574694046705193080 07040560031874804308 24258363245774282419
71471662629467815110 49437923576492715332 55058175860685540074
12846166997005333292 20693135055196364770 89473660071366603152
86469071389269047305 26303669611864172068 03221269039267734628
77726674462648053710 57005471491899352550 41219655921244258125
00801655329590315421 35576795184082404367 57045358926108523714
79846810841985095414 54407749130308074368 25653368142908401284
08267883912107871790 19754828580754260851 85090338542803312570
36074938454109899070 69946250433522132666 21610357886296152047
33488965053531919669 43156795256455969145 20074654346905564719
79660170206891953808 94149942094182178679 75008749428533877607
70473095903946178049 03902494325911994548 79942577976886892718
52628871005128785266 85640465982952951687 25140630167931185650
35630717598308274202 09663785067193830508 57547354560312618023
93965290978176460029 21939177556150699945 03773668137237874900
83472822072734266111 29731260313142613537 50621483796171365483
67697611038185924065 82549488594723957545 18614556152846026501
99491565705555148746 37363920498848981891 10949849474217815928
82196394619727250167 90206959446074605330 56789037574258475207
57461082735383694794 42366233589642549924 71986828249420716985
06991946634602238484 33441931782992921216 54584255734386026055
28648683552806701369 30290309465037832593 43421916825287049781
89200121566754187298 13867647509695377249 09173347412574930269
40003120694067005875 97042986570022146480 93493188850632604624
49124984638990436353 85370097156995545903 15945414967840631600
44960943609493951043 10162356268605852426 88525955758594785038
31083320073257277346 62493860405915502540 92028970495339968115
80952524770920132646 14905693078164272021 54129616975574447463
73780099789634112463 46307164593589429069 95917326470443518964
14724791359651790950 27595220768178538858 94510046091262749701
81349930885091175438 46694358491790938069 22244358987843084214
61232890123547346761 44731597159561704867 05365709638564507709
39402574383718101925 71211368207488855611 85214867094020109556
06653145581681719444 51593968376850748621 57332903848184882190
22052834412780887471 04660896538088728881 69490593048647220589
59376066160051311030 26916665394309497466 16803090027627283871
43344392660095770101 32646125261499604784 17200770289564557408
30553986827513722926 27724395140717228061 91464803605477549377
00612111360565250445 37082906571446523989 88426241033288029715
85952217976590579950 36566048619724809570 63141616431619684107
87548910289942597556 65526088007718624691 94546633892238650037
06151881184928662588 53292223309649484946 51783205341280869401
98594627460818553276 62706292981184027563 67127627005270333099
15744062556742880129 87149347252626071716 87717706458381160296
38291706278626514067 95827541706351284513 84099316911158992562
04373915129901845407 68612370917252865435 62508341540772317201
38341768834024444111 15916951675693085110 35124415011661531896
16889296524695350827 90819455882275719380 45065382441477748821
45949493127741935634 61715704009670727327 07119763096213251409
68380623393154121862 05648605487339569454 41923639712077771751
97915315004824671435 74202012898260651208 12705404669739573150
61430341975793848171 45931661096558312394 75325495248192472015
59424779856860133197 05334744136392726468 81289841442388651981
68515173002443450333 38870330010376248602 26751954380436285854
82617134535587544340 18274864626573081665 28885906364737388191
50123636306207006572 42016248190569842031 45760608701501200881
60006013919672679398 56276492380243298235 15429638056844051017
21626233344529880347 92912095005463580898 99328902294729458610
58469170268727239803 77759666402160008238 70060507775763978183
28960137422705695570 43565280534655204736 87983599600588320707
54700428907543468237 46630125163141418516 08888321193198622038
82684571311960555047 67621436026410391087 86804523169383033505
92435618454545030034 12821221455328241210 33803364632315414473
97081561038207543710 47035265564884172172 42941246301036928887
1829428254474718444

use warnings;
use strict;

use Test::More tests => 1 + (500 + 1)*3;

use IO::File 1.03;
my $have_bigint = eval("use Math::BigInt 1.16; 1");
my $have_bigrat = eval("use Math::BigRat 0.04; 1");

BEGIN { use_ok "Data::Entropy::Source"; }

sub match($$) {
	my($a, $b) = @_;
	ok ref($a) eq ref($b) && $a == $b;
}

my $rawsource = IO::File->new("t/test0.entropy", "r") or die $!;
my $source0 = Data::Entropy::Source->new($rawsource, "getc");
ok $source0;
$rawsource = IO::File->new("t/test0.entropy", "r") or die $!;
my $source1 = Data::Entropy::Source->new($rawsource, "getc");
ok $source1;
$rawsource = IO::File->new("t/test0.entropy", "r") or die $!;
my $source2 = Data::Entropy::Source->new($rawsource, "getc");
ok $source2;

my $bigint_thousand = $have_bigint && Math::BigInt->new(1000);
my $bigrat_thousand = $have_bigrat && Math::BigRat->new(1000);

while(<DATA>) {
	while(/([0-9]+)/g) {
		my $val = 0 + $1;
		my $tval = $source0->get_int(1000);
		match $tval, $val;
		SKIP: {
			skip "Math::BigInt unavailable", 1 unless $have_bigint;
			$tval = $source1->get_int($bigint_thousand);
			match $tval, Math::BigInt->new($val);
		}
		SKIP: {
			skip "Math::BigRat unavailable", 1 unless $have_bigrat;
			$tval = $source2->get_int($bigrat_thousand);
			match $tval, Math::BigRat->new($val);
		}
	}
}

1;

__DATA__
698 484 175 923 914 765 687 623 350 789 040 519 150 248 926 334 624 403 402 563
266 681 128 025 731 932 137 135 489 059 033 231 400 227 933 882 740 303 059 823
008 594 023 720 006 523 232 543 874 656 854 101 867 819 372 949 718 634 105 267
884 406 204 032 894 276 460 107 507 778 167 576 985 661 527 270 887 338 435 088
949 547 926 714 055 595 284 238 111 250 583 592 969 079 257 163 118 457 497 011
167 968 932 201 782 492 688 132 259 669 868 212 564 790 351 385 949 293 235 064
968 080 035 675 128 046 758 305 951 992 455 754 398 913 333 687 891 062 324 626
888 451 474 858 898 783 639 021 872 950 228 001 000 960 920 731 961 582 071 896
468 789 031 763 925 742 926 700 107 296 144 245 805 666 951 968 080 160 925 627
955 262 496 205 864 307 315 510 350 877 836 814 690 310 020 900 559 279 613 990
888 316 035 264 415 390 394 305 904 752 365 894 350 508 098 952 950 934 715 999
039 877 758 696 797 932 989 283 483 161 005 174 344 092 065 888 824 658 782 217
012 446 804 209 059 169 508 691 270 044 368 132 549 105 863 304 256 341 167 124
153 602 424 419 816 032 037 947 753 868 588 799 385 167 525 259 063 413 093 504
927 805 609 898 720 359 040 060 027 851 919 071 441 655 654 737 912 063 460 537
520 952 239 234 954 710 899 628 245 294 633 541 838 478 716 011 244 089 557 038
133 278 536 793 977 235 953 706 054 600 727 605 674 414 691 132 020 574 655 401
229 528 894 355 097 437 011 743 693 825 592 782 260 472 452 414 179 623 734 346
947 519 636 710 174 457 399 569 493 856 508 277 572 269 948 522 582 959 722 101
473 044 891 543 953 434 983 297 779 729 906 075 924 731 433 400 979 779 987 587
907 056 521 932 009 038 560 890 166 556 975 063 287 356 830 303 054 817 841 310
144 303 279 817 542 587 081 101 230 572 674 171 341 663 886 747 927 900 070 352
647 137 936 186 964 185 271 324 527 535 723 180 571 091 194 477 084 877 362 012
596 662 499 015 295 145 660 443 640 515 530 360 096 422 644 626 917 989 745 091
302 464 530 858 493 186 873 115 412 668 847 165 389 442 500 675 237 267 574 297

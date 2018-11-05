#!/usr/bin/perl -w

use strict;
my $template = "Templates/single-eqn.tex";
my $temptex = "temp";
die "temptex already exists!" if -e "$temptex.tex";

open my $fh_template, $template || die "can't find template $template";
my @template = <$fh_template>;
close $fh_template;

my $eqnnumber = 0;

open my $fh_input, $ARGV[0] || die "can't find input file '$ARGV[0]'";
while(<$fh_input>)
{
	open my $fh_output, ">$temptex.tex" || die "can't open output file $temptex.tex";
	foreach my $line (@template)
	{
		if($line =~ /%%equation%%/)
		{
			print $fh_output $_;
		}
		else
		{
			print $fh_output $line;
		}
	}
	close $fh_output;

	# now run pdflatex and imagemagick
	system("pdflatex $temptex.tex");
	system("convert -density 600 $temptex.pdf -flatten -trim $ARGV[0]-$eqnnumber.png");
	$eqnnumber += 1;
}
unlink "$temptex.tex";
			

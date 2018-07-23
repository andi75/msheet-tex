#!/usr/bin/perl -W

use strict;

sub readDat {
	my $infile = shift;
	open(my $ifh, $infile) || die "can't open $infile";

	my %map = ();
	my @list = ();
	my %dat = ( "map" => \%map, "list" => \@list );
	while(<$ifh>)
	{
		chomp();
		if(/(\w+)=(.+)/)
		{
			my $key = $1;
			my $value = $2;
			# print $key . " -> " . $value . "\n";
			$dat{"map"}{$key} = $value;
		}
		else
		{
			push $dat{"list"}, $_;
		}
	}
	close($ifh);

	return %dat;
}

sub printHash
{
	my $hashref = shift;
	for my $key (keys %$hashref)
	{
		print "$key => $$hashref{$key}\n";
	}
}

my $filename = shift @ARGV;
my $infile = $filename . ".dat";
my $outfile = $filename . ".tex";
open(my $ofh, ">$outfile") || die "can't open $outfile for writing";
select($ofh);

my %sheet = readDat($infile);

my @problems = ();
for my $problem (@{$sheet{"list"}})
{
	my %p = readDat("Aufgaben/" . $problem . ".dat");
	push @problems, \%p;
}

# %sheet contains the meta data
my %maphash = %{$sheet{"map"}};
# @problems contains each problem

open(my $tfh, "template.tex") || die "no document template";
while(<$tfh>)
{
	while(/%%(\w+)%%/g)
	{
		my $token = $1;
		if($token eq "Problems")
		{
			for my $pref (@problems)
			{
				my %phash = %{$pref};
				my %pmhash = %{$phash{"map"}};
				my @plist = @{$phash{"list"}};

				open(my $pfh, "problem.tex") || die "no problem template";
				while(<$pfh>)
				{
					while(/%%(\w+)%%/g)
					{
						my $token = $1;
						if($token eq "Tasks")
						{
							# print tasks
							for my $task (@plist)
							{
								print "\\task $task\n";
							}
							$_ = "";
						}
						else
						{
							s/%%$token%%/$pmhash{$token}/;
						}
					}
					print;
				}
				close($pfh);
			}		
			$_ = "";
		}
		else
		{
			# print("replacing $token with " . $maphash{$token} . "\n");
			s/%%$token%%/$maphash{$token}/;
		}
	}
	print;
}

close($tfh);

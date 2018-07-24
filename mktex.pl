#!/usr/bin/perl -W

use strict;

sub readDat { my $infile = shift;
	open(my $ifh, $infile) || die "can't open $infile";

	my %map = ();
	my @list = ();
	my %dat = ( "map" => \%map, "list" => \@list );
	while(<$ifh>)
	{
		next if(/^#/);
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
	if($problem =~ /^%%(\w+)%%(.*)/)
	{
		my %p = ( "command" => $1, "param" => $2 );		
		push @problems, \%p;
	}
	else
	{
		my %p = readDat("Aufgaben/" . $problem . ".dat");
		push @problems, \%p;
	}
}

# %sheet contains the meta data
my %maphash = %{$sheet{"map"}};
# @problems contains each problem

my $nodesc = 0;

my $template = "template.tex";
if(defined $maphash{"Template"})
{
	$template = $maphash{"Template"};
}
open(my $tfh, "Templates/$template") || die "no document template";
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
				if(defined $phash{"command"})
				{
					my $cmd = $phash{"command"};
					if($cmd eq "pagebreak")
					{
						print "\\newpage\n";
					}
					elsif($cmd eq "desc")
					{
						print $phash{"param"}. "\n\n";
					}
					elsif($cmd eq "nodesc")
					{
						$nodesc = 1;
					}
				}
				else
				{
					my %pmhash = %{$phash{"map"}};
					my @plist = @{$phash{"list"}};

					open(my $pfh, "Templates/problem.tex") || die "no problem template";
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
								if($token eq "Description" && $nodesc == 1)
								{
									$_ = "\$ \$\n";
								}
							}
						}
						print;
					}
					close($pfh);
				}
			}		
			$_ = "";
		}
		else
		{
			# print("replacing $token with " . $maphash{$token} . "\n");
			if(defined $maphash{$token})
			{
				s/%%$token%%/$maphash{$token}/;
			}
			else
			{
				$_ = "";
			}
		}
	}
	print;
}

close($tfh);

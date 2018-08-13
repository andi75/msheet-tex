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
		if(/([\w\-]+)=(.+)/)
		{
			my $key = $1;
			my $value = $2;
			print STDERR $key . " -> " . $value . "\n";
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

my $arg = shift @ARGV;
my $lang = "";
my $filename = $arg;

if($arg =~ /--lang=(\w+)/)
{
	$lang = $1;
	$filename = shift @ARGV;
}

my $infile = $filename . ".dat";
my $outfile = $filename . ".tex";
open(my $ofh, ">$outfile") || die "can't open $outfile for writing";
select($ofh);

my %sheet = readDat($infile);
# %sheet contains the meta data
my %maphash = %{$sheet{"map"}};

# if a language was used on the command line, use that, else
# check if dat file specified a language, else select "de"
if($lang eq "" && defined($maphash{"lang"}) )
{
	$lang = $maphash{"lang"};
}
else
{
	$lang = "de";
}

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
		my %p = readDat("Exercises/" . $problem . ".dat");
		push @problems, \%p;
	}
}

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
					if($cmd eq "newpage")
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
								if($lang ne "de" && defined $pmhash{"$token-$lang"})
								{
									print STDERR "using $token-$lang instead\n";
									s/%%$token%%/$pmhash{"$token-$lang"}/;
								}
								else
								{
									s/%%$token%%/$pmhash{$token}/;
								}
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
			my $hashkey = $token;
			my $hashkey_lang = "$token-$lang";
			if($lang ne "de")
			{
				print STDERR "checking for key $hashkey_lang\n";
				if( defined $maphash{$hashkey_lang}) {
					$hashkey = $hashkey_lang;
				}
				else
				{
					print STDERR "no foreign text defined for key $hashkey_lang\n";
				}
			}

			if(defined $maphash{$hashkey})
			{
				print STDERR "replacing $token with " . $maphash{$hashkey} . " using key $hashkey\n";
				s/%%$token%%/$maphash{$hashkey}/;
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

package Soar::WM::Slurp;

use strict;
use warnings;
use 5.010;
use Autodie;
use Carp;

use base qw(Exporter);
our @EXPORT = qw(read_wm);

#structure will be: 
# return_val->{$wme} = { #wmeval=>$wme, $attr=>@values}
# {'root_wme'} = 'S1' or some such

our $VERSION = '0.01';

say Dump read_wm(file => $ARGV[0]) unless caller;

#parse a WME dump file and create a WM object; return the WM hash and the name of the root WME.
sub read_wm {
	my %args = (
		text	=> undef,
		file	=> undef,
		@_
	);
	my $fh;
	if($args{text}){
		$fh = _get_fh_from_string($args{text});
	}elsif($args{file}){
		$fh = _get_fh($args{file});
	}else{
		$fh = \*STDIN;
		carp 'Reading WME dump from standard in.';
	}
	
	#control variables
	my ($hasOpenParen,$hasCloseParen,$line,$wme,
		$rest,$rec,@attvals,$thiss,$attr,$val,);
	
	#keep track of results/return value
	my ($root_wme, %wme_hash);
	while (my $inline = <$fh>){
		chomp $inline;
		next if $inline eq '';
		$line = "";
		$hasOpenParen = ($inline =~ /^\s*\(/);
		$hasCloseParen = ($inline =~ /\)\s*$/);

		#read entire space between parentheses
		while ($hasOpenParen && !($hasCloseParen))
		{
			chomp $inline;
			$line .= $inline;
			$inline = <$fh>;
			#if this line of the WME dump is incomplete, ignore it.
			if(!$inline){
				$inline = '';
				$line = '';
				last;
			}
			$hasCloseParen = ($inline =~ /\)\s*$/);
		}
		$line .= $inline;
		if($line){
			#separate wme and everything else [(<wme> ^the rest...)]
			($wme, $rest) = split " ", $line, 2;

			# initiate the record
			$rec = {};

			# hash each of the attr/val pairs
			@attvals = split /\^/, $rest;
			shift @attvals;#get rid of the entry, which is just an empty string.
			foreach $thiss (@attvals)
			{
				($attr, $val) = split " ", $thiss;
				if (!length($attr))
				{
					next;
				}
				
				#get rid of final parenthesis
				$val =~ s/\)$//;
				
				# store attr/val association in the record
				push @{$rec->{"$attr"}}, $val;
			}

			#strip opening parenthesis and store WME id
			$wme =~ s/^\(//;
			$rec->{'#wmeval'} = $wme;

			#rootwme is S1, or similar
			$root_wme = $wme unless $root_wme;
			
			# add the record to the wme hash
			$wme_hash{$wme} = $rec;
		}
	}
	close $fh;
	return \%wme_hash, $root_wme;
}

sub _get_fh_from_string{
	my $text = shift;
	open my $sh, '<', \$text;
	return $sh;
}

sub _get_fh{
	my ($name) = shift;
	return $name if ref $name eq 'GLOB';
	open my $fh, '<', $name;
	return $fh;
}

__END__
=head1 NAME

Soar::WM::Slurp - Perl extension for slurping Soar WME dump files.

=head1 SYNOPSIS

  use Soar::WM::Slurp;
  use Data::Dumper;
  my ($WM_hash, $root_name) = read_wm(file => 'path/to/wme/dump/file');
  print 'root is ' . $root_name;
  print Dumper($WM_hash);

=head1 DESCRIPTION
 
=head METHODS

=head2 C<read_wm>
Takes a named argument, either file => 'path/to/file', file => $fileGlob, or text => 'WME dump here'.
Returns a pointer to a hash structure representing the input WME dump, and the name of the root WME, in a list like this: ($hash, $root).

Note that any incomplete WME structures will be ignored; for example:

	(S1 ^foo bar ^baz boo ^link S2)
	(S2 ^faz far ^boo baz ^fuzz buzz

The second line in the above text will be ignored. Although some of the structure there is apparent, accepting incomplete structures would require much more 
error and input checking. WME dumps are normally complete, so this should not be a problem.

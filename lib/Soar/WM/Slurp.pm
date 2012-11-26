package Soar::WM::Slurp;

use strict;
use warnings;
use 5.010;
use Autodie;
use Data::Dump::Streamer;

use base qw(Exporter);
our @EXPORT = qw(read_wm);

#structure will be: 
# {'wme_hash'}->{$wme} = { #wmeval=>$wme, $attr=>@values}
# {'root_wme'} = S1 or some such

our $VERSION = '0.01';

say Dump read_wm(@ARGV) unless caller;

#parse a WME dump file and create a WM object; return the root WME object.
sub read_wm {
	my ($input) = @_;
	my $fh = _getFH($input) || \*STDIN;
	
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
			#minimize error in case an incomplete WME dump was generated
			if(!$inline){
				$inline = '';
				last;
			}
			$hasCloseParen = ($inline =~ /\)\s*$/);
		}
		$line .= $inline;
		
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
	return \%wme_hash, $root_wme;
}

sub _getFH{
	my ($name) = shift;
	return undef unless $name;
	open my $fh, '<', $name;
	return $fh;
}

__END__
=head1 NAME

Soar::WM::Slurp - Perl extension for slurping Soar WME dump files.

=head1 SYNOPSIS

  use Soar::WM::Slurp;
  use Data::Dumper;
  my ($WM_hash, $root_name) = read_wm('path/to/wme/dump/file');
  print 'root is ' . $root_name;
  print Dumper($WM_hash);

=head1 DESCRIPTION
 
=head METHODS

=head2 C<read_wm>

=head1 SEE ALSO
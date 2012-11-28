use strict;
use warnings;

# ABSTRACT: Traverse Soar working memory dumps
package Soar::WM;
use Soar::WM::Slurp;
use Carp;
use base 'Exporter';
use Data::Dumper;
our @EXPORT = qw( get_root );

our $VERSION = '.01';

print  __PACKAGE__->get_wm_root($ARGV[0])->id unless caller;

#return a Soar::WM::Element object for the root
sub get_wm_root {
	my ($class, $file) = @_;
	croak 'missing file name argument'
		unless $file;
	
	my ($wme_hash, $root_name) = read_wm_file($file);
	
	my $wm = bless $wme_hash, $class;
	return Soar::WM::Element->new($wm, $root_name);
}

1;

=pod
=head1 NAME

Soar::WM - Perl extension for representing Soar working memory given a WME dump file

=head1 SYNOPSIS

  use Soar::WM;

=head1 DESCRIPTION


=head METHODS

=head2 C<get_root>
This function is automatically exported into the using module's namespace.


=cut

package Soar::WM::Element;

sub new {
	my ($class, $wm, $id) = @_;
	my $self = bless {
		wm => $wm, 
		id => $id
	}, $class;
	return $self;
}

# sub first_child {
	# my ($self, $name) = @_;
# }

# sub children {
	# my ($self, $name) = @_;
# }

# sub value {
	# my ($self) = @_;
	
# }

sub id {
	my ($self) = @_;
	return $self->{id};
}

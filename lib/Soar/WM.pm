# ABSTRACT: Traverse Soar working memory dumps
package Soar::WM;
use strict;
use warnings;

use Soar::WM::Slurp qw(read_wm);
use Soar::WM::Element;

use Carp;
use base 'Exporter';
our @EXPORT_OK = qw( wm_root_from_file wm_root );

# VERSION

print 'root is ' . __PACKAGE__->wm_root_from_file( $ARGV[0] )->id unless caller;

sub new {
    my ($class, @slurp_args) = @_;
    my ( $wme_hash, $root_name ) = read_wm(@slurp_args);
    my $wm = bless $wme_hash, $class;
	$wm->{'#root_name'} = $root_name;
	return $wm;
}

sub get_wme {
	my ($self, $id) = @_;
	return Soar::WM::Element->new($self, uc $id);
}

#return a Soar::WM::Element object for the root
sub wm_root_from_file {
    my ($file) = @_;
    if ( !$file ) {
        carp 'missing file name argument';
        return;
    }

    return wm_root( file => $file );

}

#args should be file=>xx or text=>xx.
sub wm_root {
    my @slurp_args = @_;
    my ( $wme_hash, $root_name ) = read_wm(@slurp_args);

    my $wm = bless $wme_hash, __PACKAGE__;
    return Soar::WM::Element->new( $wm, $root_name );
}



1;

__END__

=head1 NAME

Soar::WM - Perl extension for representing Soar working memory given a WME dump file

=head1 SYNOPSIS

  use Soar::WM qw(wm_root_from_file);
  my $root = wm_root_from_file('/path/to/wme/dump');
  print $root->id; #probably prints S1

=head1 DESCRIPTION

This module represents Soar's working memory. It can be used for traversing and manipulating WME dumps
generated by Soar.

=head1 METHODS

=head2 C<new>

Creates a new instance of Soar::WM. The arguments to this method are the same as those to wm_root.

=head2 C<get_wme>

Argument: string working memory element ID ('S1', 'Z33', etc.); since WME ID's are always uppercase, this method is
case insensitive.

Returns a L<Soar::WM::Element> instance representing the given ID. 

=head2 C<wm_root_from_file>

This is a shortcut for:

 wm_root(file=>$arg)
 
It's single argument is the path to a WME dump file, or an opened file handle for one. It returns a L<Soar::WM::Element> object representing the root
of the given WME dump.

=head2 C<wm_root>

This function reads in a Soar WME dump and returnes a L<Soar::WM::Element> representing its root.
It takes a named argument, file or text. Using C<wm_root(file=>path)> or C<wm_root(file=>$fileGlob)>, you can create an object given the path to a WME dump file.

Using C<wm_root(text=>'(S1 ^foo bar)')>, you can create an object using a given WME dump text. 
If neither argument is specified, this function will wait for input from standard in.

=head1 SEE ALSO

The homepage for the Soar cognitive architecture is here: L<http://sitemaker.umich.edu/soar/home>.


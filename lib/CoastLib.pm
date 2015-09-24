
package CoastLib;

# utils for processing Coastal Observatory files.

use strict;
use warnings;

sub readLidarAsc
{
	my( $filename ) = @_;

	my $lidar = bless { cells=>[] }, "CoastLib::LidarAsc";
	open( my $infh, "<", $filename ) || die( "failed to read $filename: $!" );
	for( 1..6 )
	{
		my $line = readline( $infh );
		$line =~ s/[\n\r]//g;
		$line =~ m/^([^\s]+)\s+(.*)$/;
		$lidar->{$1} = $2;
	}
	while( my $line = readline( $infh ) )
	{
		$line =~ s/[\n\r]//g;
		push @{$lidar->{cells}},[split( / /, $line )];
	}
	close( $infh );

	return $lidar;	
}
#ncols         500
#nrows         500
#xllcorner     453500
#yllcorner     77000
#cellsize      1
#NODATA_value  -9999

################################################################################
################################################################################
################################################################################

package CoastLib::LidarAsc;

sub write
{
	my( $self, $outfile ) = @_;

	open( my $outfh, ">", $outfile ) || die "Can't write $outfile: $!";
	foreach my $mfield ( qw/ ncols nrows xllcorner yllcorner cellsize NODATA_value /)
	{
		print {$outfh} sprintf( "%-14s%s\n", $mfield, $self->{$mfield} );
	}
	foreach my $row ( @{$self->{cells}} )
	{
		print {$outfh} join( " ", @$row )."\n";
	}
	close $outfh;
}

1;


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
		if( $line =~ m/^([^\s]+)\s+(.*)$/ )
		{
			$lidar->{$1} = $2;
		}
		else
		{
			die "Bad line in .asc file: $line";
		}
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

sub file_copy
{
	my( $src, $dest ) = @_;

	my $size = (stat $src)[7];

	my @dest_path = split( '/', $dest );
	pop @dest_path;
	shift @dest_path;
	my $dest_i = "";
	foreach my $path_bit ( @dest_path )
	{
		$dest_i .= '/'.$path_bit;
		if( ! -d $dest_i )
		{
			mkdir( $dest_i );
		}
	}

	
	my $v=1;
	my $dest2 = $dest;
	if( -e $dest.".1" )
	{
		$dest2 = $dest.".1";
	}
	my $altered_dest = 0;
	while( -e $dest2 )
	{
		my $size2 = (stat $dest2)[7];
		if( $size2 == $size ) 
		{ 
			print "No need to copy. Both files are $size sized.\n"; 
			return;
		}

		$v++;
		$dest2 = $dest.".".$v;
		$altered_dest = 1;
	}
	my $cmd = "cp '$src' '$dest2'";
	print "$cmd\n";
	`$cmd`;
	if( -e $dest && $altered_dest )
	{
		my $cmd = "mv '$dest' '$dest.1'";
		print "$cmd\n";
		`$cmd`;
	}

}

sub find_all
{
	my( $dir, $path ) = @_;
	
	$path = "" if !defined $path;

	my @files = ();
	my @dirs = ();
	opendir( my $dh, $dir ) || die "Failed to readdir $dir\n";
	while( my $file = readdir( $dh ) )
	{
		next if( $file eq "." );
		next if( $file eq ".." );
		if( -d "$dir/$file" )
		{
			push @dirs, $file;
		}
		else
		{
			push @files, $path."/".$file;
		}
	}
	closedir( $dh );

	foreach my $sub_dir ( @dirs )
	{
		push @files, find_all( "$dir/$sub_dir", "$path/$sub_dir" );
	}

	return @files;
}

################################################################################
################################################################################
################################################################################

package CoastLib::LidarAsc;
use Data::Dumper;

sub new
{
	my( $class, %params ) = @_;

	if( !defined $params{cellsize} ) { die "new LidarAsc needs a cellsize"; }
	if( !defined $params{xllcorner} ) { die "new LidarAsc needs a xllcorner"; }
	if( !defined $params{yllcorner} ) { die "new LidarAsc needs a yllcorner"; }
	if( !defined $params{nrows} ) { die "new LidarAsc needs a nrows"; }
	if( !defined $params{ncols} ) { die "new LidarAsc needs a ncols"; }
	if( !defined $params{NODATA_value} ) { $params{NODATA_value} = -9999; }

	my $self = bless {%params}, $class;
	if( !defined $self->{cells} )
	{
		$self->{cells} = [];
		for( my $y=0; $y<$self->{nrows}; ++$y )
		{
			for( my $x=0; $x<$self->{ncols}; ++$x )
			{
				$self->{cells}->[$y]->[$x] = $self->{NODATA_value};
			}
		}
	}
	return $self;
}

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

sub add
{
	my( $self, $other ) = @_;

	if( $self->{cellsize} != $other->{cellsize} ) 
	{
		die "Mismatched cellsize in Lidar->add";
	}
	
	my $offsetx = ($self->{xllcorner}-$other->{xllcorner})/$self->{cellsize};
	my $offsety = $other->{nrows}-$self->{nrows}-(($self->{yllcorner}-$other->{yllcorner})/$self->{cellsize});

	for( my $y=0; $y<$other->{nrows}; ++$y )
	{
		CELL: for( my $x=0; $x<$other->{ncols}; ++$x )
		{
			# overwrite.
			next CELL if $other->{cells}->[$y]->[$x] == $self->{NODATA_value};

			$self->{cells}->[$offsety+$y]->[$offsetx+$x] = $other->{cells}->[$y]->[$x];
		}
	}
}

1;

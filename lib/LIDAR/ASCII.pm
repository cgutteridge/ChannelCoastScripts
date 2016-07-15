# by Christopher Gutteridge, cjg@ecs.soton.ac.uk, 2015
# This library is LGPL and very rough around the edges!

package LIDAR::ASCII;

use Data::Dumper;

sub read
{
	my( $class, $filename ) = @_;

	my $lidar = bless { cells=>[] }, $class;
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
		$line =~ s/^ +//;
		$line =~ s/ +$//;
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

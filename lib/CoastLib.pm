package CoastLib;

# utils for processing Coastal Observatory files.

use strict;
use warnings;

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

1;


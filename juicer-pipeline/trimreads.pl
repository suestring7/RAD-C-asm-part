use strict;
use warnings;

### pipe fastq file in
### one at a time should be fine for paired reads
### will replace GATCGATC with GATC and cut the remainder of the read and quality score

while (<STDIN>){

	my $read = <STDIN>;
	my $mid = <STDIN>;
	my $quality = <STDIN>;

	chomp $quality;
	chomp $read;

	$read =~ s/GATCGATC.+/GATC/;
	while ( length( $read ) < length( $quality ) ){
		chop $quality;
	}

	print $_;
	print $read, "\n";
	print $mid;
	print $quality, "\n";
}

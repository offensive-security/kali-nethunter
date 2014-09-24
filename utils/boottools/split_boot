#!/usr/bin/perl
######################################################################
#
#   File          : split_boot
#   Author(s)     : William Enck <enck@cse.psu.edu>
#					Modified by CNexus to split the <nameHere>.img to a separate folder
#					and to display the BASE address so that the files can be repacked correctly.
#					
#   Description   : Split appart an Android boot image created 
#                   with mkbootimg. The format can be found in
#                   android-src/system/core/mkbootimg/bootimg.h
#
#                   Thanks to alansj on xda-developers.com for 
#                   identifying the format in bootimg.h and 
#                   describing initial instructions for splitting
#                   the boot.img file.
#
#   Last Modified : Tue Dec  2 23:36:25 EST 2008
#   By            : William Enck <enck@cse.psu.edu>
#
#   Copyright (c) 2008 The Pennsylvania State University
#   Systems and Internet Infrastructure Security Laboratory
#
#   Licensed under the Apache License, Version 2.0 (the "License"); 
#   you may not use this file except in compliance with the License. 
#   You may obtain a copy of the License at 
#
#       http://www.apache.org/licenses/LICENSE-2.0 
#
#   Unless required by applicable law or agreed to in writing, software 
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License. 
#
######################################################################

use strict;
use warnings;

# Turn on print flushing
$|++;

######################################################################
## Global Variables and Constants

my $SCRIPT = __FILE__;
my $IMAGE_FN = undef;

# Constants (from bootimg.h)
use constant BOOT_MAGIC => 'ANDROID!';
use constant BOOT_MAGIC_SIZE => 8;
use constant BOOT_NAME_SIZE => 16;
use constant BOOT_ARGS_SIZE => 512;

# Unsigned integers are 4 bytes
use constant UNSIGNED_SIZE => 4;

# Parsed Values
my $PAGE_SIZE = undef;
my $KERNEL_SIZE = undef;
my $RAMDISK_SIZE = undef;
my $SECOND_SIZE = undef;

######################################################################
## Main Code

&parse_cmdline();
&parse_header($IMAGE_FN);

=format (from bootimg.h)
** +-----------------+
** | boot header     | 1 page
** +-----------------+
** | kernel          | n pages
** +-----------------+
** | ramdisk         | m pages
** +-----------------+
** | second stage    | o pages
** +-----------------+
**
** n = (kernel_size + page_size - 1) / page_size
** m = (ramdisk_size + page_size - 1) / page_size
** o = (second_size + page_size - 1) / page_size
=cut

my $n = int(($KERNEL_SIZE + $PAGE_SIZE - 1) / $PAGE_SIZE);
my $m = int(($RAMDISK_SIZE + $PAGE_SIZE - 1) / $PAGE_SIZE);
my $o = int(($SECOND_SIZE + $PAGE_SIZE - 1) / $PAGE_SIZE);

my $k_offset = $PAGE_SIZE;
my $r_offset = $k_offset + ($n * $PAGE_SIZE);
my $s_offset = $r_offset + ($m * $PAGE_SIZE);

(my $base = $IMAGE_FN) =~ s/.*\/(.*)$/$1/;
(my $base2 = $base) =~ s/\.[^.]+$//;

my $k_file = $base2. "/" . $base . "-kernel";
my $r_file = $base2. "/" . $base . "-ramdisk.cpio.gz";
my $s_file = $base2. "/" . $base . "-second.gz";

mkdir $base2;
mkdir $base2 . "/ramdisk";

# The kernel is always there
print "Writing $k_file ...";
&dump_file($IMAGE_FN, $k_file, $k_offset, $KERNEL_SIZE);
print " complete.\n";

# The ramdisk is always there
print "Writing $r_file ...";
&dump_file($IMAGE_FN, $r_file, $r_offset, $RAMDISK_SIZE);
print " complete.\n";

# The Second stage bootloader is optional
unless ($SECOND_SIZE == 0) {
    print "Writing $s_file ...";
    &dump_file($IMAGE_FN, $s_file, $s_offset, $SECOND_SIZE);
    print " complete.\n";
}

print "Unpacking ramdisk...";
print " complete.\n";
system("cd $base2/ramdisk && gunzip -c ../$base-ramdisk.cpio.gz | cpio -i > /dev/null 2>&1");
    
######################################################################
## Supporting Subroutines

=header_format (from bootimg.h)
struct boot_img_hdr
{
    unsigned char magic[BOOT_MAGIC_SIZE];

    unsigned kernel_size;  /* size in bytes */
    unsigned kernel_addr;  /* physical load addr */

    unsigned ramdisk_size; /* size in bytes */
    unsigned ramdisk_addr; /* physical load addr */

    unsigned second_size;  /* size in bytes */
    unsigned second_addr;  /* physical load addr */

    unsigned tags_addr;    /* physical addr for kernel tags */
    unsigned page_size;    /* flash page size we assume */
    unsigned unused[2];    /* future expansion: should be 0 */

    unsigned char name[BOOT_NAME_SIZE]; /* asciiz product name */

    unsigned char cmdline[BOOT_ARGS_SIZE];

    unsigned id[8]; /* timestamp / checksum / sha1 / etc */
};
=cut
sub parse_header {
    my ($fn) = @_;
    my $buf = undef;

    open INF, $fn or die "Could not open $fn: $!\n";
    binmode INF;

    # Read the Magic
    read(INF, $buf, BOOT_MAGIC_SIZE);
    unless ($buf eq BOOT_MAGIC) {
	die "Android Magic not found in $fn. Giving up.\n";
    }

    # Read kernel size and address (assume little-endian)
    read(INF, $buf, UNSIGNED_SIZE * 2);
    my ($k_size, $k_addr) = unpack("VV", $buf);

    # Read ramdisk size and address (assume little-endian)
    read(INF, $buf, UNSIGNED_SIZE * 2);
    my ($r_size, $r_addr) = unpack("VV", $buf);

    # Read second size and address (assume little-endian)
    read(INF, $buf, UNSIGNED_SIZE * 2);
    my ($s_size, $s_addr) = unpack("VV", $buf);

    # Read tags_addr
    read(INF, $buf, UNSIGNED_SIZE);
    my ($tags_addr) = unpack("V", $buf);

    # get the page size (assume little-endian)
    read(INF, $buf, UNSIGNED_SIZE);
    my ($p_size) = unpack("V", $buf);

    # Ignore unused
    read(INF, $buf, UNSIGNED_SIZE * 2);

    # Read the name (board name)
    read(INF, $buf, BOOT_NAME_SIZE);
    my $name = $buf;

    # Read the command line
    read(INF, $buf, BOOT_ARGS_SIZE);
    my $cmdline = $buf;

    # Ignore the id
    read(INF, $buf, UNSIGNED_SIZE * 8);

    # Close the file
    close INF;

    # Print important values
    printf "Page size: %d (0x%08x)\n", $p_size, $p_size;
    printf "Kernel size: %d (0x%08x)\n", $k_size, $k_size;
    printf "Ramdisk size: %d (0x%08x)\n", $r_size, $r_size;
    printf "Second size: %d (0x%08x)\n", $s_size, $s_size;
    printf "Board name: $name\n";
    printf "Command line: \'$cmdline\'\n";
    printf "Base address: (0x%08x)\n", $tags_addr - 0x00000100;
	print "\n";

    # Save the values
    $PAGE_SIZE = $p_size;
    $KERNEL_SIZE = $k_size;
    $RAMDISK_SIZE = $r_size;
    $SECOND_SIZE = $s_size;
}

sub dump_file {
    my ($infn, $outfn, $offset, $size) = @_;
    my $buf = undef;

    open INF, $infn or die "Could not open $infn: $!\n";
    open OUTF, ">$outfn" or die "Could not open $outfn: $!\n";

    binmode INF;
    binmode OUTF;

    seek(INF, $offset, 0) or die "Could not seek in $infn: $!\n";
    read(INF, $buf, $size) or die "Could not read $infn: $!\n";
    print OUTF $buf or die "Could not write $outfn: $!\n";

    close INF;
    close OUTF;
}

######################################################################
## Configuration Subroutines

sub parse_cmdline {
    unless ($#ARGV == 0) {
	die "Usage: $SCRIPT boot.img\n";
    }
    $IMAGE_FN = $ARGV[0];
}




#!/usr/bin/perl -w

use Time::HiRes;

sub main {
    my $interval = 0.5;
    my $i = 0;
    my $targetURL = "";
    my $wordfile = "";
    my $suffix = "";
	if (@ARGV < 2) {
        badargs();
    }
    if ($ARGV[$i] eq "-i") {
        $i++;
        if (@ARGV < 4) {
            badargs();
        }
        $interval = $ARGV[$i];
	if ($interval < 0.1) {
		$interval = 0.1;
	}
        chomp $interval;
        $i++;
    }
    $targetURL = $ARGV[$i];
    chomp $targetURL;
    $i++;
    $wordfile = $ARGV[$i];
    chomp $wordfile;
    $i++;
    if ($ARGV[$i]) {
        $suffix = $ARGV[$i];
        $suffix =~ s/[ \t]+//g;
        $i++;
    }
    not_404($targetURL, $wordfile, $interval, $suffix);
}

sub not_404 {
    my $targURL = shift;
    my $wordf = shift;
    my $interval = shift;
    my $suffix = shift;
    open(my $wordfh, '<:encoding(UTF-8)', $wordf) or die("Count not open $wordf: $!.\n");
    while ($word = <$wordfh>) {
        chomp $word;
        $word =~ s/[ \t]+//g;
        $url = "$targURL/$word$suffix";
        system("wget -o denormwgetlog.txt $url >htmldenorm.txt");   # unusual names so they're unlikely to overwrite files
        open(my $fh, '<:encoding(UTF-8)', "denormwgetlog.txt") or print("failed to open the log for $url\n") and next;
        while ($line = <$fh>) {
            if ($line =~ /200 OK/i) {
                print "found something at $url\n";
                system("rm $word$suffix");
                last;
            }
        }
	system("sleep $interval");
    }
}

sub badargs {
    die("Usage: $0 [-i <interval>] <targetURL> <wordfile> [<suffix>]\n");
}

main();
system("rm htmldenorm.txt denormwgetlog.txt");

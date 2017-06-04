#!/usr/bin/perl -w

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
    is_not_default($targetURL, $wordfile, $interval, $suffix);
}

sub is_not_default {
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
        open(my $fh, '<:encoding(UTF-8)', "denormwgetlog.txt") or print("failed to open a log\n") and next;
        while ($line = <$fh>) {
            if ($line =~ /200 OK/i) {
                print "found something at $url\n";
                system("rm $word$suffix");
                last;
            }
        }
    }
}

sub badargs {
    die("Usage: $0 [-i <interval>] <targetURL> <wordfile> [<suffix>]\n");
}

main();
system("rm htmldenorm.txt denormwgetlog.txt");

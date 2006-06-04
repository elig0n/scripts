#!/usr/bin/perl
# report a message as spam and then delete it

use strict;
use warnings;

use Mail::Box::Mbox;

my $folder = Mail::Box::Mbox->new(access => "rw",
                                  create => 0,
                                  folder => "/home/michael/mail/Junk");

my $count = 0;
foreach my $message ($folder->messages)
{
    my $subject = $message->subject;

    # skip dummy message created by IMAP server
    next if $subject =~ /FOLDER INTERNAL DATA/;

    print $message->subject . "\n";

    if (open(BOGO, "|/usr/bin/bogofilter -s"))
    {
        $message->print(\*BOGO);
        $message->delete();
        $count++;
    }
    else
    {
        warn "Cannot connect to bogofilter";
    }
}

$folder->close()
    or die "Cannot close mail box";

print STDERR "Reported $count messages\n";
exit 0;

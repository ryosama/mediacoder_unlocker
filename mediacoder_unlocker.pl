#!perl -w

use strict;

use Win32::GuiTest qw(:ALL);
my $mediacoderWindowsDonationId;

# wait for donation box
START:

print "Wait for donation box...\n";
do {
  $mediacoderWindowsDonationId = 0;
  $mediacoderWindowsDonationId = detectDonationWindow();
  sleep(2);
} while (not $mediacoderWindowsDonationId) ;

# donation box found
print "Find donation window (id : $mediacoderWindowsDonationId)\n";

# try to answer question
my $math_result = computeMathElement($mediacoderWindowsDonationId);
if ($math_result eq '') {
  die "Could not find math question\n";
} else {
  print "Result is $math_result\n";
}


my @coords = GetWindowRect($mediacoderWindowsDonationId);

# set focus on window
SetFocus($mediacoderWindowsDonationId);
# send mouse to result box
MouseMoveAbsPix($coords[0] + 348, $coords[1] + 243);
# click
SendLButtonDown(); SendLButtonUp();
# send result
SendKeys($math_result);
# send mouse to continue button
MouseMoveAbsPix($coords[0] + 348, $coords[1] + 280);
# click
SendLButtonDown(); SendLButtonUp();

# loop
sleep(10);
goto START;

################################################################################################################
sub detectDonationWindow {
  foreach (FindWindowLike(undef, "Continue in ")) {
    #my $text = GetWindowText($_);
    #printf "GetWindowText($_) : $text\n";
    return $_;
  }
  return;
}


sub computeMathElement {
  my $windowId = shift;
  my @children = GetChildWindows($windowId);

  foreach (@children) {
    my $text = WMGetText($_);
    #print "Result for '$_' : '$text'\n" ;
    if ($text =~ /Let's do a simple math: ([^=]+)=/i) {
      print "Question is : $1\n";
      my $result = eval($1);
      return $result;
    }
  }
  return '';
}
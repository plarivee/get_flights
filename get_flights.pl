#! /usr/bin/perl

use strict;
use utf8;
use WWW::Mechanize;
use HTML::TableExtract;
use Date::Simple qw/ date today /;
$| = 1;
my $offset = "0";
my $mech = WWW::Mechanize->new;
my @heavies = ('B748','B744','B742','A340','A343','A345','A380','B77W','A333','MD11');
my @exotics_ident = ('RAM','RJA','UAE','KLM','BAW','DLH','DAH','DLX','SWR','RZO','CUB');
my @airports = ('CYUL');
my $sameday= 1;
my $dow = today;
my $day=  substr($dow->strftime("%A"),0,3);
print $day;


foreach my $airport (@airports) {
	$offset = "0";
	## Fetch EnRoute flights.
	print "\n******************* $airport :: ALERTE LOURD ENTRANT ****************************\n\n";
	while ($sameday) {
		my $url_enroute = "http://flightaware.com/live/airport/$airport/enroute?;offset=$offset;order=estimatedarrivaltime;sort=ASC";
		$mech->get($url_enroute);
		my $te = HTML::TableExtract->new( headers => [qw(Ident Type Origin Estimated)] );
		my $content = $mech->content();
		$content =~ s/&nbsp;/ /g;
		$te->parse($content);
		 foreach my $ts ($te->tables) {
			foreach my $row ($ts->rows) {
				my ($operator) = $row->[0] =~ m/\s(\D+)/i ;
	#			print "'$operator'\n";
				if ($row->[1]  ~~ @heavies) {	
					print "HVY | ";
					print join(" | ", @$row), "\n";
				} elsif ( $operator ~~ @exotics_ident) {
					print "EXO | ";
					print join(" | ", @$row), "\n";
				}
				if ($day ne substr($row->[3],0,3) && $offset != "0" ){
#					print substr($row->[3],0,3);
					$sameday = 0;
				}
			}
		 }
		 $offset += "20";
	}
	print "\n\n***********************************************************************\n\n";
}



foreach my $airport (@airports) {
	## Fetch Departure flights.
	print "\n******************* $airport :: ALERTE LOURD DEPART  ****************************\n\n";
	$offset = "0";
	$sameday = 1;
	while ($sameday) {
		my $url_enroute = "http://flightaware.com/live/airport/$airport/scheduled?;offset=$offset;order=filed_departuretime;sort=ASC";
		$mech->get($url_enroute);
		my $te = HTML::TableExtract->new( headers => [qw(Ident Type Destination Scheduled)] );
		my $content = $mech->content();
		$content =~ s/&nbsp;/ /g;
		$te->parse($content);
		 foreach my $ts ($te->tables) {
			foreach my $row ($ts->rows) {
				my ($operator) = $row->[0] =~ m/\s(\D+)/i ;
	#			print "'$operator'\n";
				if ($row->[1]  ~~ @heavies) {	
					print "HVY | ";
					print join(" | ", @$row), "\n";
				} elsif ( $operator ~~ @exotics_ident) {
					print "EXO | ";
					print join(" | ", @$row), "\n";
				}
				if ($day ne substr($row->[3],0,3) && $offset != "0" ){
#					print substr($row->[3],0,3);
					$sameday = 0;
				}
			}
		 }
		 $offset += "20";
	}
	print "\n\n***********************************************************************\n\n";
}


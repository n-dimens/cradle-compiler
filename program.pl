#! /usr/bin/perl

use strict;
use warnings;

my $look;

&init();

sub init {
	&get_char();
}

sub get_char {
	chomp ($look = <STDIN>);
}

# (msg: string) -> void
sub error {
	print "[ERROR] $_[0].\n";
}

sub abort {
	&error($_[0]);
	exit 1;
}

sub expected {
	&abort("$_[0] Expected");
}

sub match {
	my $x = $_[0];
	if ($look eq $x) {
		&get_char();
	} else {
		&expected("'${x}'");
	}
}

sub isAlpha {
	return $_[0] =~ m/[A-Z]/i;
}

sub isDigit {
	return $_[0] =~ /[0-9]/i;
}

sub get_name {
	if (!&isAlpha($look)) {
		&expected("Name");
	}
	
	my $result = uc $look;
	&get_char();
	$result;
}

sub emit {
	print "\t $_[0]";
}

sub emitln {
	print "\t $_[0]\n";
}

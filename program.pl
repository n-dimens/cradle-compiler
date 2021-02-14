#! /usr/bin/perl

use strict;
use warnings;

my $look;

&init();
&expression();

sub init {
	&get_char();
}

## Lexer

# Следующий символ
sub get_char {
	$look = getc STDIN;
}

# Идентификатор
sub get_name {
	if (!&is_alpha($look)) {
		&expected("Name");
	}
	
	my $result = uc $look;
	&get_char();
	$result;
}

# Число
sub get_num {
	if (!&is_digit($look)) {
		&expected("Integer");
	}
	
	my $result = uc $look;
	&get_char();
	$result;
}

## Правила грамматики

sub term {
	&emitln("MOVE #" . &get_num() . ",D0");
}

sub expression {
	&term();
	while ($look =~ /[+-]/) {
		&emitln("MOVE D0,-(SP)");
		if ($look eq "+") {
			&add(); 
		} elsif ($look eq "-") {
			&subtract();
		} else {
			&expected("Addop");
		}			
	}
}

sub add {
	&match("+");
	&term();
	&emitln("ADD (SP)+,D0");
}

sub subtract {
	&match("-");
	&term();
	&emitln("SUB (SP)+,D0");
	&emitln("NEG D0");
}

## private

# Проверка обязательного символа
sub match {
	my $x = $_[0];
	if ($look eq $x) {
		&get_char();
	} else {
		&expected("'${x}'");
	}
}

sub is_alpha {
	$_[0] =~ m/[A-Z]/i;
}

sub is_digit {
	$_[0] =~ /[0-9]/i;
}

#  Возврат сформированной команды
sub emit {
	print "\t $_[0]";
}

sub emitln {
	print "\t $_[0]\n";
}

## Обработка ошибок

sub expected {
	&abort("$_[0] Expected");
}

sub abort {
	&error($_[0]);
	exit 1;
}

sub error {
	print "\n[ERROR] $_[0].\n";
}

1;

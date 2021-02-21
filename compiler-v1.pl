#! /usr/bin/perl

## syntax analyzer by chapters 1-3

use strict;
use warnings;

my $look;

# entry point
sub main {
	&init();
	&expression();
	# if ($look ne "\n") {
	# 	&expected("New line");
	# }
}

sub init {
	&get_char();
	&skip_spaces();
}

## Lexer

# Следующий символ
sub get_char {
	$look = getc STDIN;
}

# Идентификатор
sub get_name {
	my $token = "";
	if (!&is_alpha($look)) {
		&expected("Name");
	}
	
	while (&is_alpha($look) || &is_digit($look)) {
		$token .= uc $look;
		&get_char();
	}

	&skip_spaces();
	$token;
}

# Число
sub get_num {
	my $value = "";
	if (!&is_digit($look)) {
		&expected("Integer");
	}
	
	while (&is_digit($look)) {
		$value .= $look;
		&get_char();
	}

	&skip_spaces();
	$value;
}

sub skip_spaces {
	while (&is_space($look)) {
		&get_char();
	}
}

## Правила грамматики

sub ident {
	my $name = &get_name();
	if ($look eq "(") {
		&match("(");
		&match(")");
		&emitln("BSR ${name}");
	} else {
		&emitln("MOVE " . &get_name() . "(PC),D0");
	}
}

sub factor {
	if ($look eq "(") {
		&match("(");
		&expression();
		&match(")");
	} elsif (&is_alpha($look)) {
		&ident();
	} else {
		&emitln("MOVE #" . &get_num() . ",D0");
	}	
}

sub term {
	&factor();
	while ($look =~ /[*\/]/) {
		&emitln("MOVE D0,-(SP)");
		if ($look eq "*") {
			&multiply();
		} elsif ($look eq "/") {
			&divide();
		} else {
			&expected("Mulop");
		}
	}
}

sub expression {
	if (&is_addop($look)) {
		&emitln("CLR D0"); # - вставить 0 в начало выражения для эмуляции унарных + -
	} else {
		&term();
	}
	
	while (&is_addop($look)) {
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

sub assignment {
	my $name = &get_name();
	&match('=');
	&expression();
	&emitln("LEA $name(PC),A0");
	&emitln('MOVE D0,(A0)')
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

sub multiply {
	&match("*");
	&factor();
	&emitln("MULS (SP)+,D0");
}

sub divide {
	&match("/");
	&factor();
	&emitln("MOVE (SP)+,D1");
	&emitln("DIVS D1,D0");
}

## Обработка ошибок

sub expected {
	my ($package, $filename, $line) = caller;
	&abort("$_[0] Expected. Found: '${look}' in (${line})");
}

sub abort {
	&error($_[0]);
	exit 1;
}

sub error {
	print "\n[ERROR] $_[0].\n";
}

## private

# Проверка обязательного символа
sub match {
	my $x = $_[0];
	if ($look eq $x) {
		&get_char();
		&skip_spaces();
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

sub is_space {
	($_[0] eq " ") || ($_[0] eq "\t");
}

sub is_addop {
	$_[0] =~ /[+-]/
}

#  Возврат сформированной команды
sub emit {
	print "\t $_[0]";
}

sub emitln {
	print "\t $_[0]\n";
}

sub print_debug {
	my ($package, $filename, $line) = caller;
	print "Call from ${filename}:${line}";
}

## Script body

main();
1;

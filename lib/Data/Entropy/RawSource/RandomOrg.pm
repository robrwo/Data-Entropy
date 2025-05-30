=head1 NAME

Data::Entropy::RawSource::RandomOrg - download entropy from random.org

=head1 SYNOPSIS

	use Data::Entropy::RawSource::RandomOrg;

	my $rawsrc = Data::Entropy::RawSource::RandomOrg->new;

	$c = $rawsrc->getc;
	# and the rest of the I/O handle interface

=head1 DESCRIPTION

This class provides an I/O handle connected to a stream of random octets
being generated by an electromagnetic noise detector connected to the
random.org server.  This is a strong source of random bits, but is not
suitable for security applications because the bits are passed over the
Internet unencrypted.  The handle implements a substantial subset of
the interface described in L<IO::Handle>.

For use as a general entropy source, it is recommended to wrap an object
of this class using C<Data::Entropy::Source>, which provides methods to
extract entropy in more convenient forms than mere octets.

The bits generated at random.org are, theoretically and as far as anyone
can tell, totally unbiased and uncorrelated.  However, they are sent
over the Internet in the clear, and so are subject to interception and
alteration by an adversary.  This is therefore generally unsuitable for
security applications.  The capacity of the random bit server is also
limited.  This class will slow down requests if the server's entropy
pool is less than half full, and (as requested by the server operators)
pause entirely if the entropy pool is less than 20% full.

Applications requiring secret entropy should generate it locally
(see L<Data::Entropy::RawSource::Local>).  Applications requiring a
large amount of entropy should generate it locally or download it from
randomnumbers.info (see L<Data::Entropy::RawSource::RandomnumbersInfo>).
Applications requiring a large amount of apparently-random data,
but not true entropy, might prefer to fake it cryptographically (see
L<Data::Entropy::RawSource::CryptCounter>).

=cut

package Data::Entropy::RawSource::RandomOrg;

{ use 5.006; }
use warnings;
use strict;

use Errno 1.00 qw(EIO);
use HTTP::Lite 2.2 ();

our $VERSION = "0.009";

=head1 CONSTRUCTOR

=over

=item Data::Entropy::RawSource::RandomOrg->new

Creates and returns a handle object referring to a stream of random
octets generated by random.org.

=cut

sub new {
	my($class) = @_;
	my $http = HTTP::Lite->new;
	$http->http11_mode(1);
	return bless({
		http => $http,
		buffer => "",
		bufpos => 0,
		error => 0,
	}, $class);
}

=back

=head1 METHODS

A subset of the interfaces described in L<IO::Handle> and L<IO::Seekable>
are provided:

=over

=item $rawsrc->read(BUFFER, LENGTH[, OFFSET])

=item $rawsrc->getc

=item $rawsrc->ungetc(ORD)

=item $rawsrc->eof

Buffered reading from the source, as in L<IO::Handle>.

=item $rawsrc->sysread(BUFFER, LENGTH[, OFFSET])

Unbuffered reading from the source, as in L<IO::Handle>.

=item $rawsrc->close

Does nothing.

=item $rawsrc->opened

Retruns true to indicate that the source is available for I/O.

=item $rawsrc->clearerr

=item $rawsrc->error

Error handling, as in L<IO::Handle>.

=back

The buffered (C<read> et al) and unbuffered (C<sysread> et al) sets
of methods are interchangeable, because no such distinction is made by
this class.

Methods to write to the file are unimplemented because the stream is
fundamentally read-only.  Methods to seek are unimplemented because the
stream is non-rewindable; C<ungetc> works, however.

=cut

sub _checkbuf {
	my($self) = @_;
	$self->{http}->reset;
	unless($self->{http}->request(
		"http://www.random.org/cgi-bin/checkbuf"
	) == 200) {
		$! = EIO;
		return undef;
	}
	unless($self->{http}->body =~
			/\A[\ \t\n]*([0-9]{1,3}(?:\.[0-9]+)?)\%[\ \t\n]*\z/) {
		$! = EIO;
		return undef;
	}
	return $1;
}

sub _ensure_buffer {
	my($self) = @_;
	return 1 unless $self->{bufpos} == length($self->{buffer});
	while(1) {
		my $fillpct = $self->_checkbuf;
		return 0 unless defined $fillpct;
		if($fillpct >= 20) {
			sleep((50 - $fillpct)*0.2) if $fillpct < 50;
			last;
		}
		sleep 10;
	}
	$self->{http}->reset;
	unless($self->{http}->request(
		"http://www.random.org/cgi-bin/randbyte?nbytes=256&format=f"
	) == 200) {
		$! = EIO;
		return 0;
	}
	$self->{buffer} = $self->{http}->body;
	$self->{bufpos} = 0;
	if($self->{buffer} !~ /\A[\x00-\xff]+\z/) {
		$self->{buffer} = "";
		$! = EIO;
		return 0;
	}
	return 1;
}

sub close { 1 }

sub opened { 1 }

sub error { $_[0]->{error} }

sub clearerr {
	my($self) = @_;
	$self->{error} = 0;
	return 0;
}

sub getc {
	my($self) = @_;
	unless($self->_ensure_buffer) {
		$self->{error} = 1;
		return undef;
	}
	return substr($self->{buffer}, $self->{bufpos}++, 1);
}

sub ungetc {
	my($self, $cval) = @_;
	if($self->{bufpos} == 0) {
		$self->{buffer} = chr($cval).$self->{buffer};
	} else {
		$self->{bufpos}--;
	}
}

sub read {
	my($self, undef, $length, $offset) = @_;
	return undef if $length < 0;
	$_[1] = "" unless defined $_[1];
	if(!defined($offset)) {
		$offset = 0;
		$_[1] = "";
	} elsif($offset < 0) {
		return undef if $offset < -length($_[1]);
		substr $_[1], $offset, -$offset, "";
		$offset = length($_[1]);
	} elsif($offset > length($_[1])) {
		$_[1] .= "\0" x ($offset - length($_[1]));
	} else {
		substr $_[1], $offset, length($_[1]) - $offset, "";
	}
	my $original_offset = $offset;
	while($length != 0) {
		unless($self->_ensure_buffer) {
			$self->{error} = 1;
			last;
		}
		my $avail = length($self->{buffer}) - $self->{bufpos};
		if($length < $avail) {
			$_[1] .= substr($self->{buffer}, $self->{bufpos},
					$length);
			$offset += $length;
			$self->{bufpos} += $length;
			last;
		}
		$_[1] .= substr($self->{buffer}, $self->{bufpos}, $avail);
		$offset += $avail;
		$length -= $avail;
		$self->{bufpos} += $avail;
	}
	my $nread = $offset - $original_offset;
	return $nread == 0 ? undef : $nread;
}

*sysread = \&read;

sub eof { 0 }

=head1 SEE ALSO

L<Data::Entropy::RawSource::CryptCounter>,
L<Data::Entropy::RawSource::Local>,
L<Data::Entropy::RawSource::RandomnumbersInfo>,
L<Data::Entropy::Source>,
L<http://www.random.org>

=head1 AUTHOR

Andrew Main (Zefram) <zefram@fysh.org>

Maintained by Robert Rothenberg <rrwo@cpan.org>

=head1 COPYRIGHT

Copyright (C) 2006, 2007, 2009, 2011, 2025
Andrew Main (Zefram) <zefram@fysh.org>

=head1 LICENSE

This module is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

=cut

1;

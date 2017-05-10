#!/usr/local/bin/perl

package stream;

use constant false => 0;
use constant true => 1;

sub DESTROY
{

}

sub tell
{
	my ( $stream ) = @_;

	my $pos = tell $stream->{_fd};

	return $pos;
}

sub seek
{
        my ( $stream, $pos, $start ) = @_;

        seek $stream->{_fd}, $pos, $start;
        my $fd = $stream->{_fd};

        if (!eof $fd)
        {
                $stream->{_eof} = false;
        }
}

sub is_open
{
        my( $stream ) = @_;
        return $stream->{_is_open};
}

sub close {
        my( $stream ) = @_;

        close $stream->{_fd};
        $stream->{_is_open} = false;
}

sub fail
{
        my( $stream ) = @_;
        return $stream->{_fail};
}
1;

package istream;
@ISA = qw(stream);

use constant false 	=> 0;
use constant true 	=> 1;

sub new
{
        my $class = shift;
        my $istream = {
                _fd 	  => undef,
                _line 	  => undef,
                _is_open  => false,
                _eol 	  => false,
                _eof      => false,
                _fail     => false,
        };
        bless $istream, $class;
        return $istream;
}

sub open
{
    my ( $istream, $path ) = @_;

    if (open($istream->{_fd}, "<", $path))
    {
    	$istream->{_is_open} = true;
    }
    else
    {
    	$istream->{_is_open} = false;
    }
}

sub peek {
    my( $istream ) = @_;

    my $char;
    my $pos;

    $char = getc $istream->{_fd};

    if (eof $fd)
    {
    	$istream->{_eof} = true;
    	$istream->{_fail} = true;
    }
    $pos = tell $istream->{_fd};
    seek $istream->{_fd}, $pos-1, 0;

    if ($char eq "\n")
    {
    	$istream->{_eol} = true;
    }

    return $char;
}

sub find
{
	my ( $istream, $find_str ) = @_;

	my $fd;
	my $line;

	$fd = $istream->{_fd};

	while (!eof($fd))
	{
		$line = <$fd>;
        	$line =~ s/^\s+|\s+$//g;

		if ($line =~ m/$find_str/ig)
		{
			last;
		}
	}
	if (eof($fd))
	{
		$istream->{_eof} = true;
	}
	$istream->{_line} = $line;

	return tell $fd;
}

sub getline
{
	my( $istream ) = @_;

	my $fd;
	$fd = $istream->{_fd};

	if (!eof $fd)
	{
		$istream->{_line} = <$fd>;

		if (eof $fd)
        	{
                	$istream->{_eof} = true;

        	}
	}

	return $istream->{_line};
}

sub readline
{
	my( $istream ) = @_;

	return $istream->{_line};
}

sub read
{
	my ( $istream, $bytes ) = @_;

	my $buffer;
	my $char;

	$buffer = "";
	for my $i (1 .. $bytes)
	{
		$char = getc $istream->{_fd};
		if ($char eq "\n")
		{
			$istream->{_eol} = true;
		}
		$buffer = $buffer.$char;
	}

	return $buffer;
}

sub rdbuf
{
	my( $istream ) = @_;
	my $fd;
	my $buffer;

	$fd = $istream->{_fd};
	$buffer = "";

	while ( <$fd> )
	{
		$buffer = $buffer.$_;
	}

	return $buffer;
}

sub eof
{
	my( $istream ) = @_;

	return $istream->{_eof};
}

sub eol
{
	my( $istream ) = @_;

	return $istream->{_eol};
}
1;

package ostream;
@ISA = qw(stream);

use constant false => 0;
use constant true => 1;

# Override constructor
sub new
{
        my $class = shift;
        my $ostream = {
                _fd 			=> undef,
                _is_open	=> false,
                _fail			=> false,
        };
        bless $ostream, $class;

        return $ostream;
}

sub open
{
        my ( $ostream, $path ) = @_;

        unless(open($ostream->{_fd}, ">", $path))
        {
                $ostream->{_fail} = true;
        }
        if ($ostream->{_fail} != true)
        {
                $ostream->{_is_open} = true;
        }
}

sub put
{
	my ( $ostream, $char ) = @_;

	my $fd = $ostream->{_fd};
	print $fd $char;
}

sub write
{
	my ( $ostream, $data ) = @_;

	my $fd = $ostream->{_fd};
	print $fd $data;
}

sub flush
{
	#TODO:
}
1;

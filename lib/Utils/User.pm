package Utils::User; {

=encoding utf8

=head1 NAME

    Different utilites 

=cut

use 5.012000;
use strict;
use warnings;
use utf8;
use Db;
use Data::Dumper;

sub authorized {
    my ($c,$db,$password) = @_;
    if( !$db || !$db->is_valid  || !$password ){
        warn "Variables not define properly to detect project existance!";
        return(undef);
    }

    my $objects = $db->get_objects( { value => [$password], field => ['password'] } );
    if( $objects ){
        my @keys = keys(%{$objects});
        my $size = scalar(@keys);
        if ( $size == 0 ){ # not found!
            return(undef);
        } elsif( $size > 1 ){
            warn "Password is not unique in database scope!";
            return(undef);
        }
        $objects = $db->get_objects( { id => [$keys[0]] } );
        $c->session->{'project id'} = Utils::trim $c->stash->{prefix} ;
        $c->session->{'user type'} = $objects->{$keys[0]}{object_name};
        $c->session->{'user id'} = $keys[0];
        if( $objects->{$keys[0]}{object_name} eq 'recipient' ){
            $c->session->{'user email'} = $objects->{$keys[0]}{email};
            $c->session->{'user name'} = $objects->{$keys[0]}{name};
        }
        return(1);
    }
    return(undef);
};

sub logout{
    my $c = shift;
    return if !$c;
    $c->session(expires => 1);
    return(1);
};

# END OF PACKAGE
};

1;

__END__

=head1 AUTHOR

    M.Nurullaev <maksud.nurullaev@gmail.com>

=cut


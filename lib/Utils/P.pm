package Utils::P; {

=encoding utf8

=head1 NAME

    Different utilites 

=cut

use 5.012000;
use strict;
use warnings;
use utf8;
use Data::Dumper;
use Utils;

sub post_add{
    my $c = shift;
    my $data = Utils::validate($c,['title','project_id','password','password_confirmation'],['description']);
    Utils::validate_password2($c,$data);
    if( ! exists $data->{error} ){
        delete $data->{password_confirmation} ;
        warn Dumper $data;
        return(1)
    }
    return(0)
};

# END OF PACKAGE
};

1;

__END__

=head1 AUTHOR

    M.Nurullaev <maksud.nurullaev@gmail.com>

=cut

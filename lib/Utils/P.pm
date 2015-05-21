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

sub post_add {
    my ($c,$db) = @_;
    if( !$c || !$db ){
        warn "Variables not define properly to add new project!";
        return(undef);
    }
    my $data = Utils::validate($c,['title','project_id','password','password_confirmation'],['description']);
    Utils::validate_password2($c,$data);
    if( ! exists $data->{error} ){
        delete $data->{password_confirmation} ;
        if( !project_exist($c,$db,$data->{project_is}) ){
            return(1) if $db->insert($data) ;
        } else {
            $c->stash( "error_project_already_exist" => 1 );
        }
    }
    return(0)
};

sub post_update{
    my ($c,$db) = @_;
    if( !$c || !$db ){
        warn "Variables not define properly to add new project!";
        return(undef);
    }
    my $data = Utils::validate($c,['id','object_name','title'],['description']);
    if( !exists $data->{error} ){
        if( $db->update($data) ){
            $c->stash( "success_updated" => 1 );
            return(1);
        } else {
            $c->stash( "error_updated" => 1 );
        }
    }
    return(0)
};

sub project_exist{
    my($c,$db,$project_id) = @_;
    if( !$c || !$db || !$project_id ){
        warn "Variables not define properly to detect project existance!";
        return(undef);
    }
    my $objects = $db->get_objects({name=>['project'],add_where=>"value='$project_id'"});
    if( $objects ){
        my @keys = keys %{$objects};
        return(undef) if scalar(@keys) == 0;
        return($keys[0]) if scalar(@keys) == 1;
        warn "Many objects with same project id: $project_id";
    }
    return(undef);
};

sub project_deploy{
    my($c,$db,$project_id) = @_;
    if( !$c || !$db || !$project_id ){
        warn "Variables not define properly to detect project existance!";
        return(0);
    }
    my $objects = $db->get_objects( { id => [$project_id] } );
    if( $objects && exists( $objects->{$project_id} ) ){
        my $object = $objects->{$project_id};
        for my $key (keys %{$object}){
            $c->stash($key => $object->{$key});
        }
    } else {
        $c->stash( "error_project_not_exist" => 1 );
    }
};

# END OF PACKAGE
};

1;

__END__

=head1 AUTHOR

    M.Nurullaev <maksud.nurullaev@gmail.com>

=cut

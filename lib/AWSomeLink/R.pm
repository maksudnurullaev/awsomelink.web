package AWSomeLink::R; {
use Mojo::Base 'Mojolicious::Controller';
use Utils;
use Utils::User;
use Utils::P;
use Db;

sub _check_access{
    my $c = shift;
    my $user_type = $c->session('user type');
    if( !$user_type || $user_type ne 'recipient' ){
        my $prefix = Utils::trim $c->stash->{prefix};
        $c->redirect_to("/$prefix/p/authorization") ;
        return(0);
    }
    return(1);
};

sub start {
    my $c = shift;
    return if ! _check_access($c);
    my $prefix = Utils::trim $c->stash->{prefix};

    my $db = Db->new($c,$prefix) ;
    my $project_db_id = Utils::P::get_project_db_id($db,$prefix) ;
    Utils::P::project_deploy($c,$db,$project_db_id) if $project_db_id ;
}

sub files {
    my $c = shift;
    return if ! _check_access($c);
};

sub participants{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;

    my $project_db_id = Utils::P::get_project_db_id($db,$prefix) ;
    Utils::P::project_deploy($c,$db,$project_db_id) if $project_db_id ;
    Utils::P::project_deploy_($c,$db,'recipient','participants') ;
};

1;

};

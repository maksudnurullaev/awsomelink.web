package AWSomeLink::R; {
use Mojo::Base 'Mojolicious::Controller';
use Utils;
use Utils::User;
use Utils::P;
use Utils::R;
use Db;
use Data::Dumper;

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
    Utils::deploy_db_object($c,$db,$project_db_id) if $project_db_id ;
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
    Utils::deploy_db_object($c,$db,$project_db_id) if $project_db_id ;
    Utils::deploy_db_objects($c,$db,'recipient','participants') ;
};

sub issues{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;
    Utils::deploy_db_objects($c,$db,'issue','issues') ;
};

sub issues_add{
    my $c = shift ;
    return if !  _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;

    if( lc($c->req->method) eq 'post' ){
        if( Utils::R::issue_add($c,$db) ){
            $c->redirect_to("/$prefix/r/issues");
        } else {
        }
    }
    
    Utils::deploy_db_objects($c,$db,'property','properties') ;
};

1;

};

package AWSomeLink::R; {
use Mojo::Base 'Mojolicious::Controller';
use Utils;
use Utils::User;
use Utils::P;
use Utils::R;
use Db;
use Utils::Excel;
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
    Utils::deploy_db_objects($c,$db,'issue','issues',$c->session('issues filter')) ;
    Utils::deploy_db_objects($c,$db,'recipient','participants') ;
};

sub export{
    my $c = shift ;
    return if ! _check_access($c);

    my ($file_path,$file_name) = Utils::Excel::export($c);
    if ($file_path && $file_name){
        $c->render_file( filepath => $file_path, filename => $file_name );
    } else {
        my $prefix = Utils::trim $c->stash->{prefix} ;
        $c->redirect_to("/$prefix/r/issues");
    }
};

sub issues_nofilter{
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    $c->session( 'issues filter' => undef );
    $c->redirect_to( "/$prefix/r/issues" ) ;
};

sub issues_filter{
    my $c = shift ;
    return if ! _check_access($c);

    $c->session( 'issues filter' => $c->param('filter') );
    $c->redirect_to($c->param('return_path')) ;
};

sub issues_edit{
    my $c = shift ;
    #return if !  _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;
    my $payload = Utils::trim $c->stash->{payload};
    if( $payload ){
        if( lc($c->req->method) eq 'post' ){
            if( Utils::R::check_rw_access($db,$payload,$c->session('user id')) ){
                Utils::R::issue_edit($c,$db,$payload) ;
            } else {
                $c->stash( error_rw => 1 );
            }
        }
        Utils::deploy_db_object($c,$db,$payload) ;
        Utils::deploy_db_objects($c,$db,'property','properties') ;
    } else {
        $c->redirect_to("/$prefix/r/issues");
    }
};

sub issues_add{
    my $c = shift ;
    return if !  _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;

    if( lc($c->req->method) eq 'post' ){
        if( Utils::R::issue_add($c,$db) ){
            $c->redirect_to("/$prefix/r/issues");
        } 
    }
    
    Utils::deploy_db_objects($c,$db,'property','properties') ;
};

sub issues_delete_files{
    my $c = shift ;
    return if !  _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $payload = Utils::trim $c->stash->{payload};

    my $db = Db->new($c,$prefix) ;
    if( Utils::R::check_rw_access($db,$payload,$c->session('user id')) ){
        my $files = $c->every_param('files');
        my $path = Utils::R::get_files_path($c,$payload);
        for my $file_name (@{$files}){
            my $file_path = "$path/$file_name";
            unlink $file_path if -e $file_path ;
        }
    }   
    $c->redirect_to("/$prefix/r/issues_edit/$payload");
};

sub issues_delete {
    my $c = shift ;
    return if ! _check_access($c);

    my $prefix = Utils::trim $c->stash->{prefix} ;
    my $db = Db->new($c,$prefix) ;
    my $payload = Utils::trim $c->stash->{payload};

    if( Utils::R::check_rw_access($db,$payload,$c->session('user id')) ){
        # 1. delete db record
        $db->del($payload) ;
        # 2. delete files # !!!VERY DANGEROUS!!!
        my $path = Utils::R::get_files_path($c,$payload);
        system("rm -fR $path");
    }

    $c->redirect_to("/$prefix/r/issues");
};

1;

};

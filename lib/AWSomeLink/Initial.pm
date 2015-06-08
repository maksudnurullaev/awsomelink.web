package AWSomeLink::Initial; {
use Mojo::Base 'Mojolicious::Controller';
# use S3Manager ;
use Utils;
use Db;
use Utils::P;

sub start {
    my $c = shift;
    return if lc($c->req->method) ne 'post' ;
    
    my $prefix = Utils::trim($c->param('prefix') || $c->stash->{prefix});

    if( !$prefix || length($prefix) < 8 ){
        $c->stash(error => "Invalid LinkID!") if $prefix;
    } else {
        if( lc($c->req->method) eq 'post' ){
            my $db = Db->new($c,$prefix);
            if( Utils::P::project_exist($c,$db,$prefix) ){
                my $path = "/$prefix/p/edit";
                $c->redirect_to($path) ;
            }
        }
    }
}

1;

};

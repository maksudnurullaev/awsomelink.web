package AWSomeLink::Initial; {
use Mojo::Base 'Mojolicious::Controller';
use S3Manager ;
use Utils;

sub start {
    my $self = shift;
    my $prefix = Utils::trim $self->stash->{prefix};
    if( $prefix && length($prefix) >= 8 ){
        my $keys = S3Manager::get_keys($prefix);
        $self->stash( keys => $keys );
    } else {
        $prefix = Utils::trim $self->param('prefix');
        if( $prefix && length($prefix) >= 8 ){
            $self->redirect_to("/$prefix");
        } else {
            $self->stash(error => "Invalid LinkID!") if $prefix;
        }
    }
}

1;

};

package AWSomeLink::P; {
use Mojo::Base 'Mojolicious::Controller';
use Utils;

sub start {
    my $self = shift;
    my $prefix = Utils::trim $self->stash->{prefix};
    warn $prefix;
}

sub add {
    my $self = shift;
    my $new_project_id = Utils::get_uuid();
    $self->stash( new_project_id => $new_project_id );
};

1;

};
